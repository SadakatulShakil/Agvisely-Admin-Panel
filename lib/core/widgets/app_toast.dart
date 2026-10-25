import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_colors.dart';

/// Short confirmations and failures, bottom-anchored.
class AppToast {
  AppToast._();

  static void success(String message) =>
      _show(message, AppColors.primary, Icons.check_circle_outline);

  static void error(String message) =>
      _show(message, AppColors.danger, Icons.error_outline);

  static void info(String message) =>
      _show(message, AppColors.navy, Icons.info_outline);

  static void _show(String message, Color color, IconData icon) {
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
    Get.rawSnackbar(
      messageText: Text(
        message,
        style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.35),
      ),
      icon: Icon(icon, color: Colors.white, size: 20),
      backgroundColor: color,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
      maxWidth: 460,
      duration: const Duration(seconds: 3),
    );
  }
}
