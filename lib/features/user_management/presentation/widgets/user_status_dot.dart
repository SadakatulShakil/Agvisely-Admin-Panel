import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/status_widgets.dart';
import '../../../../models/admin_user.dart';

class UserStatusDot extends StatelessWidget {
  const UserStatusDot({super.key, required this.user});
  final AdminUser user;

  @override
  Widget build(BuildContext context) => StatusDot(
    label: user.status.label,
    color: user.isActive ? AppColors.leaf : AppColors.danger,
  );
}
