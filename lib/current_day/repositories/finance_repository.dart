import 'package:life_dashboard/current_day/infrastructure/finance_local_datasource.dart';

class FinanceRepository {
  FinanceRepository(this._datasource);

  final FinanceLocalDatasource _datasource;

  Future<void> addIncomeEntry({
    required String id,
    required String daySessionId,
    required int amountCents,
    String? note,
    required String occurredAtUtc,
    required String createdAtUtc,
  }) {
    return _datasource.insertIncomeEntry(
      id: id,
      daySessionId: daySessionId,
      amountCents: amountCents,
      note: note,
      occurredAtUtc: occurredAtUtc,
      createdAtUtc: createdAtUtc,
    );
  }

  Future<void> addExpenseEntry({
    required String id,
    required String daySessionId,
    required int amountCents,
    String? category,
    String? note,
    required String occurredAtUtc,
    required String createdAtUtc,
  }) {
    return _datasource.insertExpenseEntry(
      id: id,
      daySessionId: daySessionId,
      amountCents: amountCents,
      category: category,
      note: note,
      occurredAtUtc: occurredAtUtc,
      createdAtUtc: createdAtUtc,
    );
  }

  Future<int> getIncomeTotalCentsForDaySession(String daySessionId) {
    return _datasource.getIncomeTotalCentsForDaySession(daySessionId);
  }

  Future<int> getExpenseTotalCentsForDaySession(String daySessionId) {
    return _datasource.getExpenseTotalCentsForDaySession(daySessionId);
  }
}