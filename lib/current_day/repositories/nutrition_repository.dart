import 'package:life_dashboard/current_day/infrastructure/nutrition_local_datasource.dart';

class NutritionRepository {
  NutritionRepository(this._datasource);

  final NutritionLocalDatasource _datasource;

  Future<void> addNutritionEntry({
    required String id,
    required String daySessionId,
    required int calories,
    required int proteinGrams,
    required int carbsGrams,
    required int sugarGrams,
    required int fatGrams,
    required String createdAtUtc,
  }) {
    return _datasource.insertNutritionEntry(
      id: id,
      daySessionId: daySessionId,
      calories: calories,
      proteinGrams: proteinGrams,
      carbsGrams: carbsGrams,
      sugarGrams: sugarGrams,
      fatGrams: fatGrams,
      createdAtUtc: createdAtUtc,
    );
  }

  Future<NutritionTotals> getNutritionTotalsForDaySession(
    String daySessionId,
  ) {
    return _datasource.getNutritionTotalsForDaySession(daySessionId);
  }
}