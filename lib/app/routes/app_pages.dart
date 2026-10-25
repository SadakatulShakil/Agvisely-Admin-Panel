import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../features/auth/domen/binding/auth_binding.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/otp_page.dart';
import '../../features/common/placeholder_pages.dart';
import '../../features/dashboard/domen/binding/dashboard_binding.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/user_management/domen/binding/user_management_binding.dart';
import '../../features/user_management/presentation/pages/user_management_page.dart';
import '../middleware/route_guards.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final List<GetPage> pages = [
    GetPage(
      name: AppRoutes.root,
      page: () => const SizedBox.shrink(),
      middlewares: [RootRedirect()],
    ),

    // ── Sign-in ───────────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      binding: LoginBinding(),
      middlewares: [GuestGuard()],
    ),
    GetPage(
      name: AppRoutes.otp,
      page: () => const OtpPage(),
      binding: OtpBinding(),
      middlewares: [GuestGuard(), OtpGuard()],
    ),

    // ── Panel ─────────────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardPage(),
      binding: DashboardBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.users,
      page: () => const UserManagementPage(),
      binding: UserManagementBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.content,
      page:
          () => const ComingSoonPage(
            route: AppRoutes.content,
            title: 'Content (CMS)',
            description:
                'Advisory rule libraries for crop, GAP, IPM, livestock and aquaculture',
          ),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.others,
      page:
          () => const ComingSoonPage(
            route: AppRoutes.others,
            title: 'Others',
            description: 'Notifications, data sources and system settings',
          ),
      middlewares: [AuthGuard()],
    ),
  ];

  static final GetPage notFound = GetPage(
    name: AppRoutes.notFound,
    page: () => const NotFoundPage(),
  );
}
