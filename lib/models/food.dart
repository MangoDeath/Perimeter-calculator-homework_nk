class Food {
  final int? id;
  final String name;
  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;

  const Food({
    this.id,
    required this.name,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });

  Food copyWith({
    int? id,
    String? name,
    double? calories,
    double? proteinG,
    double? carbsG,
    double? fatG,
  }) =>
      Food(
        id: id ?? this.id,
        name: name ?? this.name,
        calories: calories ?? this.calories,
        proteinG: proteinG ?? this.proteinG,
        carbsG: carbsG ?? this.carbsG,
        fatG: fatG ?? this.fatG,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'calories': calories,
        'protein_g': proteinG,
        'carbs_g': carbsG,
        'fat_g': fatG,
      };

  factory Food.fromMap(Map<String, dynamic> map) => Food(
        id: map['id'] as int?,
        name: map['name'] as String,
        calories: (map['calories'] as num).toDouble(),
        proteinG: (map['protein_g'] as num).toDouble(),
        carbsG: (map['carbs_g'] as num).toDouble(),
        fatG: (map['fat_g'] as num).toDouble(),
      );
}
