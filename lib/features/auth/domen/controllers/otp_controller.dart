import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/services/session_service.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../data/auth_repository.dart';

/// Step 2: verify the code, check the account may use the panel, start
/// the session.
class OtpController extends GetxController {
  OtpController(this._repo);
  final AuthRepository _repo;

  static const int length = AppConfig.otpLength;

  final controllers = List.generate(length, (_) => TextEditingController());
  final focusNodes = List.generate(length, (_) => FocusNode());

  final isSubmitting = false.obs;
  final isResending = false.obs;
  final errorText = RxnString();
  final secondsLeft = AppConfig.otpResendSeconds.obs;

  Timer? _timer;

  String get phone => SessionService.to.pendingPhone ?? '';
  String get code => controllers.map((c) => c.text).join();

  @override
  void onInit() {
    super.onInit();
    _startCountdown();
  }

  @override
  void onReady() {
    super.onReady();
    focusNodes.first.requestFocus();
  }

  void _startCountdown() {
    _timer?.cancel();
    secondsLeft.value = AppConfig.otpResendSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (secondsLeft.value <= 1) {
        secondsLeft.value = 0;
        t.cancel();
      } else {
        secondsLeft.value--;
      }
    });
  }

  /// Called by the boxes whenever a digit changes.
  void onCodeChanged() {
    if (errorText.value != null) errorText.value = null;
    if (code.length == length) verify();
  }

  void clearCode() {
    for (final c in controllers) {
      c.clear();
    }
    focusNodes.first.requestFocus();
  }

  Future<void> verify() async {
    if (isSubmitting.value) return;
    final otp = code;
    if (otp.length != length) {
      errorText.value = 'Enter the $length-digit code.';
      return;
    }

    isSubmitting.value = true;
    errorText.value = null;
    try {
      final result = await _repo.verifyOtp(phone: phone, otp: otp);
      if (!result.user.canUsePanel) {
        // Valid user, wrong role: don't keep the tokens.
        await _repo.logout(result.refreshToken);
        errorText.value =
            'This number isn’t registered as an Agvisely administrator.';
        clearCode();
        return;
      }
      await SessionService.to.start(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
        expiresIn: result.expiresIn,
        profile: result.user,
      );
      await SessionService.to.clearPendingPhone();
      Get.offAllNamed(AppRoutes.dashboard);
    } catch (e) {
      errorText.value = ApiException.messageOf(e);
      clearCode();
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> resend() async {
    if (secondsLeft.value > 0 || isResending.value) return;
    isResending.value = true;
    try {
      await _repo.requestOtp(phone);
      clearCode();
      _startCountdown();
      AppToast.success('A new code is on its way.');
    } catch (e) {
      errorText.value = ApiException.messageOf(e);
    } finally {
      isResending.value = false;
    }
  }

  void changeNumber() {
    if (Get.previousRoute == AppRoutes.login) {
      Get.back();
    } else {
      Get.offNamed(AppRoutes.login);
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    for (final c in controllers) {
      c.dispose();
    }
    for (final f in focusNodes) {
      f.dispose();
    }
    super.onClose();
  }
}
