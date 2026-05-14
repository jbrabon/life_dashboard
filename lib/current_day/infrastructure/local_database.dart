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
      },
    );
  }
}