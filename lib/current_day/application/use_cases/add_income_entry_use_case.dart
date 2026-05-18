import 'package:life_dashboard/core/utils/id_generator.dart';
import 'package:life_dashboard/current_day/repositories/finance_repository.dart';

class AddIncomeEntryUseCase {
  AddIncomeEntryUseCase(this._repository);

  final FinanceRepository _repository;

  Future<void> execute({
    required String daySessionId,
    required int amountCents,
    String? note,
  }) async {
    final nowUtc = DateTime.now().toUtc().toIso8601String();

    await _repository.addIncomeEntry(
      id: IdGenerator().generate(),
      daySessionId: daySessionId,
      amountCents: amountCents,
      note: note,
      occurredAtUtc: nowUtc,
      createdAtUtc: nowUtc,
    );
  }
}