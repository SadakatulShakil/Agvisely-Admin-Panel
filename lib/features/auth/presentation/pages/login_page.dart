import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domen/controllers/login_controller.dart';
import '../widgets/auth_scaffold.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Sign in',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Sign in with your registered mobile number. We’ll text you a one-time code.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            'Mobile number for OTP',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Obx(
            () => TextField(
              controller: controller.phoneCtrl,
              enabled: !controller.isSubmitting.value,
              autofocus: true,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.go,
              autofillHints: const [AutofillHints.telephoneNumber],
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]')),
                LengthLimitingTextInputFormatter(16),
              ],
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                hintText: '+8801646923894',
                enabledBorder:
                    controller.errorText.value == null
                        ? null
                        : OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.danger),
                        ),
              ),
              onChanged: controller.onPhoneChanged,
              onSubmitted: (_) => controller.requestOtp(),
            ),
          ),
          Obx(() => AuthErrorText(controller.errorText.value)),
          const SizedBox(height: 40),
          Obx(
            () => AuthPrimaryButton(
              label: 'Request OTP',
              loading: controller.isSubmitting.value,
              onPressed: controller.requestOtp,
            ),
          ),
          if (AppConfig.useMockData) ...[
            const SizedBox(height: 24),
            const Text(
              'Demo data mode — any valid number works; the code is ${AppConfig.mockOtp}.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}
