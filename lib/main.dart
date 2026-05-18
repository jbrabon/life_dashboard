import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_dashboard/current_day/application/providers/checklist_completion_controller.dart';
import 'package:life_dashboard/current_day/application/providers/current_day_checklist_providers.dart';
import 'package:life_dashboard/current_day/application/providers/day_session_providers.dart';
import 'package:life_dashboard/current_day/application/providers/finance_providers.dart';
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

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _incomeAmountController = TextEditingController();
  final TextEditingController _incomeNoteController = TextEditingController();
  final TextEditingController _expenseAmountController = TextEditingController();
  final TextEditingController _expenseCategoryController =
      TextEditingController();
  final TextEditingController _expenseNoteController = TextEditingController();

  @override
  void dispose() {
    _incomeAmountController.dispose();
    _incomeNoteController.dispose();
    _expenseAmountController.dispose();
    _expenseCategoryController.dispose();
    _expenseNoteController.dispose();
    super.dispose();
  }

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

  int? _parseAmountToCents(String value) {
    final cleaned = value.trim().replaceAll(',', '');

    if (cleaned.isEmpty) {
      return null;
    }

    final parsed = double.tryParse(cleaned);

    if (parsed == null || parsed <= 0) {
      return null;
    }

    return (parsed * 100).round();
  }

  String _formatCents(int cents) {
    final dollars = cents / 100;
    return '\$${dollars.toStringAsFixed(2)}';
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
            final incomeTotalAsync =
                ref.watch(currentDayIncomeTotalCentsProvider);
            final expenseTotalAsync =
                ref.watch(currentDayExpenseTotalCentsProvider);
            final netTotalAsync = ref.watch(currentDayNetTotalCentsProvider);

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
                    'Finance',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  incomeTotalAsync.when(
                    loading: () => const Text('Today Income: Loading...'),
                    error: (error, stackTrace) =>
                        Text('Today Income Error: $error'),
                    data: (incomeTotalCents) {
                      return Text(
                        'Today Income: ${_formatCents(incomeTotalCents)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  expenseTotalAsync.when(
                    loading: () => const Text('Today Expenses: Loading...'),
                    error: (error, stackTrace) =>
                        Text('Today Expenses Error: $error'),
                    data: (expenseTotalCents) {
                      return Text(
                        'Today Expenses: ${_formatCents(expenseTotalCents)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  netTotalAsync.when(
                    loading: () => const Text('Today Net: Loading...'),
                    error: (error, stackTrace) =>
                        Text('Today Net Error: $error'),
                    data: (netTotalCents) {
                      return Text(
                        'Today Net: ${_formatCents(netTotalCents)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _incomeAmountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}'),
                      ),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Income amount',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _incomeNoteController,
                    decoration: const InputDecoration(
                      labelText: 'Income note (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () async {
                      final amountCents =
                          _parseAmountToCents(_incomeAmountController.text);

                      if (amountCents == null) {
                        return;
                      }

                      await ref.read(financeEntryControllerProvider).addIncome(
                            daySessionId: session.id,
                            amountCents: amountCents,
                            note: _incomeNoteController.text.trim().isEmpty
                                ? null
                                : _incomeNoteController.text.trim(),
                          );

                      _incomeAmountController.clear();
                      _incomeNoteController.clear();
                    },
                    child: const Text('Add Income'),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _expenseAmountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}'),
                      ),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Expense amount',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _expenseCategoryController,
                    decoration: const InputDecoration(
                      labelText: 'Expense category (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _expenseNoteController,
                    decoration: const InputDecoration(
                      labelText: 'Expense note (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () async {
                      final amountCents =
                          _parseAmountToCents(_expenseAmountController.text);

                      if (amountCents == null) {
                        return;
                      }

                      await ref.read(financeEntryControllerProvider).addExpense(
                            daySessionId: session.id,
                            amountCents: amountCents,
                            category:
                                _expenseCategoryController.text.trim().isEmpty
                                    ? null
                                    : _expenseCategoryController.text.trim(),
                            note: _expenseNoteController.text.trim().isEmpty
                                ? null
                                : _expenseNoteController.text.trim(),
                          );

                      _expenseAmountController.clear();
                      _expenseCategoryController.clear();
                      _expenseNoteController.clear();
                    },
                    child: const Text('Add Expense'),
                  ),
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