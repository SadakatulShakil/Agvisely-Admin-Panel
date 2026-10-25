/// Small formatting helpers (kept local to avoid an `intl` version clash
/// with the mobile app's pin).
class Fmt {
  Fmt._();

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  /// 45946 → 45,946
  static String number(num value) {
    final digits = value.round().abs().toString();
    final out = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) out.write(',');
      out.write(digits[i]);
    }
    return value < 0 ? '-$out' : out.toString();
  }

  /// 12.63 → 12.6%
  static String percent(double value) => '${value.abs().toStringAsFixed(1)}%';

  /// 2026-08-12 → 12 Aug 26
  static String shortDate(DateTime? d) {
    if (d == null) return '—';
    final dd = d.day.toString().padLeft(2, '0');
    final yy = (d.year % 100).toString().padLeft(2, '0');
    return '$dd ${_months[d.month - 1]} $yy';
  }

  /// "4 min ago", "1 hr 29 min ago", "3 days ago"
  static String timeAgo(DateTime? t, {DateTime? now}) {
    if (t == null) return 'Never';
    final diff = (now ?? DateTime.now()).difference(t);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes} min ago';
    if (diff.inDays < 1) {
      final m = diff.inMinutes % 60;
      return m == 0
          ? '${diff.inHours} hr ago'
          : '${diff.inHours} hr $m min ago';
    }
    final days = diff.inDays;
    return '$days day${days == 1 ? '' : 's'} ago';
  }
}
