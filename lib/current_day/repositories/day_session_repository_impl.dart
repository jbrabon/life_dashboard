import 'package:life_dashboard/core/utils/id_generator.dart';
import 'package:life_dashboard/current_day/domain/entities/day_session.dart';
import 'package:life_dashboard/current_day/domain/value_objects/day_context.dart';
import 'package:life_dashboard/current_day/infrastructure/day_session_local_datasource.dart';
import 'package:life_dashboard/current_day/repositories/day_session_repository.dart';

class DaySessionRepositoryImpl implements DaySessionRepository {
  DaySessionRepositoryImpl({
    required this.localDatasource,
    required this.idGenerator,
  });

  final DaySessionLocalDatasource localDatasource;
  final IdGenerator idGenerator;

  @override
  Future<DaySession?> getOpenDaySession() {
    return localDatasource.getOpenDaySession();
  }

  @override
  Future<DaySession> startDay(DayContext context) {
    final id = idGenerator.generate();

    return localDatasource.startDay(
      id: id,
      context: context,
    );
  }

  @override
  Future<void> closeDaySession({
    required String daySessionId,
    required String closedAtUtc,
  }) {
    return localDatasource.closeDaySession(
      daySessionId: daySessionId,
      closedAtUtc: closedAtUtc,
    );
  }
}