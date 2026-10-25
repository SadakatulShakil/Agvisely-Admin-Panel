import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// "• Active" / "• Inactive".
class StatusDot extends StatelessWidget {
  const StatusDot({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(label, style: TextStyle(fontSize: 15, color: color)),
        ),
      ],
    );
  }
}

/// Small filled label: profession, advisory status, trigger, source state.
class Pill extends StatelessWidget {
  const Pill({
    super.key,
    required this.label,
    this.background = AppColors.chip,
    this.foreground = AppColors.textPrimary,
    this.radius = 6,
    this.fontSize = 15,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
  });

  final String label;
  final Color background;
  final Color foreground;
  final double radius;
  final double fontSize;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: fontSize, color: foreground, height: 1.25),
      ),
    );
  }
}

/// Underlined text action ("Suspend", "Restore", "Publish"). Shows a small
/// spinner while [busy].
class LinkAction extends StatelessWidget {
  const LinkAction({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = AppColors.primary,
    this.busy = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    if (busy) {
      return const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            color: onPressed == null ? AppColors.textMuted : color,
            decoration: TextDecoration.underline,
            decorationColor: color,
          ),
        ),
      ),
    );
  }
}

/// Outlined "View details »" link-button in panel headers.
class ViewDetailsButton extends StatelessWidget {
  const ViewDetailsButton({super.key, required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 30),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        textStyle: const TextStyle(fontSize: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('View details'),
          SizedBox(width: 4),
          Icon(Icons.keyboard_double_arrow_right, size: 14),
        ],
      ),
    );
  }
}
