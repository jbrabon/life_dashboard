import 'package:life_dashboard/core/utils/id_generator.dart';
import 'package:life_dashboard/current_day/repositories/current_day_checklist_repository.dart';

class ToggleChecklistItemCompletionUseCase {
  ToggleChecklistItemCompletionUseCase(this._repository);

  final CurrentDayChecklistRepository _repository;

  Future<void> execute({
    required String daySessionId,
    required String itemId,
    required String itemType,
    required bool isCompleted,
  }) async {
    final nowUtc = DateTime.now().toUtc().toIso8601String();

    await _repository.upsertCompletion(
      id: IdGenerator.generate(),
      daySessionId: daySessionId,
      itemId: itemId,
      itemType: itemType,
      isCompleted: isCompleted,
      completedAtUtc: isCompleted ? nowUtc : null,
      updatedAtUtc: nowUtc,
    );
  }
}