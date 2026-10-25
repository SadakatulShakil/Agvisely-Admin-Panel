import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/navigation.dart';
import '../../app/routes/app_routes.dart';
import '../../features/auth/session_actions.dart';
import '../config/app_config.dart';
import '../services/session_service.dart';
import '../theme/app_colors.dart';
import '../utils/phone_util.dart';
import '../utils/responsive.dart';
import 'app_logo.dart';

/// Frame for every signed-in page: top bar (nav pills on desktop, drawer
/// on narrow screens), centred max-width content, browser tab title.
class AdminShell extends StatelessWidget {
  const AdminShell({
    super.key,
    required this.currentRoute,
    required this.title,
    required this.child,
  });

  final String currentRoute;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final gutter = context.pageGutter;
    return Title(
      title: '$title · ${AppConfig.appName}',
      color: AppColors.primary,
      child: Scaffold(
        endDrawer:
            context.useCompactNav
                ? _NavDrawer(currentRoute: currentRoute)
                : null,
        body: SafeArea(
          child: Column(
            children: [
              _TopBar(currentRoute: currentRoute),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(gutter, 8, gutter, 40),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1480),
                      child: child,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _go(String route) {
  if (Get.currentRoute != route) Get.toNamed(route);
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.currentRoute});
  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    final compact = context.useCompactNav;
    final mobile = context.isMobileLayout;
    final gutter = context.pageGutter;

    return Padding(
      padding: EdgeInsets.fromLTRB(gutter, mobile ? 12 : 24, gutter, 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1480),
          child: Row(
            children: [
              InkWell(
                onTap: () => _go(AppRoutes.dashboard),
                borderRadius: BorderRadius.circular(8),
                child: AppLogo(height: mobile ? 36 : 48),
              ),
              if (compact)
                const Spacer()
              else
                Expanded(
                  child: Center(child: _NavPills(currentRoute: currentRoute)),
                ),
              if (!mobile) ...[
                _CircleIconButton(
                  icon: Icons.search,
                  tooltip: 'Search users',
                  onPressed: () => _go(AppRoutes.users),
                ),
                const SizedBox(width: 16),
                const _NotificationsButton(),
                const SizedBox(width: 16),
              ],
              const _ProfileMenu(),
              if (compact) ...[
                const SizedBox(width: 8),
                Builder(
                  builder:
                      (ctx) => IconButton(
                        tooltip: 'Menu',
                        icon: const Icon(Icons.menu, color: AppColors.primary),
                        onPressed: () => Scaffold.of(ctx).openEndDrawer(),
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NavPills extends StatelessWidget {
  const _NavPills({required this.currentRoute});
  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final item in kNavItems)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _NavPill(item: item, selected: item.route == currentRoute),
          ),
      ],
    );
  }
}

class _NavPill extends StatelessWidget {
  const _NavPill({required this.item, required this.selected});
  final NavItem item;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          hoverColor: AppColors.primarySoft,
          onTap: () => _go(item.route),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Text(
              item.label,
              style: TextStyle(
                fontSize: 16,
                color: selected ? Colors.white : AppColors.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: _CircleFrame(icon: icon),
      ),
    );
  }
}

/// Decorative 40px outlined circle used by the top-bar icon buttons.
class _CircleFrame extends StatelessWidget {
  const _CircleFrame({this.icon});
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 1.2),
      ),
      child:
          icon == null ? null : Icon(icon, color: AppColors.primary, size: 22),
    );
  }
}

class _NotificationsButton extends StatelessWidget {
  const _NotificationsButton();

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<void>(
      tooltip: 'Notifications',
      offset: const Offset(0, 48),
      itemBuilder:
          (_) => const [
            PopupMenuItem<void>(
              enabled: false,
              child: SizedBox(
                width: 240,
                child: Text(
                  'You’re all caught up.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ),
          ],
      child: const _CircleFrame(icon: Icons.notifications_none),
    );
  }
}

class _ProfileMenu extends StatelessWidget {
  const _ProfileMenu();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = SessionService.to.user.value;
      return PopupMenuButton<String>(
        tooltip: 'Account',
        offset: const Offset(0, 52),
        onSelected: (v) {
          if (v == 'signout') SessionActions.signOut();
        },
        itemBuilder:
            (_) => [
              PopupMenuItem<String>(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name.isNotEmpty == true
                          ? user!.name
                          : 'Administrator',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (user != null)
                      Text(
                        PhoneUtil.mask(user.phone),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'signout',
                child: Row(
                  children: [
                    Icon(
                      Icons.logout,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 10),
                    Text('Sign out'),
                  ],
                ),
              ),
            ],
        child: _Avatar(
          initials: user?.initials ?? 'A',
          imageUrl: user?.profileUrl,
        ),
      );
    });
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initials, this.imageUrl});
  final String initials;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.startsWith('http');
    return CircleAvatar(
      radius: 21,
      backgroundColor: AppColors.primarySoft,
      foregroundImage: hasImage ? NetworkImage(imageUrl!) : null,
      child: Text(
        initials,
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    );
  }
}

class _NavDrawer extends StatelessWidget {
  const _NavDrawer({required this.currentRoute});
  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 300,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: AppLogo(height: 40),
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            for (final item in kNavItems)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 2,
                ),
                child: ListTile(
                  leading: Icon(item.icon),
                  title: Text(item.label),
                  selected: item.route == currentRoute,
                  selectedColor: Colors.white,
                  selectedTileColor: AppColors.primary,
                  iconColor: AppColors.primary,
                  textColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _go(item.route);
                  },
                ),
              ),
            const Spacer(),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(12),
              child: ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sign out'),
                iconColor: AppColors.textSecondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  SessionActions.signOut();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
