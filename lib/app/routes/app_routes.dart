/// URL paths. With the path URL strategy these are the real browser URLs,
/// so they're short, lowercase and bookmarkable.
abstract class AppRoutes {
  AppRoutes._();

  static const String root = '/';
  static const String login = '/login';
  static const String otp = '/login/verify';
  static const String dashboard = '/overview';
  static const String users = '/users';
  static const String content = '/content';
  static const String others = '/others';
  static const String notFound = '/not-found';
}
