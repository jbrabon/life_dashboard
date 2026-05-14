import 'package:life_dashboard/current_day/domain/entities/day_session.dart';
import 'package:life_dashboard/current_day/domain/value_objects/day_context.dart';
import 'package:life_dashboard/current_day/repositories/day_session_repository.dart';

class StartDayUseCase {
  final DaySessionRepository repository;

  StartDayUseCase({
    required this.repository,
  });

  Future<DaySession> call(DayContext context) async {
    final existing = await repository.getOpenDaySession();

    if (existing != null) {
      return existing;
    }

    return repository.startDay(context);
  }
}