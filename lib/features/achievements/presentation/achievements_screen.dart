import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:tarl_mobile_app/features/auth/controllers/auth_controller.dart';
import 'package:tarl_mobile_app/app/theme/app_colors.dart';
import 'package:tarl_mobile_app/app/theme/app_typography.dart';
import 'package:tarl_mobile_app/common/widgets/app_card.dart';

final achievementsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final auth = ref.read(authControllerProvider);
  if (!auth.isLoggedIn) return {'totalTests': 0, 'completedTests': 0, 'averageScore': 0.0, 'children': []};
  
  final db = FirebaseDatabase.instance;
  
  // Get parent's linked children
  final parentSnap = await db.ref('users').orderByChild('auth/username').equalTo(auth.username).get();
  if (!parentSnap.exists) return {'totalTests': 0, 'completedTests': 0, 'averageScore': 0.0, 'children': []};
  
  final parent = parentSnap.children.first;
  final parentData = parent.value as Map<dynamic, dynamic>;
  final linkedIds = parentData['linkedChildrenIds'];
  final childIds = <String>[];
  if (linkedIds is List) {
    for (final id in linkedIds) {
      if (id != null) childIds.add(id.toString());
    }
  }
  
  if (childIds.isEmpty) return {'totalTests': 0, 'completedTests': 0, 'averageScore': 0.0, 'children': []};
  
  // Get test data for all children
  final testsSnap = await db.ref('schools/0/tests').get();
  int totalTests = 0;
  int completedTests = 0;
  double totalScore = 0;
  int scoredTests = 0;
  
  final childrenProgress = <Map<String, dynamic>>[];
  
  for (final childId in childIds) {
    final usersSnap = await db.ref('users').get();
    final childSnap = usersSnap.child(childId);
    if (!childSnap.exists) continue;
    
    final childData = childSnap.value as Map<dynamic, dynamic>;
    final childName = '${childData['firstName'] ?? ''} ${childData['lastName'] ?? ''}'.trim();
    
    int childTests = 0;
    int childCompleted = 0;
    double childTotalScore = 0;
    int childScoredTests = 0;
    
    if (testsSnap.exists) {
      for (final testSnap in testsSnap.children) {
        final testData = testSnap.value as Map<dynamic, dynamic>;
        if ((testData['studentId'] ?? '') == childId) {
          childTests++;
          totalTests++;
          
          if ((testData['status'] ?? '') == 'completed') {
            childCompleted++;
            completedTests++;
            
            final score = testData['score'] ?? 0;
            final maxScore = testData['maxScore'] ?? 100;
            if (maxScore > 0) {
              final percentage = (score / maxScore * 100);
              childTotalScore += percentage;
              childScoredTests++;
              totalScore += percentage;
              scoredTests++;
            }
          }
        }
      }
    }
    
    childrenProgress.add({
      'name': childName,
      'tests': childTests,
      'completed': childCompleted,
      'averageScore': childScoredTests > 0 ? childTotalScore / childScoredTests : 0.0,
    });
  }
  
  return {
    'totalTests': totalTests,
    'completedTests': completedTests,
    'averageScore': scoredTests > 0 ? totalScore / scoredTests : 0.0,
    'children': childrenProgress,
  };
});

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(achievementsProvider);
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: asyncData.when(
          data: (data) => _buildProgressContent(context, data),
          loading: () => _buildLoadingState(context),
          error: (e, st) => _buildErrorState(context, ref, e.toString()),
        ),
      ),
    );
  }

  Widget _buildProgressContent(BuildContext context, Map<String, dynamic> data) {
    final totalTests = data['totalTests'] as int;
    final completedTests = data['completedTests'] as int;
    final averageScore = data['averageScore'] as double;
    final childrenData = data['children'] as List;
    final children = childrenData.cast<Map<String, dynamic>>();

    return CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.statusSuccess.withOpacity(0.1),
                  AppColors.primaryBlue.withOpacity(0.05),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: AppColors.successGradient,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.analytics_rounded,
                          color: AppColors.neutralWhite,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Progress & Analytics',
                              style: AppTypography.headlineLarge.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: AppTypography.bold,
                              ),
                            ),
                            Text(
                              'Track your children\'s learning journey',
                              style: AppTypography.bodyMedium.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overall Statistics
                _buildOverallStats(context, totalTests, completedTests, averageScore),
                
                const SizedBox(height: 32),
                
                // Children Progress
                _buildChildrenProgress(context, children),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOverallStats(BuildContext context, int totalTests, int completedTests, double averageScore) {
    final completionRate = totalTests > 0 ? (completedTests / totalTests * 100) : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overall Performance',
          style: AppTypography.headlineSmall.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: AppTypography.semiBold,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Stats Grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.3,
          children: [
            _buildStatCard(
              context,
              icon: Icons.assignment_rounded,
              iconColor: AppColors.primaryBlue,
              title: 'Total Tests',
              value: totalTests.toString(),
              subtitle: 'Across all children',
            ),
            _buildStatCard(
              context,
              icon: Icons.check_circle_rounded,
              iconColor: AppColors.statusSuccess,
              title: 'Completed',
              value: completedTests.toString(),
              subtitle: '${completionRate.round()}% completion rate',
            ),
            _buildStatCard(
              context,
              icon: Icons.star_rounded,
              iconColor: AppColors.accentOrange,
              title: 'Average Score',
              value: '${averageScore.round()}%',
              subtitle: _getPerformanceLabel(averageScore),
            ),
            _buildStatCard(
              context,
              icon: Icons.trending_up_rounded,
              iconColor: AppColors.secondaryTeal,
              title: 'This Week',
              value: '+${(completedTests * 0.2).round()}', // Mock data
              subtitle: 'Tests completed',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            value,
            style: AppTypography.headlineMedium.copyWith(
              fontWeight: AppTypography.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          
          const SizedBox(height: 4),
          
          Text(
            title,
            style: AppTypography.titleMedium.copyWith(
              fontWeight: AppTypography.semiBold,
            ),
          ),
          
          const SizedBox(height: 2),
          
          Text(
            subtitle,
            style: AppTypography.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildrenProgress(BuildContext context, List<Map<String, dynamic>> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.family_restroom_rounded,
              color: AppColors.primaryBlue,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Individual Progress',
              style: AppTypography.headlineSmall.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: AppTypography.semiBold,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        if (children.isEmpty)
          _buildEmptyChildrenState(context)
        else
          ...children.map((child) => _buildChildProgressCard(context, child)),
      ],
    );
  }

  Widget _buildChildProgressCard(BuildContext context, Map<String, dynamic> child) {
    final score = (child['averageScore'] as double).round();
    final completed = child['completed'] as int;
    final total = child['tests'] as int;
    final completionRate = total > 0 ? (completed / total * 100) : 0.0;
    
    return AppCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Child Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: _getGradientForScore(score),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    _getInitials(child['name'] as String),
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.neutralWhite,
                      fontWeight: AppTypography.bold,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Child Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child['name'] as String,
                      style: AppTypography.titleLarge.copyWith(
                        fontWeight: AppTypography.semiBold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$completed of $total tests completed',
                      style: AppTypography.bodyMedium.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Score Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getColorForScore(score).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$score%',
                  style: AppTypography.titleMedium.copyWith(
                    color: _getColorForScore(score),
                    fontWeight: AppTypography.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Completion Rate',
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: AppTypography.medium,
                    ),
                  ),
                  Text(
                    '${completionRate.round()}%',
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: AppTypography.semiBold,
                      color: _getColorForScore(completionRate),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: completionRate / 100,
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(_getColorForScore(completionRate)),
                minHeight: 8,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Performance Indicator
          Row(
            children: [
              Icon(
                _getIconForScore(score),
                color: _getColorForScore(score),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _getPerformanceLabel(score.toDouble()),
                style: AppTypography.bodyMedium.copyWith(
                  color: _getColorForScore(score),
                  fontWeight: AppTypography.medium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChildrenState(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.school_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No Children Found',
            style: AppTypography.titleLarge.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: AppTypography.semiBold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Contact your school to link children to your account.',
            style: AppTypography.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: AppCard(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AppColors.statusError,
              ),
              const SizedBox(height: 16),
              Text(
                'Unable to Load Progress',
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.statusError,
                  fontWeight: AppTypography.semiBold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: AppTypography.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => ref.refresh(achievementsProvider),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    return 'S';
  }

  Color _getColorForScore(dynamic score) {
    final scoreValue = score is double ? score : (score as int).toDouble();
    if (scoreValue >= 80) return AppColors.statusSuccess;
    if (scoreValue >= 60) return AppColors.primaryBlue;
    if (scoreValue >= 40) return AppColors.accentOrange;
    return AppColors.statusError;
  }

  LinearGradient _getGradientForScore(int score) {
    if (score >= 80) return AppColors.successGradient;
    if (score >= 60) return AppColors.primaryGradient;
    if (score >= 40) return AppColors.warningGradient;
    return LinearGradient(colors: [AppColors.statusError, AppColors.statusError.withOpacity(0.8)]);
  }

  IconData _getIconForScore(int score) {
    if (score >= 80) return Icons.trending_up_rounded;
    if (score >= 60) return Icons.trending_flat_rounded;
    return Icons.trending_down_rounded;
  }

  String _getPerformanceLabel(double score) {
    if (score >= 80) return 'Excellent Progress';
    if (score >= 60) return 'Good Progress';
    if (score >= 40) return 'Needs Improvement';
    return 'Requires Attention';
  }
}
