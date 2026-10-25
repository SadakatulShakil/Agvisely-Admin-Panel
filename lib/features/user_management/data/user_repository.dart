import 'dart:math';

import '../../../core/mock/mock_store.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/json_utils.dart';
import '../../../models/admin_user.dart';
import '../../../models/paginated.dart';
import '../../../models/rbac.dart';
import '../../../models/user_directory.dart';

/// User directory and role permissions.
abstract class UserRepository {
  Future<UserDirectoryPage> fetchUsers(UserQuery query);
  Future<AdminUser> setStatus(int userId, UserStatus status);
  Future<AdminUser> createUser(CreateUserRequest request);

  Future<RbacMatrix> fetchRbac();
  Future<RbacMatrix> saveRbac(RbacMatrix matrix);
}

class RemoteUserRepository implements UserRepository {
  final ApiClient _api = ApiClient.instance;

  @override
  Future<UserDirectoryPage> fetchUsers(UserQuery query) async {
    final resp = await _api.get(
      ApiEndpoints.adminUsers,
      query: query.toQuery(),
    );
    final root = Json.map(resp);
    final meta = Json.map(root['meta']);
    final counts = Json.map(root['counts']);
    final items = Json.list(root['data']).map(AdminUser.fromJson).toList();
    return UserDirectoryPage(
      users: Paginated(
        items: items,
        page: Json.asInt(meta['page'], query.page),
        limit: Json.asInt(meta['limit'], query.limit),
        total: Json.asInt(meta['total'], items.length),
      ),
      totalAll: Json.asInt(counts['all'], Json.asInt(meta['total'])),
      professions:
          Json.list(
            counts['professions'],
          ).map(ProfessionCount.fromJson).toList(),
    );
  }

  @override
  Future<AdminUser> setStatus(int userId, UserStatus status) async {
    final resp = await _api.patch(
      ApiEndpoints.adminUserStatus(userId),
      body: {'status': status.apiValue},
    );
    return AdminUser.fromJson(Json.map(Json.data(resp)));
  }

  @override
  Future<AdminUser> createUser(CreateUserRequest request) async {
    final resp = await _api.post(
      ApiEndpoints.adminUsers,
      body: request.toJson(),
    );
    return AdminUser.fromJson(Json.map(Json.data(resp)));
  }

  @override
  Future<RbacMatrix> fetchRbac() async {
    final resp = await _api.get(ApiEndpoints.rbac);
    return RbacMatrix.fromJson(Json.map(Json.data(resp)));
  }

  @override
  Future<RbacMatrix> saveRbac(RbacMatrix matrix) async {
    final resp = await _api.put(
      ApiEndpoints.rbac,
      body: {'grants': matrix.grantsToJson()},
    );
    final data = Json.map(Json.data(resp));
    return data.isEmpty ? matrix : RbacMatrix.fromJson(data);
  }
}

class MockUserRepository implements UserRepository {
  final MockStore _db = MockStore.instance;

  @override
  Future<UserDirectoryPage> fetchUsers(UserQuery query) async {
    await MockStore.latency();
    final since = DateTime.now().subtract(query.period.duration);
    final term = query.search.trim().toLowerCase();

    final inScope =
        _db.users.where((u) {
          if (!u.registeredAt!.isAfter(since)) return false;
          if (term.isEmpty) return true;
          return u.name.toLowerCase().contains(term) ||
              u.phone.contains(term) ||
              u.location.toLowerCase().contains(term);
        }).toList();

    final filtered =
        query.professionId == null
            ? inScope
            : inScope
                .where((u) => u.professionId == query.professionId)
                .toList();

    final start = (query.page - 1) * query.limit;
    final pageItems =
        start >= filtered.length
            ? <AdminUser>[]
            : filtered.sublist(
              start,
              min(start + query.limit, filtered.length),
            );

    return UserDirectoryPage(
      users: Paginated(
        items: pageItems,
        page: query.page,
        limit: query.limit,
        total: filtered.length,
      ),
      totalAll: inScope.length,
      professions: [
        for (final e in MockStore.professions.entries)
          ProfessionCount(
            id: e.key,
            name: e.value,
            count: inScope.where((u) => u.professionId == e.key).length,
          ),
      ],
    );
  }

  @override
  Future<AdminUser> setStatus(int userId, UserStatus status) async {
    await MockStore.latency(350);
    final i = _db.users.indexWhere((u) => u.id == userId);
    if (i < 0) throw const ApiException('That user no longer exists.');
    _db.users[i] = _db.users[i].copyWith(status: status);
    return _db.users[i];
  }

  @override
  Future<AdminUser> createUser(CreateUserRequest request) async {
    await MockStore.latency(500);
    if (_db.users.any((u) => u.phone == request.phone)) {
      throw const ApiException(
        'A user with this mobile number already exists.',
        statusCode: 409,
      );
    }
    final user = AdminUser(
      id: _db.nextUserId(),
      name: request.name,
      phone: request.phone,
      profession: MockStore.professions[request.professionId] ?? '—',
      professionId: request.professionId,
      role: request.role,
      location: request.location,
      status: UserStatus.active,
      registeredAt: DateTime.now(),
    );
    _db.users.insert(0, user);
    return user;
  }

  @override
  Future<RbacMatrix> fetchRbac() async {
    await MockStore.latency(350);
    return _db.rbac;
  }

  @override
  Future<RbacMatrix> saveRbac(RbacMatrix matrix) async {
    await MockStore.latency(500);
    _db.rbac = matrix;
    return matrix;
  }
}
