class Parent {
  final String id;
  final String fullName;
  final String phone; // E.164
  final String? email;
  final String preferredLanguage; // 'ar' | 'fr' | 'en'
  final List<String> childIds;

  Parent({
    required this.id,
    required this.fullName,
    required this.phone,
    this.email,
    this.preferredLanguage = 'fr',
    this.childIds = const [],
  });

  Map<String, dynamic> toMap() => {
        'fullName': fullName,
        'phone': phone,
        'email': email,
        'preferredLanguage': preferredLanguage,
        'childIds': childIds,
      };

  factory Parent.fromMap(String id, Map<dynamic, dynamic> map) => Parent(
        id: id,
        fullName: (map['fullName'] ?? '') as String,
        phone: (map['phone'] ?? '') as String,
        email: map['email'] as String?,
        preferredLanguage: (map['preferredLanguage'] ?? 'fr') as String,
        childIds: List<String>.from(map['childIds'] ?? const []),
      );
}
