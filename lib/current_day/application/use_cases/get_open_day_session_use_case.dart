import 'package:life_dashboard/current_day/domain/entities/day_session.dart';
import 'package:life_dashboard/current_day/repositories/day_session_repository.dart';

class GetOpenDaySessionUseCase {
  final DaySessionRepository repository;

  GetOpenDaySessionUseCase({
    required this.repository,
  });

  Future<DaySession?> call() {
    return repository.getOpenDaySession();
  }
}