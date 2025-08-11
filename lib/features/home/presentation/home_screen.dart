import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:tarl_mobile_app/l10n/app_localizations.dart';
import 'package:tarl_mobile_app/app/localization/locale_controller.dart';
import 'package:tarl_mobile_app/app/firebase_bootstrap.dart';
import 'package:tarl_mobile_app/common/services/firebase_database_service.dart';
import 'package:tarl_mobile_app/common/widgets/tarl_loading.dart';

import 'package:tarl_mobile_app/common/widgets/app_card.dart';
import 'package:tarl_mobile_app/features/auth/controllers/auth_controller.dart';
import 'package:tarl_mobile_app/features/shell/presentation/main_shell.dart';
import 'package:tarl_mobile_app/app/theme/app_colors.dart';
import 'package:tarl_mobile_app/app/theme/app_typography.dart';

final schoolNameProvider = FutureProvider<String?>((ref) async {
  final db = ref.read(firebaseDatabaseServiceProvider);
  return db.readString('schools/0/name');
});

final recentTestCompletionProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final authState = ref.watch(authControllerProvider);
  if (!authState.isLoggedIn) return null;

  final db = ref.read(firebaseDatabaseServiceProvider);
  
  // Get the full user data from Firebase using the username
  final userSnap = await FirebaseDatabase.instance.ref('users')
      .orderByChild('auth/username')
      .equalTo(authState.username)
      .get();
  
  if (!userSnap.exists) return null;
  
  final userData = userSnap.children.first.value as Map<dynamic, dynamic>;
  
  // Get linked children IDs
  final linkedIds = userData['linkedChildrenIds'];
  final childIds = <String>[];
  if (linkedIds is List) {
    for (final id in linkedIds) {
      if (id != null) childIds.add(id.toString());
    }
  }
  
  if (childIds.isEmpty) return null;

  // Find the most recent completed test for any child
  Map<String, dynamic>? mostRecentTest;
  String? childName;
  
  for (final childId in childIds) {
    try {
      // Get child data
      final childData = await db.read('users/$childId');
      if (childData == null || childData is! Map) continue;
      
      final childFirstName = childData['firstName'] ?? '';
      final childTests = childData['tests'];
      
      if (childTests is Map) {
        for (final testEntry in childTests.entries) {
          final testData = testEntry.value;
          if (testData is Map && testData['finished'] == true) {
            final finishedAt = testData['finishedAt'];
            if (finishedAt != null) {
              if (mostRecentTest == null || 
                  (mostRecentTest['finishedAt']?.compareTo(finishedAt) ?? -1) < 0) {
                mostRecentTest = Map<String, dynamic>.from(testData);
                mostRecentTest['testId'] = testEntry.key;
                childName = childFirstName;
              }
            }
          }
        }
      }
    } catch (e) {
      // Continue with other children if one fails
      continue;
    }
  }
  
  if (mostRecentTest != null && childName != null) {
    // Get test details from school tests
    try {
      final schoolTests = await db.read('schools/0/tests');
      if (schoolTests is Map) {
        final testId = mostRecentTest['testId'];
        final testInfo = schoolTests[testId];
        if (testInfo is Map) {
          final subject = testInfo['title']?['en'] ?? testInfo['title']?['fr'] ?? testInfo['title']?['ar'] ?? 'Math';
          return {
            'childName': childName,
            'subject': subject,
            'finishedAt': mostRecentTest['finishedAt'],
            'totalScore': mostRecentTest['totalScore'] ?? 0,
            'totalGames': mostRecentTest['totalGames'] ?? 0,
          };
        }
      }
    } catch (e) {
      // Fallback to basic info
    }
    
    return {
      'childName': childName,
      'subject': 'Math', // Default fallback
      'finishedAt': mostRecentTest['finishedAt'],
      'totalScore': mostRecentTest['totalScore'] ?? 0,
      'totalGames': mostRecentTest['totalGames'] ?? 0,
    };
  }
  
  return null;
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = AppLocalizations.of(context)!;
    final authState = ref.watch(authControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Modern App Bar
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: theme.colorScheme.surface,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
                title: Text(
                  '${text.homeGreeting}, ${authState.firstName}',
                  style: AppTypography.headlineMedium.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: AppTypography.semiBold,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryBlue.withOpacity(0.05),
                        AppColors.secondaryTeal.withOpacity(0.05),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
                  icon: Icon(
                    theme.brightness == Brightness.dark 
                      ? Icons.light_mode_rounded 
                      : Icons.dark_mode_rounded,
                  ),
                  tooltip: 'Toggle theme',
                ),
                PopupMenuButton<Locale>(
                  onSelected: (locale) =>
                      ref.read(localeProvider.notifier).setLocale(locale),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: const Locale('en'),
                      child: Row(
                        children: [
                          Text('🇺🇸', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 8),
                          const Text('English'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: const Locale('fr'),
                      child: Row(
                        children: [
                          Text('🇫🇷', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 8),
                          const Text('Français'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: const Locale('ar'),
                      child: Row(
                        children: [
                          Text('🇲🇦', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 8),
                          const Text('العربية'),
                        ],
                      ),
                    ),
                  ],
                  icon: const Icon(Icons.language_rounded),
                  tooltip: 'Change language',
                ),
                const SizedBox(width: 8),
              ],
            ),
            
            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Stats Row
                    _buildQuickStats(context, ref),
                    
                    const SizedBox(height: 24),
                    
                    // Recent Activity Section
                    _buildRecentActivity(context, ref, text),
                    
                    const SizedBox(height: 24),
                    
                    // School Info & Quick Actions
                    _buildSchoolAndActions(context, ref, text),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: AppCard(
            padding: const EdgeInsets.all(20),
            color: AppColors.primaryBlue,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.school_rounded,
                  color: AppColors.neutralWhite,
                  size: 32,
                ),
                const SizedBox(height: 12),
                Text(
                  'Active\nLearner',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.neutralWhite,
                    fontWeight: AppTypography.semiBold,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: AppCard(
            padding: const EdgeInsets.all(20),
            color: AppColors.statusSuccess,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.trending_up_rounded,
                  color: AppColors.neutralWhite,
                  size: 32,
                ),
                const SizedBox(height: 12),
                Text(
                  'Great\nProgress',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.neutralWhite,
                    fontWeight: AppTypography.semiBold,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity(BuildContext context, WidgetRef ref, AppLocalizations text) {
    final firebaseReady = ref.watch(firebaseReadyProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.emoji_events_rounded,
              color: AppColors.accentOrange,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Recent Activity',
              style: AppTypography.headlineSmall.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: AppTypography.semiBold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AppCard(
          padding: const EdgeInsets.all(24),
          child: firebaseReady.when(
            data: (ready) {
              if (!ready) {
                return _buildNotConfiguredState();
              }
              final recentTestAsync = ref.watch(recentTestCompletionProvider);
              return recentTestAsync.when(
                data: (testData) => _buildActivityContent(context, text, testData),
                loading: () => const TarlLoading(),
                error: (e, st) => _buildErrorState(e.toString()),
              );
            },
            loading: () => const TarlLoading(),
            error: (e, st) => _buildErrorState(e.toString()),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityContent(BuildContext context, AppLocalizations text, Map<String, dynamic>? testData) {
    if (testData == null) {
      return Column(
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No recent test completions found.',
            style: AppTypography.bodyLarge.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Your child\'s test results will appear here.',
            style: AppTypography.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    final childName = testData['childName'] ?? 'Student';
    final subject = testData['subject'] ?? 'Math';
    final score = testData['totalScore'] ?? 0;
    final totalGames = testData['totalGames'] ?? 0;
    final finishedAt = testData['finishedAt'] ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.statusSuccess.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.emoji_events_rounded,
                color: AppColors.statusSuccess,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text.dailyHighlight(childName, subject),
                    style: AppTypography.titleLarge.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: AppTypography.semiBold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Score: $score/$totalGames games completed',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.statusSuccess,
                      fontWeight: AppTypography.medium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (finishedAt.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Completed: ${DateTime.parse(finishedAt).toLocal().toString().split('.')[0]}',
              style: AppTypography.labelSmall.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSchoolAndActions(BuildContext context, WidgetRef ref, AppLocalizations text) {
    final firebaseReady = ref.watch(firebaseReadyProvider);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'School Information',
                style: AppTypography.headlineSmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: AppTypography.semiBold,
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.school_rounded,
                          color: AppColors.primaryBlue,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'School',
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: AppTypography.semiBold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    firebaseReady.when(
                      data: (ready) {
                        if (!ready) {
                          return _buildNotConfiguredState();
                        }
                        final asyncMsg = ref.watch(schoolNameProvider);
                        return asyncMsg.when(
                          data: (value) => Text(
                            value ?? "Loading school...",
                            style: AppTypography.bodyLarge.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          loading: () => const TarlLoading(),
                          error: (e, st) => _buildErrorState(e.toString()),
                        );
                      },
                      loading: () => const TarlLoading(),
                      error: (e, st) => _buildErrorState(e.toString()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick Actions',
                style: AppTypography.headlineSmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: AppTypography.semiBold,
                ),
              ),
              const SizedBox(height: 16),
              _buildQuickActionButton(
                context,
                ref,
                icon: Icons.person_rounded,
                label: 'Profile',
                targetIndex: 1,
              ),
              const SizedBox(height: 8),
              _buildQuickActionButton(
                context,
                ref,
                icon: Icons.notifications_rounded,
                label: 'Alerts',
                targetIndex: 2,
              ),
              const SizedBox(height: 8),
              _buildQuickActionButton(
                context,
                ref,
                icon: Icons.analytics_rounded,
                label: 'Progress',
                targetIndex: 3,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required String label,
    required int targetIndex,
  }) {
    return AppCard.outlined(
      padding: const EdgeInsets.all(16),
      onTap: () {
        // Switch to the target tab in MainShell
        ref.read(mainShellIndexProvider.notifier).state = targetIndex;
      },
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.primaryBlue,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppTypography.labelLarge.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildNotConfiguredState() {
    return Column(
      children: [
        Icon(
          Icons.cloud_off_rounded,
          size: 48,
          color: Colors.orange,
        ),
        const SizedBox(height: 16),
        Text(
          'Firebase not configured',
          style: AppTypography.bodyLarge.copyWith(
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String error) {
    return Column(
      children: [
        Icon(
          Icons.error_outline_rounded,
          size: 48,
          color: AppColors.statusError,
        ),
        const SizedBox(height: 16),
        Text(
          'Unable to load data',
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.statusError,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          error,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.statusError,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
