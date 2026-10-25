import '../core/network/json_utils.dart';

enum UserStatus {
  active('active', 'Active'),
  inactive('inactive', 'Inactive');

  const UserStatus(this.apiValue, this.label);
  final String apiValue;
  final String label;

  static UserStatus parse(dynamic v) {
    final s = v?.toString().toLowerCase();
    return (s == 'active') ? UserStatus.active : UserStatus.inactive;
  }
}

/// A row in the user directory (`GET /admin/users`).
class AdminUser {
  const AdminUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.profession,
    required this.role,
    required this.location,
    required this.status,
    this.professionId,
    this.registeredAt,
  });

  final int id;
  final String name;
  final String phone;
  final String profession;
  final int? professionId;
  final String role;
  final String location;
  final UserStatus status;
  final DateTime? registeredAt;

  bool get isActive => status == UserStatus.active;

  AdminUser copyWith({UserStatus? status}) => AdminUser(
    id: id,
    name: name,
    phone: phone,
    profession: profession,
    professionId: professionId,
    role: role,
    location: location,
    status: status ?? this.status,
    registeredAt: registeredAt,
  );

  factory AdminUser.fromJson(Map<String, dynamic> j) {
    final profession = j['profession'];
    final location = j['location'];
    return AdminUser(
      id: Json.asInt(j['id']),
      name: Json.asString(j['name']),
      phone: Json.asString(j['phone']),
      profession:
          profession is Map
              ? Json.asString(profession['name'])
              : Json.asString(profession ?? j['professionName'], '—'),
      professionId:
          profession is Map
              ? Json.asIntOrNull(profession['id'])
              : Json.asIntOrNull(j['professionId']),
      role: Json.asString(j['role'], 'farmer'),
      location:
          location is Map
              ? [
                location['upazila'],
                location['district'],
              ].where((e) => e != null && e.toString().isNotEmpty).join(', ')
              : Json.asString(location, '—'),
      status: UserStatus.parse(j['status']),
      registeredAt: Json.asDate(j['registeredAt'] ?? j['createdAt']),
    );
  }
}
