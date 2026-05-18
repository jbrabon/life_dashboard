import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalDatabase {
  static Database? _db;

  static Future<Database> get instance async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'life_dashboard.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
CREATE TABLE day_sessions (
  id TEXT PRIMARY KEY,
  started_at_utc TEXT NOT NULL,
  closed_at_utc TEXT,
  logical_date TEXT NOT NULL,
  timezone TEXT NOT NULL
)
''');

        await db.execute('''
CREATE TABLE checklist_completion (
  id TEXT PRIMARY KEY,
  day_session_id TEXT NOT NULL,
  item_id TEXT NOT NULL,
  item_type TEXT NOT NULL,
  is_completed INTEGER NOT NULL,
  completed_at_utc TEXT,
  updated_at_utc TEXT NOT NULL,
  UNIQUE(day_session_id, item_id)
)
''');

        await db.execute('''
CREATE TABLE finance_income_entries (
  id TEXT PRIMARY KEY,
  day_session_id TEXT NOT NULL,
  amount_cents INTEGER NOT NULL,
  note TEXT,
  occurred_at_utc TEXT NOT NULL,
  created_at_utc TEXT NOT NULL
)
''');

        await db.execute('''
CREATE TABLE finance_expense_entries (
  id TEXT PRIMARY KEY,
  day_session_id TEXT NOT NULL,
  amount_cents INTEGER NOT NULL,
  category TEXT,
  note TEXT,
  occurred_at_utc TEXT NOT NULL,
  created_at_utc TEXT NOT NULL
)
''');

        await db.execute('''
CREATE TABLE nutrition_entries (
  id TEXT PRIMARY KEY,
  day_session_id TEXT NOT NULL,
  calories INTEGER NOT NULL,
  protein_grams INTEGER NOT NULL,
  carbs_grams INTEGER NOT NULL,
  sugar_grams INTEGER NOT NULL,
  fat_grams INTEGER NOT NULL,
  created_at_utc TEXT NOT NULL
)
''');

        await db.execute('''
CREATE TABLE daily_snapshots (
  id TEXT PRIMARY KEY,
  day_session_id TEXT NOT NULL UNIQUE,
  finalized_at_utc TEXT NOT NULL,

  checklist_total_count INTEGER NOT NULL,
  checklist_completed_count INTEGER NOT NULL,

  finance_income_cents INTEGER NOT NULL,
  finance_expense_cents INTEGER NOT NULL,
  finance_net_cents INTEGER NOT NULL,

  nutrition_calories INTEGER NOT NULL,
  nutrition_protein_grams INTEGER NOT NULL,
  nutrition_carbs_grams INTEGER NOT NULL,
  nutrition_sugar_grams INTEGER NOT NULL,
  nutrition_fat_grams INTEGER NOT NULL
)
''');
      },
    );
  }
}