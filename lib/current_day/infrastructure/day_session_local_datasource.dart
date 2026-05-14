import 'package:life_dashboard/current_day/domain/entities/day_session.dart';
import 'package:life_dashboard/current_day/domain/value_objects/day_context.dart';
import 'package:life_dashboard/current_day/infrastructure/local_database.dart';

class DaySessionLocalDatasource {
  Future<DaySession?> getOpenDaySession() async {
    final db = await LocalDatabase.instance;

    final rows = await db.query(
      'day_sessions',
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    final row = rows.first;

    return DaySession(
      id: row['id'] as String,
      startedAtUtc: DateTime.parse(row['started_at_utc'] as String),
      logicalDate: row['logical_date'] as String,
      timezone: row['timezone'] as String,
    );
  }

  Future<DaySession> startDay({
    required String id,
    required DayContext context,
  }) async {
    final db = await LocalDatabase.instance;

    await db.insert(
      'day_sessions',
      {
        'id': id,
        'started_at_utc': context.startedAtUtc.toIso8601String(),
        'logical_date': context.logicalDate,
        'timezone': context.timezone,
      },
    );

    return DaySession(
      id: id,
      startedAtUtc: context.startedAtUtc,
      logicalDate: context.logicalDate,
      timezone: context.timezone,
    );
  }
}