import 'package:life_dashboard/current_day/infrastructure/current_day_checklist_local_datasource.dart';

class CurrentDayChecklistRepository {
  CurrentDayChecklistRepository(this._datasource);

  final CurrentDayChecklistLocalDatasource _datasource;

  Future<void> upsertCompletion({
    required String id,
    required String daySessionId,
    required String itemId,
    required String itemType,
    required bool isCompleted,
    required String updatedAtUtc,
    String? completedAtUtc,
  }) {
    return _datasource.upsertCompletion(
      id: id,
      daySessionId: daySessionId,
      itemId: itemId,
      itemType: itemType,
      isCompleted: isCompleted,
      updatedAtUtc: updatedAtUtc,
      completedAtUtc: completedAtUtc,
    );
  }

  Future<Map<String, bool>> getCompletionMap(String daySessionId) {
    return _datasource.getCompletionMap(daySessionId);
  }
}