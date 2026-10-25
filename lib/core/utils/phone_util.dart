/// Bangladeshi mobile-number helpers — identical rules to the mobile app,
/// so the same inputs are accepted on both.
///
///   +8801646923894 / 8801646923894 / 01646923894 / 1646923894
///   → 01646923894
class PhoneUtil {
  PhoneUtil._();

  static final RegExp _valid = RegExp(r'^01[3-9]\d{8}$');

  static String? normalize(String input) {
    var d = input.replaceAll(RegExp(r'\D'), '');
    if (d.startsWith('880')) d = d.substring(3);
    if (d.startsWith('0')) d = d.substring(1);
    final canonical = '0$d';
    return _valid.hasMatch(canonical) ? canonical : null;
  }

  static bool isValid(String input) => normalize(input) != null;

  static String? validate(String? input) {
    if (input == null || input.trim().isEmpty) {
      return 'Enter your mobile number.';
    }
    return isValid(input)
        ? null
        : 'Enter a valid Bangladeshi mobile number, like 01646923894.';
  }

  /// 01646923894 → 0164••••894
  static String mask(String phone) {
    if (phone.length < 8) return phone;
    return '${phone.substring(0, 4)}••••${phone.substring(phone.length - 3)}';
  }
}
