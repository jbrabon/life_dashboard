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
      const CurrentDayChecklistItem(
        id: 'habit_workout',
        type: CurrentDayChecklistItemType.habit,
        title: 'Workout',
        isCompleted: false,
        obligationClassification: ObligationClassification.dueToday,
      ),
      const CurrentDayChecklistItem(
        id: 'habit_read',
        type: CurrentDayChecklistItemType.habit,
        title: 'Read',
        isCompleted: false,
        obligationClassification: ObligationClassification.notDueToday,
      ),
      const CurrentDayChecklistItem(
        id: 'todo_pay_bill',
        type: CurrentDayChecklistItemType.todo,
        title: 'Pay bill',
        isCompleted: false,
        obligationClassification: ObligationClassification.dueToday,
      ),
      const CurrentDayChecklistItem(
        id: 'todo_send_email',
        type: CurrentDayChecklistItemType.todo,
        title: 'Send email',
        isCompleted: false,
        obligationClassification: ObligationClassification.overdue,
      ),
      const CurrentDayChecklistItem(
        id: 'todo_order_supplies',
        type: CurrentDayChecklistItemType.todo,
        title: 'Order supplies',
        isCompleted: false,
        obligationClassification: ObligationClassification.future,
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