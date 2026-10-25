import 'package:flutter/foundation.dart';

/// Build-time configuration, set with `--dart-define`.
///
///   flutter run -d chrome --dart-define=USE_MOCK=false \
///     --dart-define=API_BASE_URL=https://api.example.gov.bd/api/v1
class AppConfig {
  AppConfig._();

  static const String appName = 'Agvisely Admin';

  /// Same backend the mobile app talks to (`ApiEndpoints.baseUrlUser`).
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.68.52:3000/api/v1',
  );

  /// Serve every repository from in-memory mock data instead of the API.
  /// On by default in debug so the panel runs before the `/admin/*`
  /// endpoints exist; off by default in release builds.
  static const bool useMockData = bool.fromEnvironment(
    'USE_MOCK',
    defaultValue: !kReleaseMode,
  );

  /// The code the mock auth repository accepts.
  static const String mockOtp = '1234';

  /// Same as the mobile app (`AuthController.otpLength`).
  static const int otpLength = 4;

  /// Seconds before "Resend code" becomes available.
  static const int otpResendSeconds = 60;

  /// `users.role` values allowed into the admin panel.
  static const Set<String> panelRoles = {'admin', 'super_admin'};

  static const int defaultPageSize = 10;
}
