import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/phone_util.dart';
import '../../domen/controllers/otp_controller.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/otp_boxes.dart';

class OtpPage extends GetView<OtpController> {
  const OtpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Verify code',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'OTP Verification Code',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w400,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 10),
          Text.rich(
            TextSpan(
              text: 'We have sent the verification code to ',
              children: [
                TextSpan(
                  text: PhoneUtil.mask(controller.phone),
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const TextSpan(text: '. '),
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: InkWell(
                    onTap: controller.changeNumber,
                    child: const Text(
                      'Change number',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.primary,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              height: 1.45,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 36),
          Obx(
            () => OtpBoxes(
              controllers: controller.controllers,
              focusNodes: controller.focusNodes,
              enabled: !controller.isSubmitting.value,
              hasError: controller.errorText.value != null,
              onChanged: controller.onCodeChanged,
            ),
          ),
          Obx(() => Center(child: AuthErrorText(controller.errorText.value))),
          const SizedBox(height: 40),
          Obx(
            () => AuthPrimaryButton(
              label: 'Submit',
              loading: controller.isSubmitting.value,
              onPressed: controller.verify,
            ),
          ),
          const SizedBox(height: 20),
          Obx(() {
            final s = controller.secondsLeft.value;
            if (controller.isResending.value) {
              return const Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            }
            if (s > 0) {
              final mm = (s ~/ 60).toString();
              final ss = (s % 60).toString().padLeft(2, '0');
              return Text(
                'Didn’t get it? You can resend in $mm:$ss',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              );
            }
            return Center(
              child: TextButton(
                onPressed: controller.resend,
                child: const Text('Resend code'),
              ),
            );
          }),
        ],
      ),
    );
  }
}
