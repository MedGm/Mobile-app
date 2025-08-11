class Child {
  final String id;
  final String firstName;
  final String lastName;
  final String preferredLanguage; // 'ar' | 'fr' | 'en'
  final DateTime? birthDate;
  final Map<String, int> masteryLevels; // e.g., {"Maths": 2}
  final List<String> parentIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  Child({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.preferredLanguage,
    this.birthDate,
    this.masteryLevels = const {},
    this.parentIds = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'firstName': firstName,
        'lastName': lastName,
        'preferredLanguage': preferredLanguage,
        'birthDate': birthDate?.toIso8601String(),
        'masteryLevels': masteryLevels,
        'parentIds': parentIds,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Child.fromMap(String id, Map<dynamic, dynamic> map) => Child(
        id: id,
        firstName: (map['firstName'] ?? '') as String,
        lastName: (map['lastName'] ?? '') as String,
        preferredLanguage: (map['preferredLanguage'] ?? 'en') as String,
        birthDate: map['birthDate'] != null
            ? DateTime.tryParse(map['birthDate'])
            : null,
        masteryLevels: Map<String, int>.from(map['masteryLevels'] ?? {}),
        parentIds: List<String>.from(map['parentIds'] ?? const []),
        createdAt:
            DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
        updatedAt:
            DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
      );
}
