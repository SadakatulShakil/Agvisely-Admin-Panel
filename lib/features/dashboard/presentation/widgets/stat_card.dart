import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';

/// Tinted headline-number card (Active users, New registrations, …).
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.changePct,
    required this.changeLabel,
    required this.gradient,
    required this.borderColor,
    this.valueSuffix,
    this.positive,
  });

  final IconData icon;
  final String label;
  final int value;

  /// Signed; sets the arrow direction and colour.
  final double changePct;
  final String changeLabel;
  final List<Color> gradient;
  final Color borderColor;

  /// Small trailing text after the number, e.g. "of 495".
  final String? valueSuffix;

  /// Overrides the colour/arrow when the figure isn't a trend (e.g. a
  /// completion rate judged against a target).
  final bool? positive;

  @override
  Widget build(BuildContext context) {
    final up = positive ?? changePct >= 0;
    final trendColor = up ? AppColors.leaf : AppColors.danger;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: AppColors.textPrimary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.8,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text.rich(
            TextSpan(
              text: Fmt.number(value),
              children: [
                if (valueSuffix != null)
                  TextSpan(
                    text: '  $valueSuffix',
                    style: const TextStyle(
                      fontSize: 15,
                      letterSpacing: 0,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w500,
              letterSpacing: 1,
              color: AppColors.figure,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                up
                    ? Icons.arrow_circle_up_outlined
                    : Icons.arrow_circle_down_outlined,
                size: 18,
                color: trendColor,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text.rich(
                  TextSpan(
                    text: Fmt.percent(changePct),
                    style: TextStyle(
                      color: trendColor,
                      fontWeight: FontWeight.w600,
                    ),
                    children: [
                      TextSpan(
                        text: ' $changeLabel',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
