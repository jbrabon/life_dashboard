import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_dashboard/current_day/application/providers/day_session_providers.dart';
import 'package:life_dashboard/current_day/application/read_models/current_day_checklist_item.dart';
import 'package:life_dashboard/current_day/infrastructure/current_day_checklist_local_datasource.dart';
import 'package:life_dashboard/current_day/repositories/current_day_checklist_repository.dart';

final currentDayChecklistLocalDatasourceProvider = Provider((ref) {
  return CurrentDayChecklistLocalDatasource();
});

final currentDayChecklistRepositoryProvider = Provider((ref) {
  final datasource = ref.read(currentDayChecklistLocalDatasourceProvider);
  return CurrentDayChecklistRepository(datasource);
});

final currentDayChecklistProvider =
    FutureProvider<List<CurrentDayChecklistItem>>((ref) async {
  final session = await ref.watch(startDayControllerProvider.future);

  if (session == null) {
    return [];
  }

  final repository = ref.read(currentDayChecklistRepositoryProvider);

  return repository.getChecklistItems(
    daySessionId: session.id,
  );
});