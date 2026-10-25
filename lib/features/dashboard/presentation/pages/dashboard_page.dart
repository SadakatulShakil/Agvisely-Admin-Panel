import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/admin_shell.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/period_selector.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../models/dashboard.dart';
import '../../domen/controllers/dashboard_controller.dart';
import '../widgets/crop_advisory_card.dart';
import '../widgets/data_source_card.dart';
import '../widgets/recent_users_card.dart';
import '../widgets/system_analytics_card.dart';

class DashboardPage extends GetView<DashboardController> {
  const DashboardPage({super.key});

  static const double _gap = 16;

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      currentRoute: AppRoutes.dashboard,
      title: 'Overview',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: 'Overview',
            subtitle: 'Analytics and overview of the system',
            actions: [
              Obx(
                () => PeriodSelector(
                  value: controller.period.value,
                  onChanged: (p) => controller.period.value = p,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _topRow(context),
          const SizedBox(height: _gap),
          CropAdvisoryCard(controller: controller),
          const SizedBox(height: _gap),
          _sources(),
        ],
      ),
    );
  }

  Widget _topRow(BuildContext context) {
    final analytics = SystemAnalyticsCard(controller: controller);
    final users = RecentUsersCard(controller: controller);
    if (!context.isWideLayout) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [analytics, const SizedBox(height: _gap), users],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 10, child: analytics),
        const SizedBox(width: _gap),
        Expanded(flex: 12, child: users),
      ],
    );
  }

  Widget _sources() {
    return ResourceView<List<DataSource>>(
      resource: controller.sources,
      onRetry: controller.loadSources,
      placeholderHeight: 240,
      builder:
          (list) => LayoutBuilder(
            builder: (context, c) {
              final perRow =
                  c.maxWidth >= 1100
                      ? 4
                      : c.maxWidth >= 560
                      ? 2
                      : 1;
              final width =
                  ((c.maxWidth - _gap * (perRow - 1)) / perRow).floorToDouble();
              return Obx(() {
                final busy = controller.busy.toSet();
                return Wrap(
                  spacing: _gap,
                  runSpacing: _gap,
                  children: [
                    for (final s in list)
                      SizedBox(
                        width: width,
                        child: DataSourceCard(
                          source: s,
                          busy: busy.contains('src-${s.id}'),
                          onMakeDefault: () => controller.makeDefault(s),
                        ),
                      ),
                  ],
                );
              });
            },
          ),
    );
  }
}
