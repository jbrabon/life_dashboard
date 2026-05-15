import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_dashboard/current_day/application/providers/current_day_checklist_providers.dart';
import 'package:life_dashboard/current_day/application/use_cases/toggle_checklist_item_completion_use_case.dart';
import 'package:life_dashboard/current_day/repositories/current_day_checklist_repository.dart';

final currentDayChecklistRepositoryProvider = Provider((ref) {
  return CurrentDayChecklistRepository(
    ref.read(currentDayChecklistLocalDatasourceProvider),
  );
});

final toggleChecklistItemCompletionUseCaseProvider = Provider((ref) {
  return ToggleChecklistItemCompletionUseCase(
    ref.read(currentDayChecklistRepositoryProvider),
  );
});

class ChecklistCompletionController {
  ChecklistCompletionController(this._ref);

  final Ref _ref;

  Future<void> toggleCompletion({
    required String daySessionId,
    required String itemId,
    required String itemType,
    required bool isCompleted,
  }) async {
    final useCase = _ref.read(toggleChecklistItemCompletionUseCaseProvider);

    await useCase.execute(
      daySessionId: daySessionId,
      itemId: itemId,
      itemType: itemType,
      isCompleted: isCompleted,
    );

    _ref.invalidate(currentDayChecklistProvider);
  }
}

final checklistCompletionControllerProvider = Provider((ref) {
  return ChecklistCompletionController(ref);
});