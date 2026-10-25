import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../models/paginated.dart';

class PaginationBar extends StatelessWidget {
  const PaginationBar({super.key, required this.page, required this.onPage});

  final Paginated<Object?> page;
  final ValueChanged<int> onPage;

  @override
  Widget build(BuildContext context) {
    if (page.total == 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Showing ${Fmt.number(page.firstIndex)}–${Fmt.number(page.lastIndex)} of ${Fmt.number(page.total)}',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            'Page ${page.page} of ${page.totalPages}',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'Previous page',
            onPressed: page.hasPrevious ? () => onPage(page.page - 1) : null,
            icon: const Icon(Icons.chevron_left),
            color: AppColors.primary,
          ),
          IconButton(
            tooltip: 'Next page',
            onPressed: page.hasNext ? () => onPage(page.page + 1) : null,
            icon: const Icon(Icons.chevron_right),
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
