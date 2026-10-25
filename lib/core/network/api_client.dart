import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../services/session_service.dart';
import 'api_endpoints.dart';
import 'api_exception.dart';
import 'json_utils.dart';

/// JSON HTTP client with bearer auth and one-shot token refresh — the web
/// counterpart of the mobile app's `ApiClient`.
///
/// * Authenticated requests carry the session's access token.
/// * A 401 triggers one shared refresh; the request is retried once.
/// * If the refresh fails, the session is cleared and the user is sent to
///   the sign-in page.
/// * Every failure surfaces as [ApiException] with a user-facing message.
class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  final http.Client _http = http.Client();
  static const Duration _timeout = Duration(seconds: 15);

  Future<String?>? _refreshing;

  Future<dynamic> get(
    String url, {
    Map<String, String>? query,
    bool auth = true,
    String? bearer,
  }) => _send('GET', url, query: query, auth: auth, bearer: bearer);

  Future<dynamic> post(String url, {Object? body, bool auth = true}) =>
      _send('POST', url, body: body, auth: auth);

  Future<dynamic> put(String url, {Object? body}) =>
      _send('PUT', url, body: body);

  Future<dynamic> patch(String url, {Object? body}) =>
      _send('PATCH', url, body: body);

  Future<dynamic> delete(String url, {Object? body}) =>
      _send('DELETE', url, body: body);

  Future<dynamic> _send(
    String method,
    String url, {
    Object? body,
    Map<String, String>? query,
    bool auth = true,
    String? bearer,
    bool retried = false,
  }) async {
    final uri = _buildUri(url, query);
    final token = bearer ?? (auth ? SessionService.to.accessToken : null);

    final request = http.Request(method, uri)
      ..headers.addAll({
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Accept-Language': Get.locale?.languageCode ?? 'en',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      });
    if (body != null) request.body = jsonEncode(body);

    _log('→ $method $uri');

    final http.Response response;
    try {
      final streamed = await _http.send(request).timeout(_timeout);
      response = await http.Response.fromStream(streamed);
    } on TimeoutException {
      throw const ApiException(
        'The server took too long to respond. Try again in a moment.',
      );
    } on http.ClientException {
      throw const ApiException(
        "Can't reach the server. Check your connection and try again.",
      );
    }

    _log('← ${response.statusCode} $uri');

    // Session-expired path — only for requests that used the session token.
    final usedSessionToken = auth && bearer == null && token != null;
    if (response.statusCode == 401 && usedSessionToken) {
      if (!retried) {
        final fresh = await _refreshAccessToken();
        if (fresh != null) {
          return _send(
            method,
            url,
            body: body,
            query: query,
            auth: auth,
            retried: true,
          );
        }
      }
      await SessionService.to.expire();
      throw const ApiException(
        'Your session has expired. Sign in again.',
        statusCode: 401,
      );
    }

    return _decode(response);
  }

  Uri _buildUri(String url, Map<String, String>? query) {
    final uri = Uri.parse(url);
    final params = <String, String>{...uri.queryParameters};
    query?.forEach((k, v) {
      if (v.isNotEmpty) params[k] = v;
    });
    return params.isEmpty ? uri : uri.replace(queryParameters: params);
  }

  dynamic _decode(http.Response response) {
    final text = response.body.trim();
    dynamic json;
    if (text.isNotEmpty) {
      try {
        json = jsonDecode(text);
      } on FormatException {
        json = null;
      }
    }

    final ok = response.statusCode >= 200 && response.statusCode < 300;
    if (ok) {
      if (text.isNotEmpty && json == null) {
        throw ApiException(
          'The server sent a response the panel can’t read.',
          statusCode: response.statusCode,
        );
      }
      return json;
    }

    final message =
        json is Map ? (json['message'] ?? json['error'])?.toString() : null;
    throw ApiException(
      (message != null && message.isNotEmpty)
          ? message
          : _fallbackMessage(response.statusCode),
      statusCode: response.statusCode,
    );
  }

  String _fallbackMessage(int status) => switch (status) {
    403 => 'Your account doesn’t have permission to do that.',
    404 => 'That item no longer exists.',
    >= 500 => 'The server ran into a problem. Try again in a moment.',
    _ => 'Request failed ($status).',
  };

  /// One refresh shared by every concurrent 401.
  Future<String?> _refreshAccessToken() {
    return _refreshing ??= _performRefresh().whenComplete(() {
      _refreshing = null;
    });
  }

  Future<String?> _performRefresh() async {
    final session = SessionService.to;
    final refreshToken = session.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) return null;
    try {
      final resp = await _send(
        'POST',
        ApiEndpoints.refreshToken,
        body: {'refreshToken': refreshToken},
        auth: false,
      );
      final data = Json.map(Json.data(resp));
      final access = Json.asString(data['accessToken']);
      if (access.isEmpty) return null;
      await session.updateTokens(
        accessToken: access,
        refreshToken: data['refreshToken']?.toString(),
        expiresIn: Json.asIntOrNull(data['accessTokenExpiresIn']),
      );
      return access;
    } catch (_) {
      return null;
    }
  }

  void _log(String message) {
    if (kDebugMode) log(message, name: 'API');
  }
}
