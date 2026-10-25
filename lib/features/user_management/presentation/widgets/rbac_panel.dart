import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_data_table.dart';
import '../../../../core/widgets/panel_card.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../models/rbac.dart';
import '../../domen/controllers/user_management_controller.dart';

/// Capability × role grid with a dropdown per cell. Changes are held as a
/// draft until "Save changes".
class RbacPanel extends StatelessWidget {
  const RbacPanel({super.key, required this.controller});
  final UserManagementController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dirty = controller.rbacDirty;
      final saving = controller.savingRbac.value;
      return PanelCard(
        title: 'Role-Based Access Control',
        subtitle: 'Capabilities per role. Applies to the app and admin panel.',
        trailing:
            dirty
                ? Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    TextButton(
                      onPressed: saving ? null : controller.discardRbac,
                      child: const Text('Discard'),
                    ),
                    FilledButton(
                      onPressed: saving ? null : controller.saveRbac,
                      child:
                          saving
                              ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Text('Save changes'),
                    ),
                  ],
                )
                : null,
        child: ResourceView<RbacMatrix>(
          resource: controller.rbac,
          onRetry: controller.loadRbac,
          placeholderHeight: 300,
          builder: (_) {
            final draft = controller.rbacDraft.value;
            if (draft == null) return const LoadingBlock(height: 300);
            return _table(draft);
          },
        ),
      );
    });
  }

  Widget _table(RbacMatrix m) {
    final columns = [
      const TableCol('Capability', flex: 24),
      for (var i = 0; i < m.roles.length; i++)
        TableCol(m.roles[i].label, flex: 10, alignEnd: i == m.roles.length - 1),
    ];
    return AppDataTable<RbacCapability>(
      columns: columns,
      rows: m.capabilities,
      minTableWidth: 820,
      rowKey: (c) => c.key,
      cellsBuilder:
          (cap) => [
            Text(
              cap.label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            for (final role in m.roles)
              _AccessDropdown(
                value: m.levelOf(cap.key, role.key),
                options: cap.options,
                locked: cap.lockedRoles.contains(role.key),
                changed: controller.isChanged(cap.key, role.key),
                onChanged:
                    (level) => controller.setAccess(cap.key, role.key, level),
              ),
          ],
    );
  }
}

class _AccessDropdown extends StatelessWidget {
  const _AccessDropdown({
    required this.value,
    required this.options,
    required this.locked,
    required this.changed,
    required this.onChanged,
  });

  final AccessLevel value;
  final List<AccessLevel> options;
  final bool locked;
  final bool changed;
  final ValueChanged<AccessLevel> onChanged;

  @override
  Widget build(BuildContext context) {
    final chip = Container(
      padding: const EdgeInsets.fromLTRB(6, 3, 4, 3),
      decoration: BoxDecoration(
        color: changed ? AppColors.warningBg : AppColors.chip,
        borderRadius: BorderRadius.circular(4),
        border:
            changed ? Border.all(color: AppColors.warning, width: 0.8) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value.label,
            style: TextStyle(
              fontSize: 15,
              color:
                  value == AccessLevel.none
                      ? AppColors.textSecondary
                      : AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            locked ? Icons.lock_outline : Icons.arrow_drop_down,
            size: locked ? 14 : 22,
            color: locked ? AppColors.textMuted : AppColors.leaf,
          ),
        ],
      ),
    );

    if (locked) {
      return Tooltip(
        message: 'Admins always keep this, so no one is locked out.',
        child: chip,
      );
    }

    return PopupMenuButton<AccessLevel>(
      tooltip: 'Change access',
      initialValue: value,
      onSelected: (l) {
        if (l != value) onChanged(l);
      },
      itemBuilder:
          (_) => [
            for (final o in options)
              PopupMenuItem<AccessLevel>(
                value: o,
                height: 40,
                child: Row(
                  children: [
                    SizedBox(
                      width: 22,
                      child:
                          o == value
                              ? const Icon(
                                Icons.check,
                                size: 16,
                                color: AppColors.primary,
                              )
                              : null,
                    ),
                    Text(o.label),
                  ],
                ),
              ),
          ],
      child: chip,
    );
  }
}
