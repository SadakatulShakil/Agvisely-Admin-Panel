import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/resource.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../models/admin_user.dart';
import '../../../../models/dashboard.dart';
import '../../../../models/period.dart';
import '../../../../models/user_directory.dart';
import '../../../user_management/data/user_repository.dart';
import '../../../user_management/domen/user_status_action.dart';
import '../../data/dashboard_repository.dart';

class DashboardController extends GetxController {
  DashboardController(this._dashboard, this._users);

  final DashboardRepository _dashboard;
  final UserRepository _users;

  static const int previewRows = 5;

  final period = Period.week.obs;

  final summary = Resource<DashboardSummary>();
  final recentUsers = Resource<List<AdminUser>>();
  final advisories = Resource<List<CropAdvisory>>();
  final sources = Resource<List<DataSource>>();

  /// Row ids with an action in flight (user ids, advisory ids, source ids).
  final busy = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    ever<Period>(period, (_) {
      loadSummary();
      loadRecentUsers();
    });
    refreshAll();
  }

  void refreshAll() {
    loadSummary();
    loadRecentUsers();
    loadAdvisories();
    loadSources();
  }

  Future<void> loadSummary() =>
      summary.load(() => _dashboard.fetchSummary(period.value));

  Future<void> loadRecentUsers() => recentUsers.load(() async {
    final page = await _users.fetchUsers(
      UserQuery(limit: previewRows, period: period.value),
    );
    return page.users.items;
  });

  Future<void> loadAdvisories() =>
      advisories.load(() => _dashboard.fetchAdvisories(limit: previewRows));

  Future<void> loadSources() => sources.load(_dashboard.fetchDataSources);

  // ── Users ───────────────────────────────────────────────────────────────

  Future<void> toggleUser(AdminUser user) async {
    final key = 'user-${user.id}';
    if (busy.contains(key)) return;
    busy.add(key);
    final updated = await toggleUserStatus(_users, user);
    busy.remove(key);
    if (updated != null) {
      recentUsers.patch(
        (list) => [for (final u in list) u.id == updated.id ? updated : u],
      );
    }
  }

  void openUsers() => Get.toNamed(AppRoutes.users);

  // ── Advisories ──────────────────────────────────────────────────────────

  Future<void> toggleAdvisory(CropAdvisory a) async {
    final key = 'adv-${a.id}';
    if (busy.contains(key)) return;
    final publish = a.status != AdvisoryStatus.published;
    final ok = await showConfirmDialog(
      title: publish ? 'Publish this advisory?' : 'Suspend this advisory?',
      message:
          publish
              ? '${a.crop} · ${a.stage} · ${a.area} will start reaching farmers when “${a.trigger}” is forecast.'
              : '${a.crop} · ${a.stage} · ${a.area} will stop reaching farmers until you publish it again.',
      confirmLabel: publish ? 'Publish' : 'Suspend',
      destructive: !publish,
    );
    if (!ok) return;

    busy.add(key);
    try {
      final updated = await _dashboard.setAdvisoryStatus(
        a.id,
        publish ? AdvisoryStatus.published : AdvisoryStatus.suspended,
      );
      advisories.patch(
        (list) => [for (final x in list) x.id == updated.id ? updated : x],
      );
      AppToast.success(publish ? 'Advisory published.' : 'Advisory suspended.');
    } catch (e) {
      AppToast.error(ApiException.messageOf(e));
    } finally {
      busy.remove(key);
    }
  }

  /// Editing lives in Content (CMS), the next module to be built.
  void editAdvisory(CropAdvisory a) => Get.toNamed(AppRoutes.content);

  void openContent() => Get.toNamed(AppRoutes.content);

  // ── Data sources ────────────────────────────────────────────────────────

  Future<void> makeDefault(DataSource s) async {
    final key = 'src-${s.id}';
    if (busy.contains(key) || s.isDefault) return;
    final ok = await showConfirmDialog(
      title: 'Use ${s.name} in the app?',
      message:
          s.health == SourceHealth.operational
              ? 'Every forecast and advisory in the Agvisely app will come from ${s.name}.'
              : '${s.name} is marked ${s.health.label.toLowerCase()}. Every forecast and advisory in the Agvisely app will come from it.',
      confirmLabel: 'Set as default',
    );
    if (!ok) return;

    busy.add(key);
    try {
      final list = await _dashboard.setDefaultSource(s.id);
      sources.data.value = list;
      AppToast.success('${s.name} is now the app’s default source.');
    } catch (e) {
      AppToast.error(ApiException.messageOf(e));
    } finally {
      busy.remove(key);
    }
  }
}
