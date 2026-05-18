import 'package:life_dashboard/current_day/domain/entities/day_session.dart';
import 'package:life_dashboard/current_day/domain/value_objects/day_context.dart';

abstract class DaySessionRepository {
  Future<DaySession?> getOpenDaySession();

  Future<DaySession> startDay(DayContext context);

  Future<void> closeDaySession({
    required String daySessionId,
    required String closedAtUtc,
  });
}