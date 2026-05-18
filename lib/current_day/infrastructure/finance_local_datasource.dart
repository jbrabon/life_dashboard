import 'package:life_dashboard/current_day/infrastructure/local_database.dart';
import 'package:sqflite/sqflite.dart';

class FinanceLocalDatasource {
  Future<Database> get _db async => LocalDatabase.instance;

  Future<void> insertIncomeEntry({
    required String id,
    required String daySessionId,
    required int amountCents,
    String? note,
    required String occurredAtUtc,
    required String createdAtUtc,
  }) async {
    final db = await _db;

    await db.insert(
      'finance_income_entries',
      {
        'id': id,
        'day_session_id': daySessionId,
        'amount_cents': amountCents,
        'note': note,
        'occurred_at_utc': occurredAtUtc,
        'created_at_utc': createdAtUtc,
      },
    );
  }

  Future<void> insertExpenseEntry({
    required String id,
    required String daySessionId,
    required int amountCents,
    String? category,
    String? note,
    required String occurredAtUtc,
    required String createdAtUtc,
  }) async {
    final db = await _db;

    await db.insert(
      'finance_expense_entries',
      {
        'id': id,
        'day_session_id': daySessionId,
        'amount_cents': amountCents,
        'category': category,
        'note': note,
        'occurred_at_utc': occurredAtUtc,
        'created_at_utc': createdAtUtc,
      },
    );
  }

  Future<int> getIncomeTotalCentsForDaySession(String daySessionId) async {
    final db = await _db;

    final result = await db.rawQuery(
      '''
SELECT COALESCE(SUM(amount_cents), 0) AS total_cents
FROM finance_income_entries
WHERE day_session_id = ?
''',
      [daySessionId],
    );

    return result.first['total_cents'] as int;
  }

  Future<int> getExpenseTotalCentsForDaySession(String daySessionId) async {
    final db = await _db;

    final result = await db.rawQuery(
      '''
SELECT COALESCE(SUM(amount_cents), 0) AS total_cents
FROM finance_expense_entries
WHERE day_session_id = ?
''',
      [daySessionId],
    );

    return result.first['total_cents'] as int;
  }
}