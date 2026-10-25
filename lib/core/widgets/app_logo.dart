import 'package:flutter/material.dart';

/// Agvisely wordmark — the same exported PNG as the mobile app.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.height = 48});
  final double height;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Agvisely',
      image: true,
      child: Image.asset(
        'assets/images/agvisely-logo.png',
        height: height,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
      ),
    );
  }
}
