import 'package:flutter_test/flutter_test.dart';
import 'package:healthmate/data/database_helper.dart';
import 'package:healthmate/data/health_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  test('demo data is seeded once and does not duplicate', () async {
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath,
        options: OpenDatabaseOptions(
            version: DatabaseHelper.version,
            onCreate: DatabaseHelper.onCreate,
            singleInstance: false));
    final repo = HealthRepository(() async => db);
    await repo.seedDemo();
    expect((await repo.getAll()).length, 14);
    await repo.seedDemo();
    expect((await repo.getAll()).length, 14);
  });
}
