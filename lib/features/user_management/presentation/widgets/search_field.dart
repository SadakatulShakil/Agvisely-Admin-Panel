import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Compact white search box for page headers.
class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
    this.hint = 'Search…',
    this.width = 220,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final String hint;
  final double width;

  @override
  Widget build(BuildContext context) {
    const border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide.none,
    );
    return SizedBox(
      width: width,
      height: 42,
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder:
            (context, value, _) => TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              style: const TextStyle(fontSize: 15),
              decoration: InputDecoration(
                hintText: hint,
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                prefixIcon: const Icon(
                  Icons.search,
                  size: 22,
                  color: AppColors.primary,
                ),
                suffixIcon:
                    value.text.isEmpty
                        ? null
                        : IconButton(
                          tooltip: 'Clear search',
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: onClear,
                        ),
                border: border,
                enabledBorder: border,
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: AppColors.primary, width: 1.4),
                ),
              ),
            ),
      ),
    );
  }
}
