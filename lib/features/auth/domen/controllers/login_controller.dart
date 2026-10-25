import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/services/session_service.dart';
import '../../../../core/utils/phone_util.dart';
import '../../data/auth_repository.dart';

/// Step 1: mobile number → request OTP.
class LoginController extends GetxController {
  LoginController(this._repo);
  final AuthRepository _repo;

  final phoneCtrl = TextEditingController();
  final isSubmitting = false.obs;
  final errorText = RxnString();

  @override
  void onInit() {
    super.onInit();
    // Coming back from "Change number": prefill what they typed before.
    final pending = SessionService.to.pendingPhone;
    if (pending != null) phoneCtrl.text = pending;
  }

  void onPhoneChanged(String _) {
    if (errorText.value != null) errorText.value = null;
  }

  Future<void> requestOtp() async {
    if (isSubmitting.value) return;
    final invalid = PhoneUtil.validate(phoneCtrl.text);
    if (invalid != null) {
      errorText.value = invalid;
      return;
    }
    final phone = PhoneUtil.normalize(phoneCtrl.text)!;

    isSubmitting.value = true;
    errorText.value = null;
    try {
      await _repo.requestOtp(phone);
      await SessionService.to.setPendingPhone(phone);
      Get.toNamed(AppRoutes.otp);
    } catch (e) {
      errorText.value = ApiException.messageOf(e);
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    phoneCtrl.dispose();
    super.onClose();
  }
}
