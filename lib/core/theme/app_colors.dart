import 'package:flutter/material.dart';

/// Admin palette, sampled from the admin Figma frames. Brand greens match
/// the mobile app's `AppColors`.
class AppColors {
  AppColors._();

  // ── Brand ───────────────────────────────────────────────────────────────
  /// Olive — primary buttons, active nav pill, page titles.
  static const Color primary = Color(0xFF678042);
  static const Color primaryHover = Color(0xFF566C36);
  static const Color primarySoft = Color(0xFFE6ECDD);

  /// Leaf green — "Active" status, positive trends.
  static const Color leaf = Color(0xFF5F9E43);
  static const Color navy = Color(0xFF2E3F4F);

  // ── Surfaces ────────────────────────────────────────────────────────────
  static const Color scaffold = Color(0xFFF2F4F1);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF7F8F5);
  static const Color inputFill = Color(0xFFF1F3EF);
  static const Color border = Color(0xFFE5E9E1);
  static const Color borderStrong = Color(0xFFC9D3BE);
  static const Color chip = Color(0xFFEEF0EB);

  // ── Text ────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF2B3326);
  static const Color textSecondary = Color(0xFF6E7869);
  static const Color textMuted = Color(0xFF9AA394);
  static const Color figure = Color(0xFF3D4A33);

  // ── Semantic ────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF4E9F3D);
  static const Color successBg = Color(0xFFEDF6E6);
  static const Color danger = Color(0xFFDC2626);
  static const Color dangerBg = Color(0xFFFDECEC);
  static const Color warning = Color(0xFFE07B0A);
  static const Color warningBg = Color(0xFFFDF0DF);
  static const Color info = Color(0xFF1E88C7);
  static const Color infoBg = Color(0xFFE1F1FB);

  // ── Stat card tints (top-left → bottom-right, border) ───────────────────
  static const List<Color> tintGreen = [Color(0xFFEDF6E7), Color(0xFFF9FBF7)];
  static const Color tintGreenBorder = Color(0xFFDCEBD2);
  static const List<Color> tintTeal = [Color(0xFFE6F5F1), Color(0xFFF8FCFB)];
  static const Color tintTealBorder = Color(0xFFCDEAE2);
  static const List<Color> tintPeach = [Color(0xFFFFEFE5), Color(0xFFFFFAF6)];
  static const Color tintPeachBorder = Color(0xFFF7DCC8);
  static const List<Color> tintLilac = [Color(0xFFF8E9F8), Color(0xFFFDF7FD)];
  static const Color tintLilacBorder = Color(0xFFEDD6EE);
}
