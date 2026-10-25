import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/responsive.dart';

/// Page title + subtitle on the left, page-level controls on the right
/// (stacked under the title on narrow screens).
class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final mobile = context.isMobileLayout;
    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            title,
            style: TextStyle(
              fontSize: mobile ? 30 : 40,
              fontWeight: FontWeight.w400,
              color: AppColors.primary,
              height: 1.15,
            ),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );

    if (actions.isEmpty) return heading;

    return LayoutBuilder(
      builder: (context, c) {
        if (c.maxWidth < 760) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              heading,
              const SizedBox(height: 16),
              Wrap(spacing: 12, runSpacing: 12, children: actions),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: heading),
            const SizedBox(width: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: actions,
            ),
          ],
        );
      },
    );
  }
}
