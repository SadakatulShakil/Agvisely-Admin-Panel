import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/panel_card.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../models/dashboard.dart';
import '../../domen/controllers/dashboard_controller.dart';
import 'stat_card.dart';

class SystemAnalyticsCard extends StatelessWidget {
  const SystemAnalyticsCard({super.key, required this.controller});
  final DashboardController controller;

  /// Below this share of verified sign-ups the rate shows as a warning.
  static const double otpHealthyPct = 60;

  @override
  Widget build(BuildContext context) {
    return PanelCard(
      title: 'System Analytics',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ResourceView<DashboardSummary>(
          resource: controller.summary,
          onRetry: controller.loadSummary,
          placeholderHeight: 340,
          builder: (s) => _grid(s),
        ),
      ),
    );
  }

  Widget _grid(DashboardSummary s) {
    const vsPrev = 'vs previous period';
    final cards = [
      StatCard(
        icon: Icons.people_outline,
        label: 'Active users',
        value: s.activeUsers.value,
        changePct: s.activeUsers.changePct,
        changeLabel: vsPrev,
        gradient: AppColors.tintGreen,
        borderColor: AppColors.tintGreenBorder,
      ),
      StatCard(
        icon: Icons.add,
        label: 'New registrations',
        value: s.newRegistrations.value,
        // This card reports the OTP completion rate, not a trend.
        changePct: s.otpVerifiedPct,
        positive: s.otpVerifiedPct >= otpHealthyPct,
        changeLabel: 'OTP verified',
        gradient: AppColors.tintTeal,
        borderColor: AppColors.tintTealBorder,
      ),
      StatCard(
        icon: Icons.description_outlined,
        label: 'Advisories delivered',
        value: s.advisoriesDelivered.value,
        changePct: s.advisoriesDelivered.changePct,
        changeLabel: vsPrev,
        gradient: AppColors.tintPeach,
        borderColor: AppColors.tintPeachBorder,
      ),
      StatCard(
        icon: Icons.location_on_outlined,
        label: 'Upazila coverage',
        value: s.upazilaCoverage.value,
        valueSuffix: 'of ${s.upazilaTotal}',
        changePct: s.upazilaCoverage.changePct,
        changeLabel: vsPrev,
        gradient: AppColors.tintLilac,
        borderColor: AppColors.tintLilacBorder,
      ),
    ];

    return LayoutBuilder(
      builder: (context, c) {
        final twoUp = c.maxWidth >= 520;
        if (!twoUp) {
          return Column(
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                if (i > 0) const SizedBox(height: 16),
                cards[i],
              ],
            ],
          );
        }
        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: cards[0]),
                const SizedBox(width: 16),
                Expanded(child: cards[1]),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: cards[2]),
                const SizedBox(width: 16),
                Expanded(child: cards[3]),
              ],
            ),
          ],
        );
      },
    );
  }
}
