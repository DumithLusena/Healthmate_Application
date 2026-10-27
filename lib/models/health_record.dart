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

class RecordQuery {
  const RecordQuery({this.search = '', this.from, this.to, this.sortBy = 'date', this.desc = true});
  final String search;
  final String? from;
  final String? to;
  final String sortBy;
  final bool desc;

  bool get isFiltered => search.isNotEmpty || from != null || to != null;

  RecordQuery copyWith({String? search, String? sortBy, bool? desc, String? from, String? to, bool clearRange = false}) =>
      RecordQuery(
        search: search ?? this.search,
        sortBy: sortBy ?? this.sortBy,
        desc: desc ?? this.desc,
        from: clearRange ? null : (from ?? this.from),
        to: clearRange ? null : (to ?? this.to),
      );
}