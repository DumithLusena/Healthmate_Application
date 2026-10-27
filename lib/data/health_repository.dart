import 'package:sqflite/sqflite.dart';
import '../models/health_record.dart';
import 'database_helper.dart';

class HealthRepository {
  HealthRepository(this._db);

  final Future<Database> Function() _db;

  static const _table = DatabaseHelper.table;
  static const _sortable = {'date', 'steps', 'calories', 'water'};

  Map<String, Object?> _data(HealthRecord r) => Map<String, Object?>.from(r.toMap())..remove('id');

  Future<int> insert(HealthRecord r) async {
    final db = await _db();
    if (await getByDate(r.date) != null) throw DuplicateDateException(r.date);
    try {
      return await db.insert(_table, _data(r));
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) throw DuplicateDateException(r.date);
      rethrow;
    }
  }

  Future<List<HealthRecord>> getAll([RecordQuery q = const RecordQuery()]) async {
    final db = await _db();
    final where = <String>[];
    final args = <Object?>[];
    if (q.search.isNotEmpty) {
      where.add('date LIKE ?');
      args.add('%${q.search}%');
    }
    if (q.from != null) {
      where.add('date >= ?');
      args.add(q.from);
    }
    if (q.to != null) {
      where.add('date <= ?');
      args.add(q.to);
    }
    final col = _sortable.contains(q.sortBy) ? q.sortBy : 'date';
    final rows = await db.query(
      _table,
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: '$col ${q.desc ? 'DESC' : 'ASC'}, date DESC',
    );
    return rows.map(HealthRecord.fromMap).toList();
  }

  Future<HealthRecord?> getById(int id) async {
    final db = await _db();
    final rows = await db.query(_table, where: 'id = ?', whereArgs: [id], limit: 1);
    return rows.isEmpty ? null : HealthRecord.fromMap(rows.first);
  }

  Future<HealthRecord?> getByDate(String date) async {
    final db = await _db();
    final rows = await db.query(_table, where: 'date = ?', whereArgs: [date], limit: 1);
    return rows.isEmpty ? null : HealthRecord.fromMap(rows.first);
  }

  Future<int> update(HealthRecord r) async {
    final id = r.id;
    if (id == null) return 0;
    final db = await _db();
    final clash = await db.query(_table, where: 'date = ? AND id != ?', whereArgs: [r.date, id], limit: 1);
    if (clash.isNotEmpty) throw DuplicateDateException(r.date);
    return db.update(_table, _data(r), where: 'id = ?', whereArgs: [id]);
  }

  Future<int> delete(int id) async {
    final db = await _db();
    return db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> seedDemo() async => DatabaseHelper.seedDemoData(await _db());
}