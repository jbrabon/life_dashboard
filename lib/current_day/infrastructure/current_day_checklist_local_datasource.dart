import 'package:life_dashboard/current_day/application/read_models/current_day_checklist_item.dart';
import 'package:life_dashboard/current_day/application/read_models/obligation_classification.dart';
import 'package:life_dashboard/current_day/infrastructure/local_database.dart';
import 'package:sqflite/sqflite.dart';

class CurrentDayChecklistLocalDatasource {
  Future<Database> get _db async => LocalDatabase.instance;

  Future<List<CurrentDayChecklistItem>> getChecklistItems({
    required String daySessionId,
  }) async {
    final completionMap = await getCompletionMap(daySessionId);

    final seedItems = [
      CurrentDayChecklistItem(
        id: '1',
        type: CurrentDayChecklistItemType.habit,
        title: 'Workout',
        isCompleted: false,
        obligationClassification: ObligationClassification.dueToday,
      ),
      CurrentDayChecklistItem(
        id: '2',
        type: CurrentDayChecklistItemType.habit,
        title: 'Read',
        isCompleted: false,
        obligationClassification: ObligationClassification.notDueToday,
      ),
    ];

    return seedItems.map((item) {
      return CurrentDayChecklistItem(
        id: item.id,
        type: item.type,
        title: item.title,
        isCompleted: completionMap[item.id] ?? false,
        obligationClassification: item.obligationClassification,
      );
    }).toList();
  }

  Future<void> upsertCompletion({
    required String id,
    required String daySessionId,
    required String itemId,
    required String itemType,
    required bool isCompleted,
    required String updatedAtUtc,
    String? completedAtUtc,
  }) async {
    final db = await _db;

    await db.insert(
      'checklist_completion',
      {
        'id': id,
        'day_session_id': daySessionId,
        'item_id': itemId,
        'item_type': itemType,
        'is_completed': isCompleted ? 1 : 0,
        'completed_at_utc': completedAtUtc,
        'updated_at_utc': updatedAtUtc,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, bool>> getCompletionMap(String daySessionId) async {
    final db = await _db;

    final results = await db.query(
      'checklist_completion',
      where: 'day_session_id = ?',
      whereArgs: [daySessionId],
    );

    final map = <String, bool>{};

    for (final row in results) {
      map[row['item_id'] as String] = (row['is_completed'] as int) == 1;
    }

    return map;
  }
}