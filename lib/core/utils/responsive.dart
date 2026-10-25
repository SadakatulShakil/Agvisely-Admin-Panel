import 'package:flutter/widgets.dart';

/// Layout breakpoints (logical pixels).
class Breakpoints {
  Breakpoints._();

  /// Below this: phone layout (cards instead of tables, 16px gutters).
  static const double mobile = 640;

  /// Below this: the top nav collapses into a drawer.
  static const double compactNav = 980;

  /// Below this: dashboard columns stack.
  static const double wide = 1200;
}

// Names avoid GetX's own BuildContext extensions (width, isPhone, …).
extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  bool get isMobileLayout => screenWidth < Breakpoints.mobile;
  bool get useCompactNav => screenWidth < Breakpoints.compactNav;
  bool get isWideLayout => screenWidth >= Breakpoints.wide;
  double get pageGutter => isMobileLayout ? 16 : 32;
}
