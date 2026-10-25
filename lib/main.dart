import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:get/get.dart';

import 'app/bindings/initial_binding.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'core/config/app_config.dart';
import 'core/services/session_service.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Clean URLs (/users instead of /#/users). The host must rewrite unknown
  // paths to index.html — see README › Deploying.
  usePathUrlStrategy();

  // Route guards read the session synchronously, so load it first.
  await Get.putAsync<SessionService>(
    () => SessionService().init(),
    permanent: true,
  );

  runApp(const AgviselyAdminApp());
}

class AgviselyAdminApp extends StatelessWidget {
  const AgviselyAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: const Locale('en'),
      fallbackLocale: const Locale('en'),
      initialBinding: InitialBinding(),
      initialRoute: AppRoutes.root,
      getPages: AppPages.pages,
      unknownRoute: AppPages.notFound,
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 120),
      builder:
          (context, child) => ScrollConfiguration(
            behavior: const _AdminScrollBehavior(),
            child: child ?? const SizedBox.shrink(),
          ),
    );
  }
}

/// Lets mouse and trackpad drag the horizontally-scrolling tables.
class _AdminScrollBehavior extends MaterialScrollBehavior {
  const _AdminScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };
}
