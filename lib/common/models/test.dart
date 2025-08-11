enum TestStatus { open, finished, cancelled }

class Test {
  final String id;
  final String childId;
  final String subject; // 'Maths', etc.
  final int difficulty; // TARL level
  final TestStatus status;
  final int? score; // result
  final int? maxScore;
  final DateTime createdAt;
  final DateTime? finishedAt;

  Test({
    required this.id,
    required this.childId,
    required this.subject,
    required this.difficulty,
    this.status = TestStatus.open,
    this.score,
    this.maxScore,
    DateTime? createdAt,
    this.finishedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'childId': childId,
        'subject': subject,
        'difficulty': difficulty,
        'status': status.name,
        'score': score,
        'maxScore': maxScore,
        'createdAt': createdAt.toIso8601String(),
        'finishedAt': finishedAt?.toIso8601String(),
      };

  factory Test.fromMap(String id, Map<dynamic, dynamic> map) => Test(
        id: id,
        childId: (map['childId'] ?? '') as String,
        subject: (map['subject'] ?? '') as String,
        difficulty: (map['difficulty'] ?? 0) as int,
        status: TestStatus.values.firstWhere(
          (e) => e.name == (map['status'] ?? 'open'),
          orElse: () => TestStatus.open,
        ),
        score: map['score'] as int?,
        maxScore: map['maxScore'] as int?,
        createdAt:
            DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
        finishedAt: map['finishedAt'] != null
            ? DateTime.tryParse(map['finishedAt'])
            : null,
      );
}
