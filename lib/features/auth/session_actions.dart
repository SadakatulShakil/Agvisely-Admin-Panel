import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/services/session_service.dart';
import '../../core/widgets/confirm_dialog.dart';
import 'data/auth_repository.dart';

/// Sign-out flow shared by the top bar and the mobile drawer.
class SessionActions {
  SessionActions._();

  static Future<void> signOut({bool ask = true}) async {
    if (ask) {
      final ok = await showConfirmDialog(
        title: 'Sign out?',
        message: 'You’ll need a new OTP to sign back in.',
        confirmLabel: 'Sign out',
      );
      if (!ok) return;
    }
    final session = SessionService.to;
    // Revoke server-side, but never block sign-out on the network.
    try {
      await Get.find<AuthRepository>().logout(session.refreshToken);
    } catch (_) {}
    await session.clear();
    Get.offAllNamed(AppRoutes.login);
  }
}
