import 'package:life_dashboard/current_day/application/read_models/obligation_classification.dart';

enum CurrentDayChecklistItemType {
  habit,
  todo,
}

class CurrentDayChecklistItem {
  final String id;
  final CurrentDayChecklistItemType type;
  final String title;
  final bool isCompleted;
  final ObligationClassification obligationClassification;

  const CurrentDayChecklistItem({
    required this.id,
    required this.type,
    required this.title,
    required this.isCompleted,
    required this.obligationClassification,
  });
}