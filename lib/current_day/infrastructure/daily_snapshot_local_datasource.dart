import 'package:life_dashboard/current_day/infrastructure/local_database.dart';
import 'package:sqflite/sqflite.dart';

class DailySnapshotLocalDatasource {
  Future<Database> get _db async => LocalDatabase.instance;

  Future<void> insertSnapshot({
    required String id,
    required String daySessionId,
    required String finalizedAtUtc,
    required int checklistTotalCount,
    required int checklistCompletedCount,
    required int incomeCents,
    required int expenseCents,
    required int netCents,
    required int calories,
    required int proteinGrams,
    required int carbsGrams,
    required int sugarGrams,
    required int fatGrams,
  }) async {
    final db = await _db;

    await db.insert(
      'daily_snapshots',
      {
        'id': id,
        'day_session_id': daySessionId,
        'finalized_at_utc': finalizedAtUtc,
        'checklist_total_count': checklistTotalCount,
        'checklist_completed_count': checklistCompletedCount,
        'finance_income_cents': incomeCents,
        'finance_expense_cents': expenseCents,
        'finance_net_cents': netCents,
        'nutrition_calories': calories,
        'nutrition_protein_grams': proteinGrams,
        'nutrition_carbs_grams': carbsGrams,
        'nutrition_sugar_grams': sugarGrams,
        'nutrition_fat_grams': fatGrams,
      },
    );
  }
}