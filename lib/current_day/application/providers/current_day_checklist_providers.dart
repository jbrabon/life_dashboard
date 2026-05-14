import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_dashboard/current_day/application/read_models/current_day_checklist_item.dart';
import 'package:life_dashboard/current_day/infrastructure/current_day_checklist_local_datasource.dart';

final currentDayChecklistLocalDatasourceProvider =
    Provider<CurrentDayChecklistLocalDatasource>((ref) {
  return CurrentDayChecklistLocalDatasource();
});

final currentDayChecklistProvider =
    FutureProvider<List<CurrentDayChecklistItem>>((ref) async {
  final datasource = ref.read(currentDayChecklistLocalDatasourceProvider);
  return datasource.getChecklistItems();
});