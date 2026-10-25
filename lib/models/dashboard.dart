import '../core/network/json_utils.dart';

/// A headline number with its change against the previous period.
class StatMetric {
  const StatMetric({required this.value, required this.changePct});

  final int value;

  /// Signed percentage, e.g. 12.6 or -4.1.
  final double changePct;

  factory StatMetric.fromJson(dynamic j) {
    final m = Json.map(j);
    return StatMetric(
      value: Json.asInt(m['value']),
      changePct: Json.asDouble(m['changePct']),
    );
  }
}

/// `GET /admin/dashboard/summary?period=`
class DashboardSummary {
  const DashboardSummary({
    required this.activeUsers,
    required this.newRegistrations,
    required this.otpVerifiedPct,
    required this.advisoriesDelivered,
    required this.upazilaCoverage,
    required this.upazilaTotal,
  });

  final StatMetric activeUsers;
  final StatMetric newRegistrations;

  /// Share of new registrations that completed OTP verification.
  final double otpVerifiedPct;
  final StatMetric advisoriesDelivered;
  final StatMetric upazilaCoverage;
  final int upazilaTotal;

  factory DashboardSummary.fromJson(Map<String, dynamic> j) => DashboardSummary(
    activeUsers: StatMetric.fromJson(j['activeUsers']),
    newRegistrations: StatMetric.fromJson(j['newRegistrations']),
    otpVerifiedPct: Json.asDouble(
      Json.map(j['newRegistrations'])['otpVerifiedPct'],
    ),
    advisoriesDelivered: StatMetric.fromJson(j['advisoriesDelivered']),
    upazilaCoverage: StatMetric.fromJson(j['upazilaCoverage']),
    upazilaTotal: Json.asInt(Json.map(j['upazilaCoverage'])['total'], 495),
  );
}

enum AdvisoryStatus {
  published('published', 'Published'),
  draft('draft', 'Draft'),
  suspended('suspended', 'Suspended');

  const AdvisoryStatus(this.apiValue, this.label);
  final String apiValue;
  final String label;

  static AdvisoryStatus parse(dynamic v) {
    for (final s in AdvisoryStatus.values) {
      if (s.apiValue == v?.toString().toLowerCase()) return s;
    }
    return AdvisoryStatus.draft;
  }
}

/// A weather-triggered crop advisory rule (`GET /admin/advisories`).
class CropAdvisory {
  const CropAdvisory({
    required this.id,
    required this.crop,
    required this.stage,
    required this.area,
    required this.trigger,
    required this.advisory,
    required this.status,
  });

  final int id;
  final String crop;
  final String stage;
  final String area;
  final String trigger;
  final String advisory;
  final AdvisoryStatus status;

  CropAdvisory copyWith({AdvisoryStatus? status}) => CropAdvisory(
    id: id,
    crop: crop,
    stage: stage,
    area: area,
    trigger: trigger,
    advisory: advisory,
    status: status ?? this.status,
  );

  factory CropAdvisory.fromJson(Map<String, dynamic> j) => CropAdvisory(
    id: Json.asInt(j['id']),
    crop: Json.asString(j['crop'] ?? j['name']),
    stage: Json.asString(j['stage']),
    area: Json.asString(j['area']),
    trigger: Json.asString(j['trigger']),
    advisory: Json.asString(j['advisory']),
    status: AdvisoryStatus.parse(j['status']),
  );
}

enum SourceHealth {
  operational('operational', 'Operational'),
  degraded('degraded', 'Degraded'),
  pilot('pilot', 'Pilot'),
  down('down', 'Down');

  const SourceHealth(this.apiValue, this.label);
  final String apiValue;
  final String label;

  static SourceHealth parse(dynamic v) {
    for (final s in SourceHealth.values) {
      if (s.apiValue == v?.toString().toLowerCase()) return s;
    }
    return SourceHealth.operational;
  }
}

/// A forecast provider the app can read from (`GET /admin/data-sources`).
class DataSource {
  const DataSource({
    required this.id,
    required this.name,
    required this.description,
    required this.health,
    required this.lastSyncAt,
    required this.uptime30d,
    required this.isDefault,
  });

  final String id;
  final String name;
  final String description;
  final SourceHealth health;
  final DateTime? lastSyncAt;
  final double uptime30d;
  final bool isDefault;

  DataSource copyWith({bool? isDefault}) => DataSource(
    id: id,
    name: name,
    description: description,
    health: health,
    lastSyncAt: lastSyncAt,
    uptime30d: uptime30d,
    isDefault: isDefault ?? this.isDefault,
  );

  factory DataSource.fromJson(Map<String, dynamic> j) => DataSource(
    id: Json.asString(j['id']),
    name: Json.asString(j['name']),
    description: Json.asString(j['description']),
    health: SourceHealth.parse(j['status']),
    lastSyncAt: Json.asDate(j['lastSyncAt']),
    uptime30d: Json.asDouble(j['uptime30d']),
    isDefault: j['isDefault'] == true,
  );
}
