import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../models/user_directory.dart';

/// "All-54,738  Farmer-3,487  SAAO-…" filter tabs with an underline on
/// the selected one. Scrolls sideways on narrow screens.
class ProfessionTabs extends StatelessWidget {
  const ProfessionTabs({
    super.key,
    required this.totalAll,
    required this.professions,
    required this.selectedId,
    required this.onSelected,
  });

  final int totalAll;
  final List<ProfessionCount> professions;
  final int? selectedId;
  final ValueChanged<int?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _Tab(
            label: 'All',
            count: totalAll,
            selected: selectedId == null,
            onTap: () => onSelected(null),
          ),
          for (final p in professions)
            _Tab(
              label: p.name,
              count: p.count,
              selected: selectedId == p.id,
              onTap: () => onSelected(p.id),
            ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textMuted;
    return Padding(
      padding: const EdgeInsets.only(right: 32),
      child: Semantics(
        selected: selected,
        button: true,
        child: InkWell(
          onTap: selected ? null : onTap,
          child: Container(
            padding: const EdgeInsets.only(bottom: 6, top: 4),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: selected ? AppColors.primary : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            child: Text.rich(
              TextSpan(
                text: '$label-',
                children: [
                  TextSpan(
                    text: Fmt.number(count),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              style: TextStyle(fontSize: 16, color: color),
            ),
          ),
        ),
      ),
    );
  }
}
