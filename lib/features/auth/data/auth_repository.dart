import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/json_utils.dart';
import '../../../models/auth_user.dart';

class AuthResult {
  const AuthResult({
    required this.accessToken,
    required this.user,
    this.refreshToken,
    this.expiresIn,
  });

  final String accessToken;
  final String? refreshToken;
  final int? expiresIn;
  final AuthUser user;
}

/// Phone + OTP sign-in — the same backend flow as the mobile app's
/// `AuthController` (`/users/login` → `/users/verify-otp`).
abstract class AuthRepository {
  /// Sends an OTP to [phone] (canonical `01XXXXXXXXX`).
  Future<void> requestOtp(String phone);

  /// Exchanges the code for tokens and the account's profile (with role).
  Future<AuthResult> verifyOtp({required String phone, required String otp});

  /// Revokes the refresh token server-side. Never throws.
  Future<void> logout(String? refreshToken);
}

class RemoteAuthRepository implements AuthRepository {
  final ApiClient _api = ApiClient.instance;

  @override
  Future<void> requestOtp(String phone) async {
    await _api.post(ApiEndpoints.login, body: {'phone': phone}, auth: false);
  }

  @override
  Future<AuthResult> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    final resp = await _api.post(
      ApiEndpoints.verifyOtp,
      body: {'phone': phone, 'otp': otp, 'purpose': 'login'},
      auth: false,
    );
    final data = Json.map(Json.data(resp));
    final token = Json.asString(data['token'] ?? data['accessToken']);
    if (token.isEmpty) {
      throw const ApiException(
        'Sign-in succeeded but no session was returned. Try again.',
      );
    }

    // verify-otp's embedded user has no `role`; /users/me does.
    final meResp = await _api.get(ApiEndpoints.me, bearer: token);
    final me = Json.map(Json.data(meResp));
    final user = AuthUser.fromJson(me.isNotEmpty ? me : Json.map(data['user']));

    return AuthResult(
      accessToken: token,
      refreshToken: data['refreshToken']?.toString(),
      expiresIn: Json.asIntOrNull(data['accessTokenExpiresIn']),
      user: user,
    );
  }

  @override
  Future<void> logout(String? refreshToken) async {
    try {
      await _api.post(
        ApiEndpoints.logout,
        body: {if (refreshToken != null) 'refreshToken': refreshToken},
      );
    } catch (_) {
      // Best effort — the local session is cleared regardless.
    }
  }
}

/// Offline stand-in: any valid number, code [AppConfig.mockOtp].
class MockAuthRepository implements AuthRepository {
  @override
  Future<void> requestOtp(String phone) =>
      Future.delayed(const Duration(milliseconds: 600));

  @override
  Future<AuthResult> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (otp != AppConfig.mockOtp) {
      throw const ApiException(
        'That code is incorrect. Check the SMS and try again.',
        statusCode: 400,
      );
    }
    return AuthResult(
      accessToken: 'mock-access-${DateTime.now().millisecondsSinceEpoch}',
      refreshToken: 'mock-refresh',
      expiresIn: 3600,
      user: AuthUser(id: 1, name: 'DAE Admin', phone: phone, role: 'admin'),
    );
  }

  @override
  Future<void> logout(String? refreshToken) async {}
}
