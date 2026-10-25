import 'package:get/get.dart';

import '../../core/config/app_config.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/dashboard/data/dashboard_repository.dart';
import '../../features/user_management/data/user_repository.dart';

/// App-wide repositories. Each page binding only adds its controller.
/// `USE_MOCK` swaps every repository for its in-memory twin.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    const mock = AppConfig.useMockData;
    Get.put<AuthRepository>(
      mock ? MockAuthRepository() : RemoteAuthRepository(),
      permanent: true,
    );
    Get.lazyPut<DashboardRepository>(
      () => mock ? MockDashboardRepository() : RemoteDashboardRepository(),
      fenix: true,
    );
    Get.lazyPut<UserRepository>(
      () => mock ? MockUserRepository() : RemoteUserRepository(),
      fenix: true,
    );
  }
}
