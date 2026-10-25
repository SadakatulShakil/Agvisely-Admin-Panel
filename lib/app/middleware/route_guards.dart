import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../core/services/session_service.dart';
import '../routes/app_routes.dart';

/// `/` → overview when signed in, sign-in otherwise.
class RootRedirect extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) => RouteSettings(
    name:
        SessionService.to.isAuthenticated
            ? AppRoutes.dashboard
            : AppRoutes.login,
  );
}

/// Panel pages: signed-in admins only.
class AuthGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) =>
      SessionService.to.isAuthenticated
          ? null
          : const RouteSettings(name: AppRoutes.login);
}

/// Sign-in pages: bounce signed-in admins to the overview.
class GuestGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) =>
      SessionService.to.isAuthenticated
          ? const RouteSettings(name: AppRoutes.dashboard)
          : null;
}

/// The OTP step needs a phone number from the previous step.
class OtpGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) =>
      (SessionService.to.pendingPhone?.isNotEmpty ?? false)
          ? null
          : const RouteSettings(name: AppRoutes.login);
}
