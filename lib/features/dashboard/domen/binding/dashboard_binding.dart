import 'package:get/get.dart';

import '../../../user_management/data/user_repository.dart';
import '../../data/dashboard_repository.dart';
import '../controllers/dashboard_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => DashboardController(
        Get.find<DashboardRepository>(),
        Get.find<UserRepository>(),
      ),
    );
  }
}
