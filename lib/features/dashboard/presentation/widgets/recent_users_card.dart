import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_data_table.dart';
import '../../../../core/widgets/panel_card.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/widgets/status_widgets.dart';
import '../../../../models/admin_user.dart';
import '../../../user_management/presentation/widgets/user_status_dot.dart';
import '../../domen/controllers/dashboard_controller.dart';

class RecentUsersCard extends StatelessWidget {
  const RecentUsersCard({super.key, required this.controller});
  final DashboardController controller;

  static const _columns = [
    TableCol('Name', flex: 13),
    TableCol('Mobile', flex: 11),
    TableCol('Profession', flex: 11),
    TableCol('Location', flex: 14),
    TableCol('Status', flex: 9),
    TableCol('Action', flex: 8),
  ];

  @override
  Widget build(BuildContext context) {
    return PanelCard(
      title: 'User Management',
      trailing: ViewDetailsButton(onPressed: controller.openUsers),
      child: ResourceView<List<AdminUser>>(
        resource: controller.recentUsers,
        onRetry: controller.loadRecentUsers,
        placeholderHeight: 320,
        builder:
            (users) => Obx(() {
              // Rebuild on busy changes.
              final busy = controller.busy.toSet();
              return AppDataTable<AdminUser>(
                columns: _columns,
                rows: users,
                minTableWidth: 760,
                rowKey: (u) => u.id,
                emptyMessage: 'No one registered in this period.',
                cellsBuilder:
                    (u) => [
                      CellText(u.name),
                      CellText(u.phone),
                      Pill(label: u.profession),
                      CellText(u.location),
                      UserStatusDot(user: u),
                      _action(u, busy.contains('user-${u.id}')),
                    ],
                mobileCardBuilder:
                    (u) => _mobileCard(u, busy.contains('user-${u.id}')),
              );
            }),
      ),
    );
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
      const SizedBox(height: 8),
      Align(alignment: Alignment.centerRight, child: _action(u, busy)),
    ],
  );
}
