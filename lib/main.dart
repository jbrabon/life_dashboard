import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_dashboard/current_day/application/providers/current_day_checklist_providers.dart';
import 'package:life_dashboard/current_day/application/providers/day_session_providers.dart';
import 'package:life_dashboard/current_day/application/read_models/obligation_classification.dart';
import 'package:life_dashboard/current_day/domain/value_objects/day_context.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Life Dashboard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final Set<String> _completedItemIds = {};

  bool _isItemCompleted(dynamic item) {
    return _completedItemIds.contains(item.id) || item.isCompleted == true;
  }

  void _toggleItem(dynamic item) {
    setState(() {
      if (_isItemCompleted(item)) {
        _completedItemIds.remove(item.id);
      } else {
        _completedItemIds.add(item.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(startDayControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Life Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: sessionState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Text('Error: $error'),
          data: (session) {
            if (session == null) {
              return Center(
                child: ElevatedButton(
                  onPressed: () {
                    final now = DateTime.now().toUtc();

                    final dayContext = DayContext(
                      startedAtUtc: now,
                      logicalDate: now.toIso8601String().split('T').first,
                      timezone: now.timeZoneName,
                    );

                    ref
                        .read(startDayControllerProvider.notifier)
                        .startDay(dayContext);
                  },
                  child: const Text('Start Day'),
                ),
              );
            }

            final checklistAsync = ref.watch(currentDayChecklistProvider);

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Open Day Session',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('ID: ${session.id}'),
                  const SizedBox(height: 8),
                  Text(
                    'Started At UTC: ${session.startedAtUtc.toIso8601String()}',
                  ),
                  const SizedBox(height: 8),
                  Text('Logical Date: ${session.logicalDate}'),
                  const SizedBox(height: 8),
                  Text('Timezone: ${session.timezone}'),
                  const SizedBox(height: 24),
                  const Text(
                    'Checklist',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  checklistAsync.when(
                    loading: () => const CircularProgressIndicator(),
                    error: (error, stackTrace) => Text('Error: $error'),
                    data: (items) {
                      final overdue = items
                          .where(
                            (item) =>
                                item.obligationClassification ==
                                ObligationClassification.overdue,
                          )
                          .toList();

                      final dueToday = items
                          .where(
                            (item) =>
                                item.obligationClassification ==
                                ObligationClassification.dueToday,
                          )
                          .toList();

                      final notDueToday = items
                          .where(
                            (item) =>
                                item.obligationClassification ==
                                ObligationClassification.notDueToday,
                          )
                          .toList();

                      final future = items
                          .where(
                            (item) =>
                                item.obligationClassification ==
                                ObligationClassification.future,
                          )
                          .toList();

                      Widget section(String title, List<dynamic> sectionItems) {
                        if (sectionItems.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            for (final item in sectionItems)
                              GestureDetector(
                                onTap: () => _toggleItem(item),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Text(
                                    '- ${item.title}',
                                    style: TextStyle(
                                      decoration: _isItemCompleted(item)
                                          ? TextDecoration.lineThrough
                                          : null,
                                      color: _isItemCompleted(item)
                                          ? Colors.grey
                                          : null,
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 16),
                          ],
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          section('Overdue', overdue),
                          section('Due Today', dueToday),
                          section('Not Due Today', notDueToday),
                          section('Future', future),
                        ],
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}