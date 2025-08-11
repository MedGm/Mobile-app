import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';

final studentTestsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, studentId) async {
  final db = FirebaseDatabase.instance;
  
  // Get tests from the student's own data (based on real schema)
  final studentSnap = await db.ref('users/$studentId').get();
  if (!studentSnap.exists) return [];
  
  final studentData = studentSnap.value as Map<dynamic, dynamic>;
  final studentTests = studentData['tests'] as Map<dynamic, dynamic>?;
  
  if (studentTests == null) return [];
  
  final result = <Map<String, dynamic>>[];
  
  // Get school tests for additional info
  final schoolTestsSnap = await db.ref('schools/0/tests').get();
  final schoolTests = schoolTestsSnap.exists ? schoolTestsSnap.value as Map<dynamic, dynamic> : <dynamic, dynamic>{};
  
  for (final testEntry in studentTests.entries) {
    final testId = testEntry.key;
    final testData = testEntry.value as Map<dynamic, dynamic>;
    
    // Get test details from school if available
    final schoolTestInfo = schoolTests[testId] as Map<dynamic, dynamic>?;
    
    final test = <String, dynamic>{
      'id': testId,
      'finished': testData['finished'] ?? false,
      'finishedAt': testData['finishedAt'],
      'totalScore': testData['totalScore'] ?? 0,
      'totalGames': testData['totalGames'] ?? 0,
      'numGamesPassed': testData['numGamesPassed'] ?? 0,
      'evaluatedGrade': testData['evaluatedGrade'],
    };
    
    // Add school test info if available
    if (schoolTestInfo != null) {
      test['title'] = schoolTestInfo['title'] ?? {};
      test['status'] = schoolTestInfo['status'] ?? 'draft';
      test['createdAt'] = schoolTestInfo['createdAt'];
    }
    
    // Set computed fields for UI
    test['score'] = test['totalScore'];
    test['maxScore'] = (test['totalGames'] as int) * 10; // Rough estimate based on typical scoring
    test['subject'] = (test['title'] as Map?)?['en'] ?? 
                     (test['title'] as Map?)?['fr'] ?? 
                     (test['title'] as Map?)?['ar'] ?? 
                     'Math';
    test['difficulty'] = test['evaluatedGrade']?['inferredGrade']?.toString() ?? 'Unknown';
    
    result.add(test);
  }
  
  // Sort by completion date, most recent first
  result.sort((a, b) {
    final aFinished = a['finishedAt'] ?? '';
    final bFinished = b['finishedAt'] ?? '';
    return bFinished.toString().compareTo(aFinished.toString());
  });
  
  return result;
});

class StudentProfileScreen extends ConsumerWidget {
  final Map<String, dynamic> student;
  
  const StudentProfileScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentId = student['uid'] ?? '';
    final asyncTests = ref.watch(studentTestsProvider(studentId));
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${student['firstName']} ${student['lastName']}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Student Info', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text('Name: ${student['firstName']} ${student['lastName']}'),
                    Text('Grade: ${student['schoolGrade'] ?? 'N/A'}'),
                    Text('Student ID: ${student['uid']}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Test History', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Expanded(
              child: asyncTests.when(
                data: (tests) {
                  if (tests.isEmpty) {
                    return const Center(child: Text('No tests found for this student.'));
                  }
                  return ListView.separated(
                    itemCount: tests.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final test = tests[i];
                      final subject = test['subject'] ?? 'Math';
                      final totalGames = test['totalGames'] ?? 0;
                      final numGamesPassed = test['numGamesPassed'] ?? 0;
                      final finished = test['finished'] ?? false;
                      final difficulty = test['difficulty'] ?? 'Unknown';
                      final finishedAt = test['finishedAt'];
                      
                      final percentage = totalGames > 0 ? (numGamesPassed / totalGames * 100).round() : 0;
                      
                      Color statusColor = Colors.grey;
                      IconData statusIcon = Icons.schedule;
                      String statusText = 'In Progress';
                      
                      if (finished) {
                        if (percentage >= 70) {
                          statusColor = Colors.green;
                          statusIcon = Icons.check_circle;
                          statusText = 'Completed';
                        } else {
                          statusColor = Colors.orange;
                          statusIcon = Icons.warning;
                          statusText = 'Needs Review';
                        }
                      }
                      
                      return Card(
                        child: ListTile(
                          title: Text('$subject Test'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('$statusText • Level $difficulty'),
                              Text('Games: $numGamesPassed/$totalGames passed'),
                              if (finishedAt != null)
                                Text(
                                  'Completed: ${DateTime.parse(finishedAt).toLocal().toString().split(' ')[0]}',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                ),
                            ],
                          ),
                          isThreeLine: true,
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(statusIcon, color: statusColor),
                              Text('$percentage%', style: TextStyle(color: statusColor, fontSize: 12)),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
