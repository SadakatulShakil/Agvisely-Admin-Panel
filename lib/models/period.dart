/// Reporting window used by the period switch on every page.
enum Period {
  week('7d', '07 Days'),
  month('30d', '30 Days'),
  year('1y', '01 Year');

  const Period(this.apiValue, this.label);

  /// Value sent as `?period=`.
  final String apiValue;
  final String label;

  Duration get duration => switch (this) {
    Period.week => const Duration(days: 7),
    Period.month => const Duration(days: 30),
    Period.year => const Duration(days: 365),
  };
}
