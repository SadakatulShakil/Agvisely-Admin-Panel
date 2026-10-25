import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_colors.dart';

/// Asks before a consequential action. Resolves to true only when the
/// person presses the confirm button.
Future<bool> showConfirmDialog({
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = 'Cancel',
  bool destructive = false,
}) async {
  final result = await Get.dialog<bool>(
    AlertDialog(
      title: Text(title),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Text(message),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: Text(cancelLabel),
        ),
        FilledButton(
          style:
              destructive
                  ? FilledButton.styleFrom(backgroundColor: AppColors.danger)
                  : null,
          onPressed: () => Get.back(result: true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}
