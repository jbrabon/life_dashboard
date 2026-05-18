import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_dashboard/current_day/application/providers/day_session_providers.dart';
import 'package:life_dashboard/current_day/application/use_cases/add_expense_entry_use_case.dart';
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

final addExpenseEntryUseCaseProvider = Provider((ref) {
  final repository = ref.read(financeRepositoryProvider);
  return AddExpenseEntryUseCase(repository);
});

final currentDayIncomeTotalCentsProvider = FutureProvider<int>((ref) async {
  final session = await ref.watch(startDayControllerProvider.future);

  if (session == null) {
    return 0;
  }

  final repository = ref.read(financeRepositoryProvider);
  return repository.getIncomeTotalCentsForDaySession(session.id);
});

final currentDayExpenseTotalCentsProvider = FutureProvider<int>((ref) async {
  final session = await ref.watch(startDayControllerProvider.future);

  if (session == null) {
    return 0;
  }

  final repository = ref.read(financeRepositoryProvider);
  return repository.getExpenseTotalCentsForDaySession(session.id);
});

final currentDayNetTotalCentsProvider = FutureProvider<int>((ref) async {
  final income = await ref.watch(currentDayIncomeTotalCentsProvider.future);
  final expenses = await ref.watch(currentDayExpenseTotalCentsProvider.future);

  return income - expenses;
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
    _ref.invalidate(currentDayNetTotalCentsProvider);
  }

  Future<void> addExpense({
    required String daySessionId,
    required int amountCents,
    String? category,
    String? note,
  }) async {
    final useCase = _ref.read(addExpenseEntryUseCaseProvider);

    await useCase.execute(
      daySessionId: daySessionId,
      amountCents: amountCents,
      category: category,
      note: note,
    );

    _ref.invalidate(currentDayExpenseTotalCentsProvider);
    _ref.invalidate(currentDayNetTotalCentsProvider);
  }
}

final financeEntryControllerProvider = Provider((ref) {
  return FinanceEntryController(ref);
});