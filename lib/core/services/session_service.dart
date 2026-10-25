import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/routes/app_routes.dart';
import '../../models/auth_user.dart';

/// Holds the admin session: tokens (secure storage), the signed-in
/// profile, and the phone number waiting on the OTP step.
///
/// Loaded once before `runApp`, so route guards can check
/// [isAuthenticated] synchronously.
class SessionService extends GetxService {
  static SessionService get to => Get.find<SessionService>();

  static const _kAccess = 'admin_access_token';
  static const _kRefresh = 'admin_refresh_token';
  static const _kExpiresAt = 'admin_access_expires_at';
  static const _kUser = 'admin_user';
  static const _kPendingPhone = 'admin_pending_phone';

  final FlutterSecureStorage _secure = const FlutterSecureStorage();
  late final SharedPreferences _prefs;

  String? _accessToken;
  String? _refreshToken;

  /// The signed-in admin; null when signed out.
  final user = Rxn<AuthUser>();

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;

  bool get isAuthenticated =>
      (_accessToken?.isNotEmpty ?? false) && user.value != null;

  DateTime? get accessTokenExpiry {
    final ms = _prefs.getInt(_kExpiresAt);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<SessionService> init() async {
    _prefs = await SharedPreferences.getInstance();
    try {
      _accessToken = await _secure.read(key: _kAccess);
      _refreshToken = await _secure.read(key: _kRefresh);
    } catch (_) {
      // Corrupt or unreadable storage (e.g. cleared browser keys) —
      // treat as signed out rather than failing to boot.
      _accessToken = null;
      _refreshToken = null;
    }
    final raw = _prefs.getString(_kUser);
    if (raw != null && _accessToken != null) {
      try {
        user.value = AuthUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {
        user.value = null;
      }
    }
    return this;
  }

  // ── Session lifecycle ───────────────────────────────────────────────────

  Future<void> start({
    required String accessToken,
    String? refreshToken,
    int? expiresIn,
    required AuthUser profile,
  }) async {
    await updateTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresIn: expiresIn,
    );
    await _prefs.setString(_kUser, jsonEncode(profile.toJson()));
    user.value = profile;
  }

  Future<void> updateTokens({
    required String accessToken,
    String? refreshToken,
    int? expiresIn,
  }) async {
    _accessToken = accessToken;
    await _secure.write(key: _kAccess, value: accessToken);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      _refreshToken = refreshToken;
      await _secure.write(key: _kRefresh, value: refreshToken);
    }
    if (expiresIn != null) {
      await _prefs.setInt(
        _kExpiresAt,
        DateTime.now().add(Duration(seconds: expiresIn)).millisecondsSinceEpoch,
      );
    }
  }

  Future<void> clear() async {
    _accessToken = null;
    _refreshToken = null;
    user.value = null;
    try {
      await _secure.delete(key: _kAccess);
      await _secure.delete(key: _kRefresh);
    } catch (_) {}
    await _prefs.remove(_kExpiresAt);
    await _prefs.remove(_kUser);
  }

  /// Called when the token can't be refreshed: drop the session and go to
  /// sign-in, unless we're already there.
  Future<void> expire() async {
    await clear();
    final current = Get.currentRoute;
    if (current != AppRoutes.login && current != AppRoutes.otp) {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  // ── OTP hand-off (survives a page refresh on the OTP step) ──────────────

  String? get pendingPhone => _prefs.getString(_kPendingPhone);

  Future<void> setPendingPhone(String phone) =>
      _prefs.setString(_kPendingPhone, phone);

  Future<void> clearPendingPhone() => _prefs.remove(_kPendingPhone);
}
