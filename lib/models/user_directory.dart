import '../core/network/json_utils.dart';
import 'admin_user.dart';
import 'paginated.dart';
import 'period.dart';

/// A profession tab ("Farmer-3,487") with its user count.
class ProfessionCount {
  const ProfessionCount({
    required this.id,
    required this.name,
    required this.count,
  });

  final int id;
  final String name;
  final int count;

  factory ProfessionCount.fromJson(Map<String, dynamic> j) => ProfessionCount(
    id: Json.asInt(j['id']),
    name: Json.asString(j['name']),
    count: Json.asInt(j['count']),
  );
}

/// Filters for `GET /admin/users`.
class UserQuery {
  const UserQuery({
    this.page = 1,
    this.limit = 10,
    this.search = '',
    this.professionId,
    this.period = Period.week,
  });

  final int page;
  final int limit;
  final String search;
  final int? professionId;
  final Period period;

  Map<String, String> toQuery() => {
    'page': '$page',
    'limit': '$limit',
    'period': period.apiValue,
    if (search.trim().isNotEmpty) 'search': search.trim(),
    if (professionId != null) 'professionId': '$professionId',
  };
}

/// One page of users plus the per-profession tab counts for the same
/// period and search.
class UserDirectoryPage {
  const UserDirectoryPage({
    required this.users,
    required this.totalAll,
    required this.professions,
  });

  final Paginated<AdminUser> users;
  final int totalAll;
  final List<ProfessionCount> professions;

  UserDirectoryPage replaceUser(AdminUser updated) => UserDirectoryPage(
    users: users.mapItems(
      (list) => [for (final u in list) u.id == updated.id ? updated : u],
    ),
    totalAll: totalAll,
    professions: professions,
  );
}

/// Body for `POST /admin/users`.
class CreateUserRequest {
  const CreateUserRequest({
    required this.name,
    required this.phone,
    required this.professionId,
    required this.role,
    required this.location,
  });

  final String name;
  final String phone;
  final int professionId;
  final String role;
  final String location;

  Map<String, dynamic> toJson() => {
    'name': name,
    'phone': phone,
    'professionId': professionId,
    'role': role,
    'location': location,
  };
}
