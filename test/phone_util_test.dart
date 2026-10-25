import 'package:agvisely_admin/core/utils/formatters.dart';
import 'package:agvisely_admin/core/utils/phone_util.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PhoneUtil', () {
    test('normalizes every accepted input to 01XXXXXXXXX', () {
      for (final input in [
        '+8801646923894',
        '8801646923894',
        '01646923894',
        '1646923894',
        '+880 1646 923894',
      ]) {
        expect(PhoneUtil.normalize(input), '01646923894', reason: input);
      }
    });

    test('rejects invalid numbers', () {
      expect(PhoneUtil.normalize('01246923894'), isNull); // bad operator digit
      expect(PhoneUtil.normalize('0164692389'), isNull); // too short
      expect(PhoneUtil.validate(''), isNotNull);
    });

    test('masks the middle digits', () {
      expect(PhoneUtil.mask('01646923894'), '0164••••894');
    });
  });

  group('Fmt', () {
    test('groups thousands', () {
      expect(Fmt.number(45946), '45,946');
      expect(Fmt.number(54738), '54,738');
      expect(Fmt.number(6), '6');
      expect(Fmt.number(1000000), '1,000,000');
    });

    test('short dates match the design', () {
      expect(Fmt.shortDate(DateTime(2026, 8, 12)), '12 Aug 26');
    });

    test('relative times', () {
      final now = DateTime(2026, 10, 25, 12);
      expect(
        Fmt.timeAgo(now.subtract(const Duration(minutes: 4)), now: now),
        '4 min ago',
      );
      expect(
        Fmt.timeAgo(
          now.subtract(const Duration(hours: 1, minutes: 29)),
          now: now,
        ),
        '1 hr 29 min ago',
      );
    });
  });
}
