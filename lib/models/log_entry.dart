class LogEntry {
  final int? id;
  final String date;
  final String name;
  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double servings;

  const LogEntry({
    this.id,
    required this.date,
    required this.name,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    this.servings = 1.0,
  });

  double get totalCalories => calories * servings;
  double get totalProtein => proteinG * servings;
  double get totalCarbs => carbsG * servings;
  double get totalFat => fatG * servings;

  LogEntry copyWith({
    int? id,
    String? date,
    String? name,
    double? calories,
    double? proteinG,
    double? carbsG,
    double? fatG,
    double? servings,
  }) =>
      LogEntry(
        id: id ?? this.id,
        date: date ?? this.date,
        name: name ?? this.name,
        calories: calories ?? this.calories,
        proteinG: proteinG ?? this.proteinG,
        carbsG: carbsG ?? this.carbsG,
        fatG: fatG ?? this.fatG,
        servings: servings ?? this.servings,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'date': date,
        'name': name,
        'calories': calories,
        'protein_g': proteinG,
        'carbs_g': carbsG,
        'fat_g': fatG,
        'servings': servings,
      };

  factory LogEntry.fromMap(Map<String, dynamic> map) => LogEntry(
        id: map['id'] as int?,
        date: map['date'] as String,
        name: map['name'] as String,
        calories: (map['calories'] as num).toDouble(),
        proteinG: (map['protein_g'] as num).toDouble(),
        carbsG: (map['carbs_g'] as num).toDouble(),
        fatG: (map['fat_g'] as num).toDouble(),
        servings: (map['servings'] as num).toDouble(),
      );
}
