class ProgressRecord {
  final String id;
  final String childId;
  final String subject;
  final int levelBefore;
  final int levelAfter;
  final String? testId;
  final DateTime timestamp;

  ProgressRecord({
    required this.id,
    required this.childId,
    required this.subject,
    required this.levelBefore,
    required this.levelAfter,
    this.testId,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'childId': childId,
        'subject': subject,
        'levelBefore': levelBefore,
        'levelAfter': levelAfter,
        'testId': testId,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ProgressRecord.fromMap(String id, Map<dynamic, dynamic> map) =>
      ProgressRecord(
        id: id,
        childId: (map['childId'] ?? '') as String,
        subject: (map['subject'] ?? '') as String,
        levelBefore: (map['levelBefore'] ?? 0) as int,
        levelAfter: (map['levelAfter'] ?? 0) as int,
        testId: map['testId'] as String?,
        timestamp:
            DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
      );
}
