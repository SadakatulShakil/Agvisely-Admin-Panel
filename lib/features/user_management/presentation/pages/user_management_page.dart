import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/admin_shell.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/period_selector.dart';
import '../../domen/controllers/user_management_controller.dart';
import '../widgets/rbac_panel.dart';
import '../widgets/search_field.dart';
import '../widgets/users_panel.dart';

class UserManagementPage extends GetView<UserManagementController> {
  const UserManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mobile = context.isMobileLayout;
    return AdminShell(
      currentRoute: AppRoutes.users,
      title: 'User Management',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: 'User Management',
            subtitle: 'People using Agvisely and what each role can do',
            actions: [
              SearchField(
                controller: controller.searchCtrl,
                onChanged: controller.onSearchChanged,
                onClear: controller.clearSearch,
                hint: 'Search name, mobile, place',
                width: mobile ? context.screenWidth - 32 : 240,
              ),
              Obx(
                () => PeriodSelector(
                  value: controller.period.value,
                  onChanged: (p) => controller.period.value = p,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          UsersPanel(controller: controller),
          const SizedBox(height: 16),
          RbacPanel(controller: controller),
        ],
      ),
    );
  }
}
