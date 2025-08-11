import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:tarl_mobile_app/app/theme/app_colors.dart';
import 'package:tarl_mobile_app/app/theme/app_typography.dart';
import 'package:tarl_mobile_app/common/widgets/app_card.dart';

final notificationsProvider = StreamProvider<List<String>>((ref) {
  final db = FirebaseDatabase.instance.ref('notifications');
  return db.onValue.map((event) {
    final List<String> items = [];
    final val = event.snapshot.value;
    if (val is List) {
      for (final e in val) {
        if (e != null) items.add(e.toString());
      }
    } else if (val is Map) {
      for (final e in val.values) {
        if (e != null) items.add(e.toString());
      }
    }
    return items;
  });
});

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncNotes = ref.watch(notificationsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.accentOrange.withOpacity(0.1),
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
                              gradient: LinearGradient(
                                colors: [AppColors.accentOrange, AppColors.accentOrange.withOpacity(0.8)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.notifications_rounded,
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
                                  'Notifications',
                                  style: AppTypography.headlineLarge.copyWith(
                                    color: theme.colorScheme.onSurface,
                                    fontWeight: AppTypography.bold,
                                  ),
                                ),
                                Text(
                                  'Stay updated with your child\'s progress',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
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
                child: asyncNotes.when(
                  data: (items) => _buildNotificationsList(context, items, ref),
                  loading: () => _buildLoadingState(context),
                  error: (e, st) => _buildErrorState(context, ref, e.toString()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList(BuildContext context, List<String> items, WidgetRef ref) {
    if (items.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Alerts',
              style: AppTypography.headlineSmall.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: AppTypography.semiBold,
              ),
            ),
            TextButton.icon(
              onPressed: () => ref.refresh(notificationsProvider),
              icon: Icon(
                Icons.refresh_rounded,
                size: 18,
                color: AppColors.primaryBlue,
              ),
              label: Text(
                'Refresh',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final notification = entry.value;
          return _buildNotificationCard(context, notification, index, items.length);
        }),
      ],
    );
  }

  Widget _buildNotificationCard(BuildContext context, String notification, int index, int total) {
    final isRecent = index < 3; // Mark first 3 as recent
    final notificationType = _getNotificationType(notification);
    
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Notification Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _getNotificationColor(notificationType).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getNotificationIcon(notificationType),
              color: _getNotificationColor(notificationType),
              size: 24,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Notification Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification,
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: isRecent ? AppTypography.semiBold : AppTypography.regular,
                        ),
                      ),
                    ),
                    if (isRecent)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.statusSuccess.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'New',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.statusSuccess,
                            fontWeight: AppTypography.semiBold,
                          ),
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getRelativeTime(index),
                      style: AppTypography.bodySmall.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: AppCard(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.neutralGray100,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                size: 48,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Notifications Yet',
              style: AppTypography.headlineSmall.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: AppTypography.semiBold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You\'ll receive notifications about your child\'s progress, test completions, and important updates here.',
              style: AppTypography.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Navigate to settings to enable notifications
              },
              icon: const Icon(Icons.settings_rounded),
              label: const Text('Notification Settings'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: AppColors.neutralWhite,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: AppCard(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading notifications...',
              style: AppTypography.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, String error) {
    return Center(
      child: AppCard(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.statusError.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AppColors.statusError,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Access Denied',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.statusError,
                fontWeight: AppTypography.semiBold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Unable to load notifications. Please check Firebase permissions or try again later.',
              style: AppTypography.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton.icon(
                  onPressed: () => ref.refresh(notificationsProvider),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Show help or contact support
                  },
                  icon: const Icon(Icons.help_outline_rounded),
                  label: const Text('Get Help'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: AppColors.neutralWhite,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getNotificationType(String notification) {
    final lower = notification.toLowerCase();
    if (lower.contains('test') || lower.contains('exam')) return 'test';
    if (lower.contains('progress') || lower.contains('improvement')) return 'progress';
    if (lower.contains('reminder') || lower.contains('schedule')) return 'reminder';
    if (lower.contains('achievement') || lower.contains('success')) return 'achievement';
    return 'general';
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'test':
        return Icons.quiz_rounded;
      case 'progress':
        return Icons.trending_up_rounded;
      case 'reminder':
        return Icons.schedule_rounded;
      case 'achievement':
        return Icons.emoji_events_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'test':
        return AppColors.primaryBlue;
      case 'progress':
        return AppColors.statusSuccess;
      case 'reminder':
        return AppColors.accentOrange;
      case 'achievement':
        return AppColors.accentGreen;
      default:
        return AppColors.neutralGray500;
    }
  }

  String _getRelativeTime(int index) {
    if (index == 0) return 'Just now';
    if (index < 3) return '${index + 1} minutes ago';
    if (index < 6) return '${index - 2} hours ago';
    return '${index - 5} days ago';
  }
}
