import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:tarl_mobile_app/features/auth/controllers/auth_controller.dart';
import 'package:tarl_mobile_app/app/theme/app_colors.dart';
import 'package:tarl_mobile_app/app/theme/app_typography.dart';
import 'package:tarl_mobile_app/common/widgets/app_card.dart';
import 'package:tarl_mobile_app/app/localization/locale_controller.dart';

final linkedStudentsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final auth = ref.read(authControllerProvider);
  if (!auth.isLoggedIn || auth.username.isEmpty) return [];
  final db = FirebaseDatabase.instance;
  // Fetch parent by username
  final parentSnap = await db.ref('users').orderByChild('auth/username').equalTo(auth.username).get();
  if (!parentSnap.exists) return [];
  final parent = parentSnap.children.first;
  final parentData = parent.value as Map<dynamic, dynamic>;
  final linkedIds = parentData['linkedChildrenIds'];
  final ids = <String>[];
  if (linkedIds is List) {
    for (final id in linkedIds) {
      if (id != null) ids.add(id.toString());
    }
  }
  if (ids.isEmpty) return [];

  final usersSnap = await db.ref('users').get();
  final result = <Map<String, dynamic>>[];
  for (final id in ids) {
    final childSnap = usersSnap.child(id);
    if (childSnap.exists) {
      final m = childSnap.value as Map<dynamic, dynamic>;
      if ((m['role'] ?? '') == 'Student') {
        result.add({
          'uid': id,
          'firstName': m['firstName'] ?? '',
          'lastName': m['lastName'] ?? '',
          'schoolGrade': m['schoolGrade'] ?? '',
        });
      }
    }
  }
  return result;
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final asyncChildren = ref.watch(linkedStudentsProvider);
    final theme = Theme.of(context);
    final currentLocale = ref.watch(localeProvider);
    final currentTheme = ref.watch(themeModeProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Profile Header
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryBlue.withOpacity(0.1),
                      AppColors.secondaryTeal.withOpacity(0.1),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: _buildProfileHeader(context, auth),
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
                    // Account Settings
                    _buildAccountSettings(context, ref, currentLocale, currentTheme),
                    
                    const SizedBox(height: 24),
                    
                    // Children Section
                    _buildChildrenSection(context, asyncChildren),
                    
                    const SizedBox(height: 32),
                    
                    // Logout Button
                    _buildLogoutButton(context, ref),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, AuthState auth) {
    return Column(
      children: [
        // Profile Avatar
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              _getInitials(auth.firstName, auth.lastName),
              style: AppTypography.displayMedium.copyWith(
                color: AppColors.neutralWhite,
                fontWeight: AppTypography.bold,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Name and Username
        Text(
          '${auth.firstName} ${auth.lastName}'.trim(),
          style: AppTypography.headlineLarge.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: AppTypography.semiBold,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 8),
        
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '@${auth.username}',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.primaryBlue,
              fontWeight: AppTypography.medium,
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Parent Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.statusSuccess.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.statusSuccess.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.verified_user_rounded,
                size: 16,
                color: AppColors.statusSuccess,
              ),
              const SizedBox(width: 6),
              Text(
                'Parent Account',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.statusSuccess,
                  fontWeight: AppTypography.semiBold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSettings(BuildContext context, WidgetRef ref, Locale currentLocale, ThemeMode currentTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account Settings',
          style: AppTypography.headlineSmall.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: AppTypography.semiBold,
          ),
        ),
        
        const SizedBox(height: 16),
        
        AppCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Language Setting
              _buildSettingItem(
                context,
                icon: Icons.language_rounded,
                title: 'Language',
                subtitle: _getLanguageName(currentLocale.languageCode),
                trailing: PopupMenuButton<Locale>(
                  onSelected: (locale) => ref.read(localeProvider.notifier).setLocale(locale),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: const Locale('en'),
                      child: Row(
                        children: [
                          Text('🇺🇸', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          const Text('English'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: const Locale('fr'),
                      child: Row(
                        children: [
                          Text('🇫🇷', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          const Text('Français'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: const Locale('ar'),
                      child: Row(
                        children: [
                          Text('🇲🇦', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          const Text('العربية'),
                        ],
                      ),
                    ),
                  ],
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              
              const Divider(height: 32),
              
              // Theme Setting
              _buildSettingItem(
                context,
                icon: Theme.of(context).brightness == Brightness.dark 
                  ? Icons.dark_mode_rounded 
                  : Icons.light_mode_rounded,
                title: 'Theme',
                subtitle: _getThemeName(currentTheme),
                trailing: Switch(
                  value: currentTheme == ThemeMode.dark,
                  onChanged: (_) => ref.read(themeModeProvider.notifier).toggle(),
                  activeColor: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryBlue,
            size: 20,
          ),
        ),
        
        const SizedBox(width: 16),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
        ),
        
        trailing,
      ],
    );
  }

  Widget _buildChildrenSection(BuildContext context, AsyncValue<List<Map<String, dynamic>>> asyncChildren) {
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
              'Your Children',
              style: AppTypography.headlineSmall.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: AppTypography.semiBold,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        asyncChildren.when(
          data: (children) {
            if (children.isEmpty) {
              return AppCard(
                padding: const EdgeInsets.all(24),
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
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Contact your school administrator to link children to your account.',
                      style: AppTypography.bodyMedium.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }
            
            return Column(
              children: children.map((child) => _buildChildCard(context, child)).toList(),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (e, st) => AppCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: AppColors.statusError,
                ),
                const SizedBox(height: 16),
                Text(
                  'Unable to Load Children',
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.statusError,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  e.toString(),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.statusError,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChildCard(BuildContext context, Map<String, dynamic> child) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      onTap: () {
        Navigator.of(context).pushNamed('/student-profile', arguments: child);
      },
      child: Row(
        children: [
          // Child Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: AppColors.successGradient,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: Text(
                _getInitials(child['firstName'] ?? '', child['lastName'] ?? ''),
                style: AppTypography.titleLarge.copyWith(
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
                  '${child['firstName']} ${child['lastName']}'.trim(),
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: AppTypography.semiBold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryTeal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Grade ${child['schoolGrade'] ?? 'N/A'}',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.secondaryTeal,
                      fontWeight: AppTypography.medium,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Navigation Arrow
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: () async {
          // Show confirmation dialog
          final shouldLogout = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(
                'Logout',
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: AppTypography.semiBold,
                ),
              ),
              content: Text(
                'Are you sure you want to logout?',
                style: AppTypography.bodyMedium,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Logout'),
                ),
              ],
            ),
          );
          
          if (shouldLogout == true) {
            await ref.read(authControllerProvider.notifier).logout();
            if (context.mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            }
          }
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.statusError,
          side: BorderSide(color: AppColors.statusError),
        ),
        icon: Icon(Icons.logout_rounded, color: AppColors.statusError),
        label: Text(
          'Logout',
          style: AppTypography.buttonMedium.copyWith(
            color: AppColors.statusError,
          ),
        ),
      ),
    );
  }

  String _getInitials(String firstName, String lastName) {
    final first = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final last = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$first$last';
  }

  String _getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'fr':
        return 'Français';
      case 'ar':
        return 'العربية';
      default:
        return 'English';
    }
  }

  String _getThemeName(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'Light Mode';
      case ThemeMode.dark:
        return 'Dark Mode';
      case ThemeMode.system:
        return 'System Default';
    }
  }
}
