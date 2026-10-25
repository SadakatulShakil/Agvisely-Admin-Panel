import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_data_table.dart';
import '../../../../core/widgets/panel_card.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/widgets/status_widgets.dart';
import '../../../../models/dashboard.dart';
import '../../domen/controllers/dashboard_controller.dart';

class CropAdvisoryCard extends StatelessWidget {
  const CropAdvisoryCard({super.key, required this.controller});
  final DashboardController controller;

  static const _columns = [
    TableCol('Name', flex: 11),
    TableCol('Stage', flex: 9),
    TableCol('Area', flex: 11),
    TableCol('Trigger', flex: 13),
    TableCol('Advisory', flex: 28),
    TableCol('Status', flex: 10),
    TableCol('Action', flex: 9),
  ];

  @override
  Widget build(BuildContext context) {
    return PanelCard(
      title: 'Crop Advisory',
      trailing: ViewDetailsButton(onPressed: controller.openContent),
      child: ResourceView<List<CropAdvisory>>(
        resource: controller.advisories,
        onRetry: controller.loadAdvisories,
        placeholderHeight: 320,
        builder:
            (rows) => Obx(() {
              final busy = controller.busy.toSet();
              return AppDataTable<CropAdvisory>(
                columns: _columns,
                rows: rows,
                minTableWidth: 1120,
                rowMinHeight: 62,
                rowKey: (a) => a.id,
                emptyMessage:
                    'No crop advisories yet. Add them in Content (CMS).',
                cellsBuilder:
                    (a) => [
                      CellText(a.crop),
                      CellText(a.stage),
                      CellText(a.area),
                      TriggerPill(a.trigger),
                      CellText(a.advisory),
                      AdvisoryStatusPill(a.status),
                      _actions(a, busy.contains('adv-${a.id}')),
                    ],
                mobileCardBuilder:
                    (a) => _mobileCard(a, busy.contains('adv-${a.id}')),
              );
            }),
      ),
    );
  }

  Widget _actions(CropAdvisory a, bool busy) {
    final publish = a.status != AdvisoryStatus.published;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _EditButton(onPressed: () => controller.editAdvisory(a)),
        const SizedBox(width: 14),
        LinkAction(
          label: publish ? 'Publish' : 'Suspend',
          busy: busy,
          onPressed: () => controller.toggleAdvisory(a),
        ),
      ],
    );
  }

  Widget _mobileCard(CropAdvisory a, bool busy) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              '${a.crop} · ${a.stage}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          AdvisoryStatusPill(a.status),
        ],
      ),
      CardField(label: 'Area', child: CellText(a.area)),
      CardField(label: 'Trigger', child: TriggerPill(a.trigger)),
      const SizedBox(height: 10),
      Text(a.advisory, style: const TextStyle(fontSize: 15, height: 1.4)),
      const SizedBox(height: 10),
      Align(alignment: Alignment.centerRight, child: _actions(a, busy)),
    ],
  );
}

class _EditButton extends StatelessWidget {
  const _EditButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 30),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        side: const BorderSide(color: AppColors.textPrimary, width: 0.8),
        foregroundColor: AppColors.textPrimary,
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      child: const Text('Edit'),
    );
  }
}

class TriggerPill extends StatelessWidget {
  const TriggerPill(this.trigger, {super.key});
  final String trigger;

  @override
  Widget build(BuildContext context) => Pill(
    label: trigger,
    background: AppColors.dangerBg,
    foreground: AppColors.danger,
    radius: 4,
  );
}

class AdvisoryStatusPill extends StatelessWidget {
  const AdvisoryStatusPill(this.status, {super.key});
  final AdvisoryStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      AdvisoryStatus.published => (AppColors.successBg, AppColors.success),
      AdvisoryStatus.draft => (AppColors.warningBg, AppColors.warning),
      AdvisoryStatus.suspended => (AppColors.chip, AppColors.textSecondary),
    };
    return Pill(label: status.label, background: bg, foreground: fg, radius: 4);
  }
}
