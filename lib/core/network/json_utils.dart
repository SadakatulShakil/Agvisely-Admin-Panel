/// Defensive JSON readers — the backend sometimes sends numbers as
/// strings, and a single malformed field should not crash a whole page.
class Json {
  Json._();

  /// The `data` field of the standard `{success, message, data}` envelope.
  static dynamic data(dynamic response) =>
      response is Map ? response['data'] : null;

  static Map<String, dynamic> map(dynamic v) =>
      v is Map ? v.cast<String, dynamic>() : <String, dynamic>{};

  static List<Map<String, dynamic>> list(dynamic v) =>
      v is List
          ? v.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList()
          : <Map<String, dynamic>>[];

  static int asInt(dynamic v, [int fallback = 0]) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? fallback;
    return fallback;
  }

  static int? asIntOrNull(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  static double asDouble(dynamic v, [double fallback = 0]) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? fallback;
    return fallback;
  }

  static String asString(dynamic v, [String fallback = '']) =>
      v == null ? fallback : v.toString();

  static DateTime? asDate(dynamic v) {
    if (v is String && v.isNotEmpty) return DateTime.tryParse(v)?.toLocal();
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    return null;
  }
}
