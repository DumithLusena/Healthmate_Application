import 'package:intl/intl.dart';
import '../models/health_record.dart';

String fmtDate(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

class Stats {
  static List<HealthRecord?> window(List<HealthRecord> all, DateTime end, int days) {
    final byDate = {for (final r in all) r.date: r};
    return [
      for (var i = days - 1; i >= 0; i--) byDate[fmtDate(DateTime(end.year, end.month, end.day - i))]
    ];
  }

  static double? average(List<HealthRecord?> w, int Function(HealthRecord) f) {
    final v = [for (final r in w) if (r != null) f(r)];
    return v.isEmpty ? null : v.reduce((a, b) => a + b) / v.length;
  }

  static HealthRecord? best(List<HealthRecord?> w, int Function(HealthRecord) f) {
    HealthRecord? b;
    for (final r in w) {
      if (r != null && (b == null || f(r) > f(b))) b = r;
    }
    return b;
  }

  static double? changePct(double? cur, double? prev) =>
      (cur == null || prev == null || prev == 0) ? null : (cur - prev) / prev * 100;

  static double goalPct(int value, int goal) => goal <= 0 ? 0 : value / goal * 100;
}
