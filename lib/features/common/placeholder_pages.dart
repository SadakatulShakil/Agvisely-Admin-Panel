import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/config/app_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/admin_shell.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/panel_card.dart';

/// Holds a nav slot for a section that's designed but not built yet.
class ComingSoonPage extends StatelessWidget {
  const ComingSoonPage({
    super.key,
    required this.route,
    required this.title,
    required this.description,
  });

  final String route;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      currentRoute: route,
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(title: title, subtitle: description),
          const SizedBox(height: 16),
          PanelCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 72, horizontal: 24),
              child: Column(
                children: [
                  const Icon(
                    Icons.construction_outlined,
                    size: 40,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '$title is the next part of the panel to be built.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () => Get.offAllNamed(AppRoutes.dashboard),
                    child: const Text('Back to overview'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Title(
      title: 'Page not found · ${AppConfig.appName}',
      color: AppColors.primary,
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Page not found',
                  style: TextStyle(fontSize: 32, color: AppColors.primary),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This address doesn’t match any page in the admin panel.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () => Get.offAllNamed(AppRoutes.root),
                  child: const Text('Go to overview'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
