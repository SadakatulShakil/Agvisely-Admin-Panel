import '../config/app_config.dart';

/// Every URL the panel calls. Auth endpoints are the same ones the mobile
/// app already uses; `/admin/*` is the admin contract documented in the
/// README.
class ApiEndpoints {
  ApiEndpoints._();

  static const String base = AppConfig.apiBaseUrl;

  // ── Auth (shared with the mobile app) ───────────────────────────────────
  static const String login = '$base/users/login';
  static const String verifyOtp = '$base/users/verify-otp';
  static const String refreshToken = '$base/users/refresh-token';
  static const String logout = '$base/users/logout';
  static const String me = '$base/users/me';
  static const String professions = '$base/professions';

  // ── Dashboard ───────────────────────────────────────────────────────────
  static const String dashboardSummary = '$base/admin/dashboard/summary';

  // ── Users & roles ───────────────────────────────────────────────────────
  static const String adminUsers = '$base/admin/users';
  static String adminUserStatus(int id) => '$base/admin/users/$id/status';
  static const String rbac = '$base/admin/rbac';

  // ── Content ─────────────────────────────────────────────────────────────
  static const String advisories = '$base/admin/advisories';
  static String advisoryStatus(int id) => '$base/admin/advisories/$id/status';

  // ── Forecast data sources ───────────────────────────────────────────────
  static const String dataSources = '$base/admin/data-sources';
  static String dataSourceDefault(String id) =>
      '$base/admin/data-sources/$id/default';
}
