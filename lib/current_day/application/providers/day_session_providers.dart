import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_dashboard/core/utils/id_generator.dart';
import 'package:life_dashboard/current_day/application/use_cases/get_open_day_session_use_case.dart';
import 'package:life_dashboard/current_day/application/use_cases/start_day_use_case.dart';
import 'package:life_dashboard/current_day/domain/entities/day_session.dart';
import 'package:life_dashboard/current_day/domain/value_objects/day_context.dart';
import 'package:life_dashboard/current_day/infrastructure/day_session_local_datasource.dart';
import 'package:life_dashboard/current_day/repositories/day_session_repository.dart';
import 'package:life_dashboard/current_day/repositories/day_session_repository_impl.dart';

final idGeneratorProvider = Provider((ref) {
  return IdGenerator();
});

final daySessionLocalDatasourceProvider = Provider((ref) {
  return DaySessionLocalDatasource();
});

final daySessionRepositoryProvider = Provider<DaySessionRepository>((ref) {
  return DaySessionRepositoryImpl(
    localDatasource: ref.read(daySessionLocalDatasourceProvider),
    idGenerator: ref.read(idGeneratorProvider),
  );
});

final getOpenDaySessionUseCaseProvider = Provider((ref) {
  return GetOpenDaySessionUseCase(
    repository: ref.read(daySessionRepositoryProvider),
  );
});

final startDayUseCaseProvider = Provider((ref) {
  return StartDayUseCase(
    repository: ref.read(daySessionRepositoryProvider),
  );
});

class StartDayController extends AsyncNotifier<DaySession?> {
  @override
  Future<DaySession?> build() async {
    final getOpenDaySession = ref.read(getOpenDaySessionUseCaseProvider);
    return getOpenDaySession();
  }

  Future<void> startDay(DayContext context) async {
    final startDay = ref.read(startDayUseCaseProvider);

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      return startDay(context);
    });
  }
}

final startDayControllerProvider =
    AsyncNotifierProvider<StartDayController, DaySession?>(
  StartDayController.new,
);