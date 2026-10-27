import 'stats.dart';

class Validators {
  static const int maxSteps = 100000;
  static const int maxCalories = 20000;
  static const int maxWater = 10000;

  static String? date(String? v) {
    if (v == null || v.trim().isEmpty) return 'Date is required';
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(v)) return 'Use format YYYY-MM-DD';
    final d = DateTime.tryParse(v);
    if (d == null || fmtDate(d) != v) return 'Enter a valid date';
    if (d.isAfter(DateTime.now())) return 'Date cannot be in the future';
    return null;
  }

  static String? count(String? v, {required String label, required int max}) {
    if (v == null || v.trim().isEmpty) return '$label is required';
    final n = int.tryParse(v.trim());
    if (n == null) return '$label must be a whole number';
    if (n < 0) return '$label cannot be negative';
    if (n > max) return '$label cannot exceed $max';
    return null;
  }

  static String? steps(String? v) => count(v, label: 'Steps', max: maxSteps);
  static String? calories(String? v) => count(v, label: 'Calories', max: maxCalories);
  static String? water(String? v) => count(v, label: 'Water', max: maxWater);
}
