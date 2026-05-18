import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_dashboard/current_day/application/providers/checklist_completion_controller.dart';
import 'package:life_dashboard/current_day/application/providers/current_day_checklist_providers.dart';
import 'package:life_dashboard/current_day/application/providers/day_session_providers.dart';
import 'package:life_dashboard/current_day/application/read_models/current_day_checklist_item.dart';
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

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _itemTypeValue(CurrentDayChecklistItem item) {
    switch (item.type) {
      case CurrentDayChecklistItemType.habit:
        return 'habit';
      case CurrentDayChecklistItemType.todo:
        return 'todo';
    }
  }

  List<CurrentDayChecklistItem> _incompleteFirst(
    List<CurrentDayChecklistItem> items,
  ) {
    final incomplete = items.where((item) => !item.isCompleted).toList();
    final completed = items.where((item) => item.isCompleted).toList();

    return [...incomplete, ...completed];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

                    final context = DayContext(
                      startedAtUtc: now,
                      logicalDate: now.toIso8601String().split('T').first,
                      timezone: now.timeZoneName,
                    );

                    ref
                        .read(startDayControllerProvider.notifier)
                        .startDay(context);
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
                      final overdue = _incompleteFirst(
                        items
                            .where(
                              (item) =>
                                  item.obligationClassification ==
                                  ObligationClassification.overdue,
                            )
                            .toList(),
                      );

                      final dueToday = _incompleteFirst(
                        items
                            .where(
                              (item) =>
                                  item.obligationClassification ==
                                  ObligationClassification.dueToday,
                            )
                            .toList(),
                      );

                      final notDueToday = _incompleteFirst(
                        items
                            .where(
                              (item) =>
                                  item.obligationClassification ==
                                  ObligationClassification.notDueToday,
                            )
                            .toList(),
                      );

                      final future = _incompleteFirst(
                        items
                            .where(
                              (item) =>
                                  item.obligationClassification ==
                                  ObligationClassification.future,
                            )
                            .toList(),
                      );

                      Widget buildItem(CurrentDayChecklistItem item) {
                        return InkWell(
                          onTap: () async {
                            await ref
                                .read(checklistCompletionControllerProvider)
                                .toggleCompletion(
                                  daySessionId: session.id,
                                  itemId: item.id,
                                  itemType: _itemTypeValue(item),
                                  isCompleted: !item.isCompleted,
                                );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              '- ${item.title}',
                              style: TextStyle(
                                color: item.isCompleted ? Colors.grey : null,
                                decoration: item.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ),
                        );
                      }

                      Widget section(
                        String title,
                        List<CurrentDayChecklistItem> sectionItems,
                      ) {
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
                            ...sectionItems.map(buildItem),
                            const SizedBox(height: 16),
                          ],
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          section('Overdue', overdue),
                          section('Due Today', dueToday),
                          section('Habits Not Due Today', notDueToday),
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