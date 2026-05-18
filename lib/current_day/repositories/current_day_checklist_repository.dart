import 'package:life_dashboard/current_day/application/read_models/current_day_checklist_item.dart';
import 'package:life_dashboard/current_day/application/read_models/obligation_classification.dart';
import 'package:life_dashboard/current_day/infrastructure/current_day_checklist_local_datasource.dart';

class CurrentDayChecklistRepository {
  CurrentDayChecklistRepository(this._datasource);

  final CurrentDayChecklistLocalDatasource _datasource;

  Future<List<CurrentDayChecklistItem>> getChecklistItems({
    required String daySessionId,
  }) async {
    final completionMap = await _datasource.getCompletionMap(daySessionId);

    final seedItems = [
      CurrentDayChecklistItem(
        id: '1',
        type: CurrentDayChecklistItemType.habit,
        title: 'Workout',
        isCompleted: false,
        obligationClassification: ObligationClassification.dueToday,
      ),
      CurrentDayChecklistItem(
        id: '2',
        type: CurrentDayChecklistItemType.habit,
        title: 'Read',
        isCompleted: false,
        obligationClassification: ObligationClassification.notDueToday,
      ),
    ];

    return seedItems.map((item) {
      return CurrentDayChecklistItem(
        id: item.id,
        type: item.type,
        title: item.title,
        isCompleted: completionMap[item.id] ?? false,
        obligationClassification: item.obligationClassification,
      );
    }).toList();
  }

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
}