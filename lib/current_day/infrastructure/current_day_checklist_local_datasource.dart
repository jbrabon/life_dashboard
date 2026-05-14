import 'package:life_dashboard/current_day/application/read_models/current_day_checklist_item.dart';
import 'package:life_dashboard/current_day/application/read_models/obligation_classification.dart';

class CurrentDayChecklistLocalDatasource {
  Future<List<CurrentDayChecklistItem>> getChecklistItems() async {
    // Temporary seed data (Phase 1: habits only)

    return [
      const CurrentDayChecklistItem(
        id: 'habit_1',
        type: CurrentDayChecklistItemType.habit,
        title: 'Wake up at 5:30',
        isCompleted: false,
        obligationClassification: ObligationClassification.dueToday,
      ),
      const CurrentDayChecklistItem(
        id: 'habit_2',
        type: CurrentDayChecklistItemType.habit,
        title: 'Go to gym',
        isCompleted: false,
        obligationClassification: ObligationClassification.dueToday,
      ),
      const CurrentDayChecklistItem(
        id: 'habit_3',
        type: CurrentDayChecklistItemType.habit,
        title: 'Read 10 pages',
        isCompleted: false,
        obligationClassification: ObligationClassification.notDueToday,
      ),
    ];
  }
}