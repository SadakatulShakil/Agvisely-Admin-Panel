import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/resource.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../models/admin_user.dart';
import '../../../../models/period.dart';
import '../../../../models/rbac.dart';
import '../../../../models/user_directory.dart';
import '../../data/user_repository.dart';
import '../user_status_action.dart';

class UserManagementController extends GetxController {
  UserManagementController(this._repo);
  final UserRepository _repo;

  // ── Directory filters ───────────────────────────────────────────────────
  final period = Period.week.obs;
  final search = ''.obs;
  final searchCtrl = TextEditingController();

  /// null = "All" tab.
  final professionId = Rxn<int>();
  int _page = 1;

  final directory = Resource<UserDirectoryPage>();
  final busy = <int>{}.obs;

  // ── Roles & permissions ─────────────────────────────────────────────────
  final rbac = Resource<RbacMatrix>();
  final rbacDraft = Rxn<RbacMatrix>();
  final savingRbac = false.obs;

  bool get rbacDirty {
    final saved = rbac.data.value;
    final draft = rbacDraft.value;
    return saved != null && draft != null && !draft.sameGrantsAs(saved);
  }

  /// Known professions (from the tab counts) for the add-user form.
  List<ProfessionCount> get professions =>
      directory.data.value?.professions ?? const [];

  @override
  void onInit() {
    super.onInit();
    debounce<String>(
      search,
      (_) => _reload(),
      time: const Duration(milliseconds: 400),
    );
    ever<Period>(period, (_) => _reload());
    ever<int?>(professionId, (_) => _reload());
    loadUsers();
    loadRbac();
  }

  // ── Directory ───────────────────────────────────────────────────────────

  void _reload() {
    _page = 1;
    loadUsers();
  }

  Future<void> loadUsers() => directory.load(
    () => _repo.fetchUsers(
      UserQuery(
        page: _page,
        limit: AppConfig.defaultPageSize,
        search: search.value,
        professionId: professionId.value,
        period: period.value,
      ),
    ),
  );

  void goToPage(int page) {
    if (page < 1 || page == _page) return;
    _page = page;
    loadUsers();
  }

  void selectProfession(int? id) => professionId.value = id;

  void onSearchChanged(String value) => search.value = value;

  void clearSearch() {
    searchCtrl.clear();
    search.value = '';
  }

  Future<void> toggleUser(AdminUser user) async {
    if (busy.contains(user.id)) return;
    busy.add(user.id);
    final updated = await toggleUserStatus(_repo, user);
    busy.remove(user.id);
    if (updated != null) directory.patch((p) => p.replaceUser(updated));
  }

  /// Returns null on success, or an error message for the form.
  Future<String?> createUser(CreateUserRequest request) async {
    try {
      final user = await _repo.createUser(request);
      AppToast.success('${user.name} is added.');
      // Newest first: show them at the top of the first page.
      clearSearch();
      professionId.value = null;
      _reload();
      return null;
    } catch (e) {
      return ApiException.messageOf(e);
    }
  }

  // ── Roles & permissions ─────────────────────────────────────────────────

  Future<void> loadRbac() async {
    final applied = await rbac.load(_repo.fetchRbac);
    if (applied) rbacDraft.value = rbac.data.value;
  }

  void setAccess(String capability, String role, AccessLevel level) {
    final draft = rbacDraft.value;
    if (draft == null) return;
    rbacDraft.value = draft.withLevel(capability, role, level);
  }

  bool isChanged(String capability, String role) {
    final saved = rbac.data.value;
    final draft = rbacDraft.value;
    if (saved == null || draft == null) return false;
    return saved.levelOf(capability, role) != draft.levelOf(capability, role);
  }

  void discardRbac() => rbacDraft.value = rbac.data.value;

  Future<void> saveRbac() async {
    final draft = rbacDraft.value;
    if (draft == null || !rbacDirty || savingRbac.value) return;
    final ok = await showConfirmDialog(
      title: 'Save access changes?',
      message:
          'New permissions apply to the app and admin panel the next time each person signs in.',
      confirmLabel: 'Save changes',
    );
    if (!ok) return;

    savingRbac.value = true;
    try {
      final saved = await _repo.saveRbac(draft);
      rbac.data.value = saved;
      rbacDraft.value = saved;
      AppToast.success('Access changes saved.');
    } catch (e) {
      AppToast.error(ApiException.messageOf(e));
    } finally {
      savingRbac.value = false;
    }
  }

  @override
  void onClose() {
    searchCtrl.dispose();
    super.onClose();
  }
}
