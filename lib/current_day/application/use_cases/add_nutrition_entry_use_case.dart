import 'package:life_dashboard/core/utils/id_generator.dart';
import 'package:life_dashboard/current_day/repositories/nutrition_repository.dart';

class AddNutritionEntryUseCase {
  AddNutritionEntryUseCase(this._repository);

  final NutritionRepository _repository;

  Future<void> execute({
    required String daySessionId,
    required int calories,
    required int proteinGrams,
    required int carbsGrams,
    required int sugarGrams,
    required int fatGrams,
  }) async {
    final nowUtc = DateTime.now().toUtc().toIso8601String();

    await _repository.addNutritionEntry(
      id: IdGenerator().generate(),
      daySessionId: daySessionId,
      calories: calories,
      proteinGrams: proteinGrams,
      carbsGrams: carbsGrams,
      sugarGrams: sugarGrams,
      fatGrams: fatGrams,
      createdAtUtc: nowUtc,
    );
  }
}