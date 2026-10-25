import 'package:get/get.dart';

import '../../data/auth_repository.dart';
import '../controllers/login_controller.dart';
import '../controllers/otp_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginController(Get.find<AuthRepository>()));
  }
}

class OtpBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OtpController(Get.find<AuthRepository>()));
  }
}
