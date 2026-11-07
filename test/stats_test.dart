import 'package:flutter_test/flutter_test.dart';
import 'package:healthmate/core/stats.dart';
import 'package:healthmate/models/health_record.dart';

void main() {
  final now = DateTime(2026, 10, 10);
  HealthRecord r(String d, int s) => HealthRecord(date: d, steps: s, calories: 0, water: 0);
  int steps(HealthRecord x) => x.steps;

  test('empty dataset', () {
    final w = Stats.window([], now, 7);
    expect(w.length, 7);
    expect(Stats.average(w, steps), isNull);
    expect(Stats.best(w, steps), isNull);
  });

  test('missing days are skipped in average; zero counts', () {
    final w = Stats.window([r('2026-10-10', 1000), r('2026-10-08', 0)], now, 7);
    expect(w.whereType<HealthRecord>().length, 2);
    expect(Stats.average(w, steps), 500);
    expect(Stats.best(w, steps)!.date, '2026-10-10');
  });

  test('change vs previous period', () {
    expect(Stats.changePct(150, 100), 50);
    expect(Stats.changePct(150, null), isNull);
    expect(Stats.changePct(150, 0), isNull);
  });

  test('goal percentage', () {
    expect(Stats.goalPct(5000, 10000), 50);
    expect(Stats.goalPct(5, 0), 0);
  });
}
