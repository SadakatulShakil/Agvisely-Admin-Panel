import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_data_table.dart';
import '../../../../core/widgets/panel_card.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/widgets/status_widgets.dart';
import '../../../../models/admin_user.dart';
import '../../../../models/user_directory.dart';
import '../../domen/controllers/user_management_controller.dart';
import 'add_user_dialog.dart';
import 'pagination_bar.dart';
import 'profession_tabs.dart';
import 'user_status_dot.dart';

class UsersPanel extends StatelessWidget {
  const UsersPanel({super.key, required this.controller});
  final UserManagementController controller;

  static const _columns = [
    TableCol('Name', flex: 13),
    TableCol('Mobile', flex: 11),
    TableCol('Profession', flex: 11),
    TableCol('Location', flex: 15),
    TableCol('Registered', flex: 10),
    TableCol('Status', flex: 9),
    TableCol('Action', flex: 8, alignEnd: true),
  ];

  @override
  Widget build(BuildContext context) {
    final mobile = context.isMobileLayout;
    return PanelCard(
      title: 'Users',
      trailing: FilledButton.icon(
        onPressed: () => showAddUserDialog(controller),
        icon: const Icon(Icons.add, size: 20),
        label: Text(mobile ? 'Add user' : 'Add New User'),
      ),
      child: ResourceView<UserDirectoryPage>(
        resource: controller.directory,
        onRetry: controller.loadUsers,
        placeholderHeight: 420,
        builder:
            (page) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Obx(
                  () => ProfessionTabs(
                    totalAll: page.totalAll,
                    professions: page.professions,
                    selectedId: controller.professionId.value,
                    onSelected: controller.selectProfession,
                  ),
                ),
                const SizedBox(height: 12),
                Obx(() {
                  final busy = controller.busy.toSet();
                  return AppDataTable<AdminUser>(
                    columns: _columns,
                    rows: page.users.items,
                    minTableWidth: 980,
                    rowKey: (u) => u.id,
                    emptyMessage: _emptyMessage(),
                    cellsBuilder:
                        (u) => [
                          CellText(u.name),
                          CellText(u.phone),
                          Pill(label: u.profession),
                          CellText(u.location),
                          CellText(Fmt.shortDate(u.registeredAt)),
                          UserStatusDot(user: u),
                          _action(u, busy.contains(u.id)),
                        ],
                    mobileCardBuilder:
                        (u) => _mobileCard(u, busy.contains(u.id)),
                  );
                }),
                PaginationBar(page: page.users, onPage: controller.goToPage),
              ],
            ),
      ),
    );
  }

  String _emptyMessage() {
    final term = controller.search.value.trim();
    return term.isEmpty
        ? 'No one registered in this period. Try a longer period.'
        : 'No users match “$term”. Check the spelling or search by mobile number.';
  }

  Widget _action(AdminUser u, bool busy) => LinkAction(
    label: u.isActive ? 'Suspend' : 'Restore',
    busy: busy,
    onPressed: () => controller.toggleUser(u),
  );

  Widget _mobileCard(AdminUser u, bool busy) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              u.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          UserStatusDot(user: u),
        ],
      ),
      const SizedBox(height: 2),
      Text(u.phone, style: const TextStyle(color: AppColors.textSecondary)),
      CardField(label: 'Profession', child: Pill(label: u.profession)),
      CardField(label: 'Location', child: CellText(u.location)),
      CardField(
        label: 'Registered',
        child: CellText(Fmt.shortDate(u.registeredAt)),
      ),
      const SizedBox(height: 8),
      Align(alignment: Alignment.centerRight, child: _action(u, busy)),
    ],
  );
}
