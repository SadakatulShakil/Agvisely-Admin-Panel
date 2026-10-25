import '../core/network/json_utils.dart';

/// How much of a capability a role gets.
enum AccessLevel {
  full('full', 'Full'),
  ownModules('own_modules', 'Own modules'),
  region('region', 'Region'),
  ownUpazila('own_upazila', 'Own upazila'),
  none('none', 'No access');

  const AccessLevel(this.apiValue, this.label);
  final String apiValue;
  final String label;

  static AccessLevel parse(dynamic v) {
    final s = v?.toString();
    for (final l in AccessLevel.values) {
      if (l.apiValue == s) return l;
    }
    return AccessLevel.none;
  }
}

class RbacRole {
  const RbacRole({required this.key, required this.label});
  final String key;
  final String label;

  factory RbacRole.fromJson(Map<String, dynamic> j) =>
      RbacRole(key: Json.asString(j['key']), label: Json.asString(j['label']));
}

class RbacCapability {
  const RbacCapability({
    required this.key,
    required this.label,
    required this.options,
    this.lockedRoles = const {},
  });

  final String key;
  final String label;

  /// Levels that make sense for this capability.
  final List<AccessLevel> options;

  /// Roles whose level can't be changed here (e.g. admin on "manage users",
  /// so nobody locks themselves out).
  final Set<String> lockedRoles;

  factory RbacCapability.fromJson(Map<String, dynamic> j) {
    final opts =
        (j['options'] is List)
            ? (j['options'] as List).map(AccessLevel.parse).toList()
            : AccessLevel.values.toList();
    final locked =
        (j['lockedRoles'] is List)
            ? (j['lockedRoles'] as List).map((e) => e.toString()).toSet()
            : <String>{};
    return RbacCapability(
      key: Json.asString(j['key']),
      label: Json.asString(j['label']),
      options: opts,
      lockedRoles: locked,
    );
  }
}

/// Capability × role grid (`GET/PUT /admin/rbac`). Immutable — edits
/// return a new matrix.
class RbacMatrix {
  const RbacMatrix({
    required this.roles,
    required this.capabilities,
    required this.grants,
  });

  final List<RbacRole> roles;
  final List<RbacCapability> capabilities;

  /// capabilityKey → roleKey → level
  final Map<String, Map<String, AccessLevel>> grants;

  AccessLevel levelOf(String capability, String role) =>
      grants[capability]?[role] ?? AccessLevel.none;

  RbacMatrix withLevel(String capability, String role, AccessLevel level) {
    final next = {
      for (final e in grants.entries)
        e.key: Map<String, AccessLevel>.of(e.value),
    };
    (next[capability] ??= <String, AccessLevel>{})[role] = level;
    return RbacMatrix(roles: roles, capabilities: capabilities, grants: next);
  }

  bool sameGrantsAs(RbacMatrix other) {
    for (final c in capabilities) {
      for (final r in roles) {
        if (levelOf(c.key, r.key) != other.levelOf(c.key, r.key)) return false;
      }
    }
    return true;
  }

  Map<String, dynamic> grantsToJson() => {
    for (final c in capabilities)
      c.key: {for (final r in roles) r.key: levelOf(c.key, r.key).apiValue},
  };

  factory RbacMatrix.fromJson(Map<String, dynamic> j) {
    final grantsJson = Json.map(j['grants']);
    return RbacMatrix(
      roles: Json.list(j['roles']).map(RbacRole.fromJson).toList(),
      capabilities:
          Json.list(j['capabilities']).map(RbacCapability.fromJson).toList(),
      grants: {
        for (final e in grantsJson.entries)
          e.key: {
            for (final g in Json.map(e.value).entries)
              g.key: AccessLevel.parse(g.value),
          },
      },
    );
  }
}
