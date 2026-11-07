import 'package:flutter_test/flutter_test.dart';
import 'package:healthmate/data/database_helper.dart';
import 'package:healthmate/data/health_repository.dart';
import 'package:healthmate/models/health_record.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  late HealthRepository repo;

  HealthRecord rec(String d, [int s = 1000, int c = 100, int w = 500]) =>
      HealthRecord(date: d, steps: s, calories: c, water: w);

  late Database db;

  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: DatabaseHelper.version,
        onCreate: DatabaseHelper.onCreate,
        singleInstance: false,
      ),
    );
    repo = HealthRepository(() async => db);
  });

  tearDown(() async => db.close());

  test('empty dataset returns empty list', () async => expect(await repo.getAll(), isEmpty));

  test('create and read', () async {
    final id = await repo.insert(rec('2026-10-01', 7850, 420, 2000));
    final r = await repo.getById(id);
    expect(r!.steps, 7850);
    expect(r.calories, 420);
    expect(r.water, 2000);
  });

  test('duplicate date throws', () async {
    await repo.insert(rec('2026-10-01'));
    await expectLater(() => repo.insert(rec('2026-10-01')), throwsA(isA<DuplicateDateException>()));
  });

  test('update', () async {
    final id = await repo.insert(rec('2026-10-01'));
    await repo.update(HealthRecord(id: id, date: '2026-10-01', steps: 5, calories: 6, water: 7));
    expect((await repo.getById(id))!.steps, 5);
  });

  test('update to an existing date throws', () async {
    await repo.insert(rec('2026-10-01'));
    final id = await repo.insert(rec('2026-10-02'));
    expect(() => repo.update(HealthRecord(id: id, date: '2026-10-01', steps: 1, calories: 1, water: 1)),
        throwsA(isA<DuplicateDateException>()));
  });

  test('delete', () async {
    final id = await repo.insert(rec('2026-10-01'));
    await repo.delete(id);
    expect(await repo.getById(id), isNull);
  });

  test('search, range filter and sort', () async {
    await repo.insert(rec('2026-09-30', 300));
    await repo.insert(rec('2026-10-01', 100));
    await repo.insert(rec('2026-10-02', 200));
    expect((await repo.getAll(const RecordQuery(search: '2026-10'))).length, 2);
    expect((await repo.getAll(const RecordQuery(from: '2026-10-01', to: '2026-10-01'))).length, 1);
    final bySteps = await repo.getAll(const RecordQuery(sortBy: 'steps', desc: false));
    expect(bySteps.map((r) => r.steps), [100, 200, 300]);
    expect(await repo.getAll(const RecordQuery(search: '1999')), isEmpty);
  });
}
