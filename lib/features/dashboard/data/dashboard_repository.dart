import '../../../core/mock/mock_store.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/json_utils.dart';
import '../../../models/dashboard.dart';
import '../../../models/period.dart';

/// Overview data: headline stats, advisory rules and forecast sources.
abstract class DashboardRepository {
  Future<DashboardSummary> fetchSummary(Period period);

  Future<List<CropAdvisory>> fetchAdvisories({int limit = 5});
  Future<CropAdvisory> setAdvisoryStatus(int id, AdvisoryStatus status);

  Future<List<DataSource>> fetchDataSources();

  /// Makes [id] the source the mobile app reads from; returns the new list.
  Future<List<DataSource>> setDefaultSource(String id);
}

class RemoteDashboardRepository implements DashboardRepository {
  final ApiClient _api = ApiClient.instance;

  @override
  Future<DashboardSummary> fetchSummary(Period period) async {
    final resp = await _api.get(
      ApiEndpoints.dashboardSummary,
      query: {'period': period.apiValue},
    );
    return DashboardSummary.fromJson(Json.map(Json.data(resp)));
  }

  @override
  Future<List<CropAdvisory>> fetchAdvisories({int limit = 5}) async {
    final resp = await _api.get(
      ApiEndpoints.advisories,
      query: {'limit': '$limit', 'sort': '-updatedAt'},
    );
    return Json.list(Json.data(resp)).map(CropAdvisory.fromJson).toList();
  }

  @override
  Future<CropAdvisory> setAdvisoryStatus(int id, AdvisoryStatus status) async {
    final resp = await _api.patch(
      ApiEndpoints.advisoryStatus(id),
      body: {'status': status.apiValue},
    );
    return CropAdvisory.fromJson(Json.map(Json.data(resp)));
  }

  @override
  Future<List<DataSource>> fetchDataSources() async {
    final resp = await _api.get(ApiEndpoints.dataSources);
    return Json.list(Json.data(resp)).map(DataSource.fromJson).toList();
  }

  @override
  Future<List<DataSource>> setDefaultSource(String id) async {
    await _api.put(ApiEndpoints.dataSourceDefault(id));
    return fetchDataSources();
  }
}

class MockDashboardRepository implements DashboardRepository {
  final MockStore _db = MockStore.instance;

  @override
  Future<DashboardSummary> fetchSummary(Period period) async {
    await MockStore.latency(500);
    final since = DateTime.now().subtract(period.duration);
    final newUsers =
        _db.users.where((u) => u.registeredAt!.isAfter(since)).length;
    final scale = switch (period) {
      Period.week => 1.0,
      Period.month => 3.6,
      Period.year => 31.0,
    };
    return DashboardSummary(
      activeUsers: StatMetric(
        value: (45946 * (0.9 + scale / 60)).round(),
        changePct: 12.6,
      ),
      newRegistrations: StatMetric(
        value: (newUsers * 60 * scale).round(),
        changePct: -4.2,
      ),
      otpVerifiedPct: 42.9,
      advisoriesDelivered: StatMetric(
        value: (3421 * scale).round(),
        changePct: 9.6,
      ),
      upazilaCoverage: StatMetric(
        value: period == Period.week ? 412 : 468,
        changePct: 12.6,
      ),
      upazilaTotal: 495,
    );
  }

  @override
  Future<List<CropAdvisory>> fetchAdvisories({int limit = 5}) async {
    await MockStore.latency(400);
    return _db.advisories.take(limit).toList();
  }

  @override
  Future<CropAdvisory> setAdvisoryStatus(int id, AdvisoryStatus status) async {
    await MockStore.latency(350);
    final i = _db.advisories.indexWhere((a) => a.id == id);
    if (i < 0) throw const ApiException('That advisory no longer exists.');
    _db.advisories[i] = _db.advisories[i].copyWith(status: status);
    return _db.advisories[i];
  }

  @override
  Future<List<DataSource>> fetchDataSources() async {
    await MockStore.latency(300);
    return List.of(_db.sources);
  }

  @override
  Future<List<DataSource>> setDefaultSource(String id) async {
    await MockStore.latency(450);
    for (var i = 0; i < _db.sources.length; i++) {
      _db.sources[i] = _db.sources[i].copyWith(
        isDefault: _db.sources[i].id == id,
      );
    }
    return List.of(_db.sources);
  }
}
