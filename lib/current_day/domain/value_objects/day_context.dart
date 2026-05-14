class DayContext {
  final DateTime startedAtUtc;
  final String logicalDate;
  final String timezone;

  const DayContext({
    required this.startedAtUtc,
    required this.logicalDate,
    required this.timezone,
  });
}