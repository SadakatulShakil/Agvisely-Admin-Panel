/// The only error type repositories throw. [message] is always safe to
/// show to the user as-is.
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;

  /// Turns anything thrown into a user-facing message.
  static String messageOf(Object error) {
    if (error is ApiException) return error.message;
    return 'Something went wrong. Try again.';
  }

  @override
  String toString() => message;
}
