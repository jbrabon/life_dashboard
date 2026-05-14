class DaySession {
  final String id;
  final DateTime startedAtUtc;
  final String logicalDate;
  final String timezone;

  const DaySession({
    required this.id,
    required this.startedAtUtc,
    required this.logicalDate,
    required this.timezone,
  });
}