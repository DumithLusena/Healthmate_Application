class HealthRecord {
  const HealthRecord({
    this.id,
    required this.date,
    required this.steps,
    required this.calories,
    required this.water,
  });

  final int? id;
  final String date;
  final int steps;
  final int calories;
  final int water;

  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'date': date,
    'steps': steps,
    'calories': calories,
    'water': water,
  };

  factory HealthRecord.fromMap(Map<String, Object?> m) => HealthRecord(
    id: m['id'] as int?,
    date: m['date'] as String,
    steps: m['steps'] as int,
    calories: m['calories'] as int,
    water: m['water'] as int,
  );
}

class DuplicateDateException implements Exception {
  DuplicateDateException(this.date);
  final String date;
  @override
  String toString() => 'A record for $date already exists';
}