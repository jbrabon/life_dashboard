import 'package:life_dashboard/core/utils/id_generator.dart';
import 'package:life_dashboard/current_day/repositories/current_day_checklist_repository.dart';
import 'package:life_dashboard/current_day/repositories/daily_snapshot_repository.dart';
import 'package:life_dashboard/current_day/repositories/day_session_repository.dart';
import 'package:life_dashboard/current_day/repositories/finance_repository.dart';
import 'package:life_dashboard/current_day/repositories/nutrition_repository.dart';

class FinishDayUseCase {
  FinishDayUseCase({
    required CurrentDayChecklistRepository checklistRepository,
    required FinanceRepository financeRepository,
    required NutritionRepository nutritionRepository,
    required DailySnapshotRepository dailySnapshotRepository,
    required DaySessionRepository daySessionRepository,
  })  : _checklistRepository = checklistRepository,
        _financeRepository = financeRepository,
        _nutritionRepository = nutritionRepository,
        _dailySnapshotRepository = dailySnapshotRepository,
        _daySessionRepository = daySessionRepository;

  final CurrentDayChecklistRepository _checklistRepository;
  final FinanceRepository _financeRepository;
  final NutritionRepository _nutritionRepository;
  final DailySnapshotRepository _dailySnapshotRepository;
  final DaySessionRepository _daySessionRepository;

  Future<void> execute({
    required String daySessionId,
  }) async {
    final finalizedAtUtc = DateTime.now().toUtc().toIso8601String();

    final checklistItems = await _checklistRepository.getChecklistItems(
      daySessionId: daySessionId,
    );

    final checklistTotalCount = checklistItems.length;
    final checklistCompletedCount =
        checklistItems.where((item) => item.isCompleted).length;

    final incomeCents =
        await _financeRepository.getIncomeTotalCentsForDaySession(daySessionId);

    final expenseCents =
        await _financeRepository.getExpenseTotalCentsForDaySession(daySessionId);

    final nutritionTotals =
        await _nutritionRepository.getNutritionTotalsForDaySession(daySessionId);

    await _dailySnapshotRepository.createSnapshot(
      id: IdGenerator().generate(),
      daySessionId: daySessionId,
      finalizedAtUtc: finalizedAtUtc,
      checklistTotalCount: checklistTotalCount,
      checklistCompletedCount: checklistCompletedCount,
      incomeCents: incomeCents,
      expenseCents: expenseCents,
      netCents: incomeCents - expenseCents,
      calories: nutritionTotals.calories,
      proteinGrams: nutritionTotals.proteinGrams,
      carbsGrams: nutritionTotals.carbsGrams,
      sugarGrams: nutritionTotals.sugarGrams,
      fatGrams: nutritionTotals.fatGrams,
    );

    await _daySessionRepository.closeDaySession(
      daySessionId: daySessionId,
      closedAtUtc: finalizedAtUtc,
    );
  }
}