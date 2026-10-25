import '../core/config/app_config.dart';
import '../core/network/json_utils.dart';

/// The signed-in administrator. Same shape as the mobile app's `UserModel`
/// (`GET /users/me`), trimmed to what the panel needs.
class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    required this.phone,
    this.role,
    this.profileUrl,
  });

  final int id;
  final String name;
  final String phone;
  final String? role;
  final String? profileUrl;

  /// Whether this account's role is allowed into the admin panel.
  bool get canUsePanel =>
      role != null && AppConfig.panelRoles.contains(role!.toLowerCase());

  String get initials {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'A';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  factory AuthUser.fromJson(Map<String, dynamic> j) => AuthUser(
    id: Json.asInt(j['id']),
    name: Json.asString(j['name']),
    phone: Json.asString(j['phone']),
    role: j['role']?.toString(),
    profileUrl: j['profileUrl']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'role': role,
    'profileUrl': profileUrl,
  };
}
