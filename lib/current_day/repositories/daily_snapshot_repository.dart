import 'package:life_dashboard/current_day/infrastructure/daily_snapshot_local_datasource.dart';

class DailySnapshotRepository {
  DailySnapshotRepository(this._datasource);

  final DailySnapshotLocalDatasource _datasource;

  Future<void> createSnapshot({
    required String id,
    required String daySessionId,
    required String finalizedAtUtc,
    required int checklistTotalCount,
    required int checklistCompletedCount,
    required int incomeCents,
    required int expenseCents,
    required int netCents,
    required int calories,
    required int proteinGrams,
    required int carbsGrams,
    required int sugarGrams,
    required int fatGrams,
  }) {
    return _datasource.insertSnapshot(
      id: id,
      daySessionId: daySessionId,
      finalizedAtUtc: finalizedAtUtc,
      checklistTotalCount: checklistTotalCount,
      checklistCompletedCount: checklistCompletedCount,
      incomeCents: incomeCents,
      expenseCents: expenseCents,
      netCents: netCents,
      calories: calories,
      proteinGrams: proteinGrams,
      carbsGrams: carbsGrams,
      sugarGrams: sugarGrams,
      fatGrams: fatGrams,
    );
  }
}