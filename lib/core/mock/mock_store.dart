import 'dart:math';

import '../../models/admin_user.dart';
import '../../models/dashboard.dart';
import '../../models/rbac.dart';

/// In-memory data behind every `Mock*Repository`, so the panel is fully
/// clickable before the `/admin/*` API exists. Seeded deterministically;
/// changes (suspend, publish, add user, …) last until the tab reloads.
class MockStore {
  MockStore._() {
    _seed();
  }
  static final MockStore instance = MockStore._();

  static Future<void> latency([int ms = 450]) =>
      Future.delayed(Duration(milliseconds: ms));

  static const professions = <int, String>{
    1: 'Farmer',
    2: 'SAAO',
    3: 'DAE Official',
    4: 'Researcher',
    5: 'Finance',
    6: 'Insurance',
  };

  static const _roleByProfession = <int, String>{
    1: 'farmer',
    2: 'officer',
    3: 'officer',
    4: 'expert',
    5: 'expert',
    6: 'expert',
  };

  final List<AdminUser> users = [];
  final List<CropAdvisory> advisories = [];
  final List<DataSource> sources = [];
  late RbacMatrix rbac;
  int _nextUserId = 1;

  void _seed() {
    final rnd = Random(42);
    const first = [
      'Khairul',
      'Nasrin',
      'Abdul',
      'Shirin',
      'Rafiq',
      'Taslima',
      'Jahid',
      'Farzana',
      'Mizanur',
      'Sumaiya',
      'Habibur',
      'Rokeya',
      'Anisur',
      'Moushumi',
      'Sajib',
      'Ayesha',
      'Mahbub',
      'Nusrat',
      'Kamrul',
      'Shapla',
    ];
    const last = [
      'Islam',
      'Akter',
      'Rahman',
      'Hossain',
      'Ahmed',
      'Begum',
      'Uddin',
      'Khatun',
      'Sarker',
      'Mia',
      'Chowdhury',
      'Alam',
    ];
    const places = [
      'Pallabi, Mirpur, Dhaka',
      'Mymensingh Sadar, Mymensingh',
      'Gaibandha Sadar, Gaibandha',
      'Savar, Dhaka',
      'Dumuria, Khulna',
      'Paba, Rajshahi',
      'Companiganj, Sylhet',
      'Kaunia, Rangpur',
      'Bakerganj, Barishal',
      'Sitakunda, Chattogram',
      'Tarash, Sirajganj',
      'Chuadanga Sadar, Chuadanga',
      'Kalapara, Patuakhali',
    ];
    // Weighted toward farmers, like the real user base.
    const professionPool = [1, 1, 1, 1, 1, 1, 2, 2, 3, 3, 4, 5, 6];

    final now = DateTime.now();
    for (var i = 0; i < 180; i++) {
      final pid = professionPool[rnd.nextInt(professionPool.length)];
      final daysAgo =
          i < 45
              ? rnd.nextInt(7)
              : i < 100
              ? 7 + rnd.nextInt(23)
              : 30 + rnd.nextInt(335);
      users.add(
        AdminUser(
          id: _nextUserId++,
          name:
              '${first[rnd.nextInt(first.length)]} ${last[rnd.nextInt(last.length)]}',
          phone: '01${3 + rnd.nextInt(7)}${_digits(rnd, 8)}',
          profession: professions[pid]!,
          professionId: pid,
          role: _roleByProfession[pid]!,
          location: places[rnd.nextInt(places.length)],
          status:
              rnd.nextInt(100) < 82 ? UserStatus.active : UserStatus.inactive,
          registeredAt: now.subtract(
            Duration(days: daysAgo, hours: rnd.nextInt(24)),
          ),
        ),
      );
    }
    users.sort((a, b) => b.registeredAt!.compareTo(a.registeredAt!));

    const advisory = 'দুপুরে জমিতে ৫–৭ সেমি পানি ধরে রাখুন; সকালে সেচ দিন';
    final rows = <(String, String, String, String, AdvisoryStatus)>[
      (
        'Rice (Boro)',
        'Flowering',
        'Dhaka',
        'Tmax > 35°C',
        AdvisoryStatus.published,
      ),
      (
        'Rice (Boro)',
        'Flowering',
        'Khulna',
        'Tmax > 35°C',
        AdvisoryStatus.published,
      ),
      (
        'Rice (Boro)',
        'Flowering',
        'Mymensingh',
        'Tmax > 35°C',
        AdvisoryStatus.draft,
      ),
      (
        'Rice (Aman)',
        'Tillering',
        'Rangpur',
        'Rain > 50 mm',
        AdvisoryStatus.published,
      ),
      (
        'Wheat',
        'Grain filling',
        'Rajshahi',
        'Tmax > 32°C',
        AdvisoryStatus.published,
      ),
      (
        'Potato',
        'Tuber initiation',
        'Bogura',
        'RH > 90%',
        AdvisoryStatus.draft,
      ),
      (
        'Jute',
        'Vegetative',
        'Faridpur',
        'Rain < 5 mm/7d',
        AdvisoryStatus.suspended,
      ),
    ];
    for (var i = 0; i < rows.length; i++) {
      final r = rows[i];
      advisories.add(
        CropAdvisory(
          id: i + 1,
          crop: r.$1,
          stage: r.$2,
          area: r.$3,
          trigger: r.$4,
          advisory: advisory,
          status: r.$5,
        ),
      );
    }

    sources.addAll([
      DataSource(
        id: 'bmd',
        name: 'BMD',
        description: 'Bangladesh Meteorological Department · Primary',
        health: SourceHealth.operational,
        lastSyncAt: now.subtract(const Duration(minutes: 4)),
        uptime30d: 99.8,
        isDefault: true,
      ),
      DataSource(
        id: 'ukmo',
        name: 'UK Met Office',
        description: 'Global model · Upazila downscaling',
        health: SourceHealth.operational,
        lastSyncAt: now.subtract(const Duration(minutes: 12)),
        uptime30d: 99.6,
        isDefault: false,
      ),
      DataSource(
        id: 'ecmwf',
        name: 'ECMWF',
        description: 'Sub-seasonal · Integration in progress',
        health: SourceHealth.degraded,
        lastSyncAt: now.subtract(const Duration(hours: 1, minutes: 29)),
        uptime30d: 97.2,
        isDefault: false,
      ),
      DataSource(
        id: 'union-pilot',
        name: 'Union Downscaling (Pilot)',
        description: 'Experimental · 10-day lead time',
        health: SourceHealth.pilot,
        lastSyncAt: now.subtract(const Duration(minutes: 25)),
        uptime30d: 94.1,
        isDefault: false,
      ),
    ]);

    const allLevels = AccessLevel.values;
    const roles = [
      RbacRole(key: 'admin', label: 'Admin'),
      RbacRole(key: 'expert', label: 'Expert'),
      RbacRole(key: 'officer', label: 'Officer'),
      RbacRole(key: 'farmer', label: 'Farmer'),
    ];
    rbac = const RbacMatrix(
      roles: roles,
      capabilities: const [
        RbacCapability(
          key: 'view_forecasts',
          label: 'View forecasts & advisories',
          options: [
            AccessLevel.full,
            AccessLevel.region,
            AccessLevel.ownUpazila,
            AccessLevel.none,
          ],
        ),
        RbacCapability(
          key: 'edit_cms',
          label: 'Edit advisory content (CMS)',
          options: [AccessLevel.full, AccessLevel.ownModules, AccessLevel.none],
        ),
        RbacCapability(
          key: 'upload_bulletins',
          label: 'Upload disease bulletins',
          options: [AccessLevel.full, AccessLevel.region, AccessLevel.none],
        ),
        RbacCapability(
          key: 'send_push',
          label: 'Send push notifications',
          options: allLevels,
        ),
        RbacCapability(
          key: 'manage_users',
          label: 'Manage users & roles',
          options: [AccessLevel.full, AccessLevel.none],
          lockedRoles: {'admin'},
        ),
      ],
      grants: {
        'view_forecasts': {
          'admin': AccessLevel.full,
          'expert': AccessLevel.full,
          'officer': AccessLevel.full,
          'farmer': AccessLevel.full,
        },
        'edit_cms': {
          'admin': AccessLevel.full,
          'expert': AccessLevel.ownModules,
          'officer': AccessLevel.none,
          'farmer': AccessLevel.none,
        },
        'upload_bulletins': {
          'admin': AccessLevel.full,
          'expert': AccessLevel.full,
          'officer': AccessLevel.none,
          'farmer': AccessLevel.none,
        },
        'send_push': {
          'admin': AccessLevel.full,
          'expert': AccessLevel.region,
          'officer': AccessLevel.ownUpazila,
          'farmer': AccessLevel.none,
        },
        'manage_users': {
          'admin': AccessLevel.full,
          'expert': AccessLevel.none,
          'officer': AccessLevel.none,
          'farmer': AccessLevel.none,
        },
      },
    );
  }

  static String _digits(Random rnd, int n) =>
      List.generate(n, (_) => rnd.nextInt(10)).join();

  int nextUserId() => _nextUserId++;
}
