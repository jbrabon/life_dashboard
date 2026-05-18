import 'package:life_dashboard/current_day/domain/entities/day_session.dart';
import 'package:life_dashboard/current_day/domain/value_objects/day_context.dart';
import 'package:life_dashboard/current_day/infrastructure/local_database.dart';
import 'package:sqflite/sqflite.dart';

class DaySessionLocalDatasource {
  Future<Database> get _db async => LocalDatabase.instance;

  Future<DaySession?> getOpenDaySession() async {
    final db = await _db;

    final results = await db.query(
      'day_sessions',
      where: 'closed_at_utc IS NULL',
      limit: 1,
    );

    if (results.isEmpty) {
      return null;
    }

    final row = results.first;

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
    final db = await _db;

    final session = DaySession(
      id: id,
      startedAtUtc: context.startedAtUtc,
      logicalDate: context.logicalDate,
      timezone: context.timezone,
    );

    await db.insert(
      'day_sessions',
      {
        'id': session.id,
        'started_at_utc': session.startedAtUtc.toIso8601String(),
        'closed_at_utc': null,
        'logical_date': session.logicalDate,
        'timezone': session.timezone,
      },
    );

    return session;
  }

  Future<void> closeDaySession({
    required String daySessionId,
    required String closedAtUtc,
  }) async {
    final db = await _db;

    await db.update(
      'day_sessions',
      {
        'closed_at_utc': closedAtUtc,
      },
      where: 'id = ? AND closed_at_utc IS NULL',
      whereArgs: [daySessionId],
    );
  }
}