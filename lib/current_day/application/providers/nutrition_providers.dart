import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_dashboard/current_day/application/providers/day_session_providers.dart';
import 'package:life_dashboard/current_day/application/use_cases/add_nutrition_entry_use_case.dart';
import 'package:life_dashboard/current_day/infrastructure/nutrition_local_datasource.dart';
import 'package:life_dashboard/current_day/repositories/nutrition_repository.dart';

final nutritionLocalDatasourceProvider = Provider((ref) {
  return NutritionLocalDatasource();
});

final nutritionRepositoryProvider = Provider((ref) {
  final datasource = ref.read(nutritionLocalDatasourceProvider);
  return NutritionRepository(datasource);
});

final addNutritionEntryUseCaseProvider = Provider((ref) {
  final repository = ref.read(nutritionRepositoryProvider);
  return AddNutritionEntryUseCase(repository);
});

final currentDayNutritionTotalsProvider =
    FutureProvider<NutritionTotals>((ref) async {
  final session = await ref.watch(startDayControllerProvider.future);

  if (session == null) {
    return NutritionTotals(
      calories: 0,
      proteinGrams: 0,
      carbsGrams: 0,
      sugarGrams: 0,
      fatGrams: 0,
    );
  }

  final repository = ref.read(nutritionRepositoryProvider);

  return repository.getNutritionTotalsForDaySession(session.id);
});

class NutritionEntryController {
  NutritionEntryController(this._ref);

  final Ref _ref;

  Future<void> addEntry({
    required String daySessionId,
    required int calories,
    required int proteinGrams,
    required int carbsGrams,
    required int sugarGrams,
    required int fatGrams,
  }) async {
    final useCase = _ref.read(addNutritionEntryUseCaseProvider);

    await useCase.execute(
      daySessionId: daySessionId,
      calories: calories,
      proteinGrams: proteinGrams,
      carbsGrams: carbsGrams,
      sugarGrams: sugarGrams,
      fatGrams: fatGrams,
    );

    _ref.invalidate(currentDayNutritionTotalsProvider);
  }
}

final nutritionEntryControllerProvider = Provider((ref) {
  return NutritionEntryController(ref);
});