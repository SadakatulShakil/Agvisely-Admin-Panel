import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/responsive.dart';
import 'state_views.dart';

/// Column definition for [AppDataTable].
class TableCol {
  const TableCol(this.label, {this.flex = 10, this.alignEnd = false});

  final String label;

  /// Relative width (columns share the row by flex).
  final int flex;
  final bool alignEnd;
}

/// Flex-column table matching the admin design.
///
/// * Wider than [minTableWidth]: columns stretch to fill.
/// * Narrower: scrolls horizontally at [minTableWidth].
/// * Phone layout with [mobileCardBuilder]: one card per row instead.
class AppDataTable<T> extends StatelessWidget {
  const AppDataTable({
    super.key,
    required this.columns,
    required this.rows,
    required this.cellsBuilder,
    this.minTableWidth = 900,
    this.mobileCardBuilder,
    this.rowMinHeight = 56,
    this.emptyMessage = 'Nothing here yet.',
    this.rowKey,
  });

  final List<TableCol> columns;
  final List<T> rows;
  final List<Widget> Function(T row) cellsBuilder;
  final double minTableWidth;
  final Widget Function(T row)? mobileCardBuilder;
  final double rowMinHeight;
  final String emptyMessage;
  final Object Function(T row)? rowKey;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return EmptyBlock(message: emptyMessage);

    if (mobileCardBuilder != null && context.isMobileLayout) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Divider(),
          for (var i = 0; i < rows.length; i++) ...[
            KeyedSubtree(
              key: rowKey == null ? null : ValueKey(rowKey!(rows[i])),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: mobileCardBuilder!(rows[i]),
              ),
            ),
            if (i < rows.length - 1) const Divider(indent: 16, endIndent: 16),
          ],
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final table = _buildTable();
        if (constraints.maxWidth >= minTableWidth) return table;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(width: minTableWidth, child: table),
        );
      },
    );
  }

  Widget _buildTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: const BoxDecoration(
            border: Border.symmetric(
              horizontal: BorderSide(color: AppColors.border),
            ),
          ),
          child: Row(
            children: [
              for (final c in columns)
                Expanded(
                  flex: c.flex,
                  child: Text(
                    c.label.toUpperCase(),
                    textAlign: c.alignEnd ? TextAlign.end : TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.4,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        for (var i = 0; i < rows.length; i++)
          _row(rows[i], last: i == rows.length - 1),
      ],
    );
  }

  Widget _row(T row, {required bool last}) {
    final cells = cellsBuilder(row);
    assert(
      cells.length == columns.length,
      'cellsBuilder returned ${cells.length} cells for ${columns.length} columns',
    );
    return Container(
      key: rowKey == null ? null : ValueKey(rowKey!(row)),
      constraints: BoxConstraints(minHeight: rowMinHeight),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border:
            last
                ? null
                : const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < columns.length; i++)
            Expanded(
              flex: columns[i].flex,
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Align(
                  alignment:
                      columns[i].alignEnd
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                  child: cells[i],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Plain body text for a table cell.
class CellText extends StatelessWidget {
  const CellText(this.text, {super.key, this.maxLines = 2, this.color});

  final String text;
  final int maxLines;
  final Color? color;

  @override
  Widget build(BuildContext context) => Text(
    text,
    maxLines: maxLines,
    overflow: TextOverflow.ellipsis,
    style: TextStyle(fontSize: 15, color: color ?? AppColors.textPrimary),
  );
}

/// "Label  value" line used inside mobile cards.
class CardField extends StatelessWidget {
  const CardField({super.key, required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(child: Align(alignment: Alignment.centerLeft, child: child)),
        ],
      ),
    );
  }
}
