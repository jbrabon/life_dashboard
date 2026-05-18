import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_dashboard/current_day/application/providers/current_day_checklist_providers.dart';
import 'package:life_dashboard/current_day/application/providers/day_session_providers.dart';
import 'package:life_dashboard/current_day/application/providers/finance_providers.dart';
import 'package:life_dashboard/current_day/application/providers/nutrition_providers.dart';
import 'package:life_dashboard/current_day/application/use_cases/finish_day_use_case.dart';
import 'package:life_dashboard/current_day/infrastructure/daily_snapshot_local_datasource.dart';
import 'package:life_dashboard/current_day/repositories/daily_snapshot_repository.dart';

final dailySnapshotLocalDatasourceProvider = Provider((ref) {
  return DailySnapshotLocalDatasource();
});

final dailySnapshotRepositoryProvider = Provider((ref) {
  final datasource = ref.read(dailySnapshotLocalDatasourceProvider);
  return DailySnapshotRepository(datasource);
});

final finishDayUseCaseProvider = Provider((ref) {
  return FinishDayUseCase(
    checklistRepository: ref.read(currentDayChecklistRepositoryProvider),
    financeRepository: ref.read(financeRepositoryProvider),
    nutritionRepository: ref.read(nutritionRepositoryProvider),
    dailySnapshotRepository: ref.read(dailySnapshotRepositoryProvider),
    daySessionRepository: ref.read(daySessionRepositoryProvider),
  );
});

class FinishDayController {
  FinishDayController(this._ref);

  final Ref _ref;

  Future<void> finishDay({
    required String daySessionId,
  }) async {
    final useCase = _ref.read(finishDayUseCaseProvider);

    await useCase.execute(daySessionId: daySessionId);

    _ref.invalidate(startDayControllerProvider);
    _ref.invalidate(currentDayChecklistProvider);
  }
}

final finishDayControllerProvider = Provider((ref) {
  return FinishDayController(ref);
});