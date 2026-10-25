import 'package:flutter/material.dart';

import '../../models/period.dart';
import '../theme/app_colors.dart';

/// "07 Days | 30 Days | 01 Year" switch.
class PeriodSelector extends StatelessWidget {
  const PeriodSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final Period value;
  final ValueChanged<Period> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final p in Period.values)
            Semantics(
              selected: p == value,
              button: true,
              child: Material(
                color: p == value ? AppColors.primarySoft : Colors.transparent,
                child: InkWell(
                  onTap: p == value ? null : () => onChanged(p),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Center(
                      child: Text(
                        p.label,
                        style: TextStyle(
                          fontSize: 15,
                          color:
                              p == value
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
