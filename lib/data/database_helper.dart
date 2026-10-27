import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../core/stats.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static const String dbName = 'healthmate.db';
  static const int version = 1;
  static const String table = 'health_records';

  Database? _db;
  Future<Database>? _opening;

  Future<Database> get database async {
    if (_db != null) return _db!;
    return _opening ??= _open();
  }

  Future<Database> _open() async {
    final path = p.join(await getDatabasesPath(), dbName);
    final db = await openDatabase(
      path,
      version: version,
      onCreate: (db, v) async {
        await onCreate(db, v);
        await seedDemoData(db);
      },
      onUpgrade: onUpgrade,
    );
    _db = db;
    return db;
  }

  static Future<void> onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL UNIQUE,
        steps INTEGER NOT NULL CHECK (steps >= 0),
        calories INTEGER NOT NULL CHECK (calories >= 0),
        water INTEGER NOT NULL CHECK (water >= 0)
      )
    ''');
  }

  static Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Future schema migrations go here.
  }

  static const _steps = [7850, 9120, 6430, 10250, 5800, 8740, 11200, 7300, 6900, 9560, 8100, 4980, 10780, 8420];
  static const _calories = [420, 510, 360, 560, 310, 470, 610, 400, 380, 520, 440, 280, 590, 450];
  static const _water = [2000, 2400, 1800, 2600, 1500, 2200, 2800, 1900, 2000, 2500, 2100, 1400, 2700, 2300];

  static Future<void> seedDemoData(DatabaseExecutor db) async {
    final now = DateTime.now();
    for (var i = 0; i < _steps.length; i++) {
      final d = DateTime(now.year, now.month, now.day - i);
      await db.insert(
        table,
        {'date': fmtDate(d), 'steps': _steps[i], 'calories': _calories[i], 'water': _water[i]},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }
}
