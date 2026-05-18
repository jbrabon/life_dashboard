import 'package:life_dashboard/current_day/infrastructure/local_database.dart';
import 'package:sqflite/sqflite.dart';

class NutritionTotals {
  final int calories;
  final int proteinGrams;
  final int carbsGrams;
  final int sugarGrams;
  final int fatGrams;

  NutritionTotals({
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.sugarGrams,
    required this.fatGrams,
  });
}

class NutritionLocalDatasource {
  Future<Database> get _db async => LocalDatabase.instance;

  Future<void> insertNutritionEntry({
    required String id,
    required String daySessionId,
    required int calories,
    required int proteinGrams,
    required int carbsGrams,
    required int sugarGrams,
    required int fatGrams,
    required String createdAtUtc,
  }) async {
    final db = await _db;

    await db.insert('nutrition_entries', {
      'id': id,
      'day_session_id': daySessionId,
      'calories': calories,
      'protein_grams': proteinGrams,
      'carbs_grams': carbsGrams,
      'sugar_grams': sugarGrams,
      'fat_grams': fatGrams,
      'created_at_utc': createdAtUtc,
    });
  }

  Future<NutritionTotals> getNutritionTotalsForDaySession(
    String daySessionId,
  ) async {
    final db = await _db;

    final result = await db.rawQuery('''
SELECT
  COALESCE(SUM(calories), 0) AS calories,
  COALESCE(SUM(protein_grams), 0) AS protein,
  COALESCE(SUM(carbs_grams), 0) AS carbs,
  COALESCE(SUM(sugar_grams), 0) AS sugar,
  COALESCE(SUM(fat_grams), 0) AS fat
FROM nutrition_entries
WHERE day_session_id = ?
''', [daySessionId]);

    final row = result.first;

    return NutritionTotals(
      calories: row['calories'] as int,
      proteinGrams: row['protein'] as int,
      carbsGrams: row['carbs'] as int,
      sugarGrams: row['sugar'] as int,
      fatGrams: row['fat'] as int,
    );
  }
}