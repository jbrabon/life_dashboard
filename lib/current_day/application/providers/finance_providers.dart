import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_dashboard/current_day/application/providers/day_session_providers.dart';
import 'package:life_dashboard/current_day/application/use_cases/add_income_entry_use_case.dart';
import 'package:life_dashboard/current_day/infrastructure/finance_local_datasource.dart';
import 'package:life_dashboard/current_day/repositories/finance_repository.dart';

final financeLocalDatasourceProvider = Provider((ref) {
  return FinanceLocalDatasource();
});

final financeRepositoryProvider = Provider((ref) {
  final datasource = ref.read(financeLocalDatasourceProvider);
  return FinanceRepository(datasource);
});

final addIncomeEntryUseCaseProvider = Provider((ref) {
  final repository = ref.read(financeRepositoryProvider);
  return AddIncomeEntryUseCase(repository);
});

final currentDayIncomeTotalCentsProvider = FutureProvider<int>((ref) async {
  final session = await ref.watch(startDayControllerProvider.future);

  if (session == null) {
    return 0;
  }

  final repository = ref.read(financeRepositoryProvider);

  return repository.getIncomeTotalCentsForDaySession(session.id);
});

class FinanceEntryController {
  FinanceEntryController(this._ref);

  final Ref _ref;

  Future<void> addIncome({
    required String daySessionId,
    required int amountCents,
    String? note,
  }) async {
    final useCase = _ref.read(addIncomeEntryUseCaseProvider);

    await useCase.execute(
      daySessionId: daySessionId,
      amountCents: amountCents,
      note: note,
    );

    _ref.invalidate(currentDayIncomeTotalCentsProvider);
  }
}

final financeEntryControllerProvider = Provider((ref) {
  return FinanceEntryController(ref);
});