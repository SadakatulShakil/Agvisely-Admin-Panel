import '../../../core/network/api_exception.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../models/admin_user.dart';
import '../data/user_repository.dart';

/// Suspend / restore with confirmation — shared by the overview preview
/// and the full user list. Returns the updated user, or null if cancelled
/// or failed.
Future<AdminUser?> toggleUserStatus(UserRepository repo, AdminUser user) async {
  final suspending = user.isActive;
  final ok = await showConfirmDialog(
    title: suspending ? 'Suspend ${user.name}?' : 'Restore ${user.name}?',
    message:
        suspending
            ? 'They’ll be signed out of the Agvisely app and can’t sign back in until you restore them.'
            : 'They’ll be able to sign in to the Agvisely app again.',
    confirmLabel: suspending ? 'Suspend' : 'Restore',
    destructive: suspending,
  );
  if (!ok) return null;

  try {
    final updated = await repo.setStatus(
      user.id,
      suspending ? UserStatus.inactive : UserStatus.active,
    );
    AppToast.success(
      suspending ? '${user.name} is suspended.' : '${user.name} is restored.',
    );
    return updated;
  } catch (e) {
    AppToast.error(ApiException.messageOf(e));
    return null;
  }
}
