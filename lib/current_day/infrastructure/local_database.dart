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
  updated_at_utc TEXT NOT NULL
)
''');
      },
    );
  }
}