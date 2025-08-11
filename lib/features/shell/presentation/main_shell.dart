import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarl_mobile_app/features/home/presentation/home_screen.dart';
import 'package:tarl_mobile_app/features/profile/presentation/profile_screen.dart';
import 'package:tarl_mobile_app/features/notifications/presentation/notifications_screen.dart';
import 'package:tarl_mobile_app/features/achievements/presentation/achievements_screen.dart';

// Provider to control the main shell tab index
final mainShellIndexProvider = StateProvider<int>((ref) => 0);

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  final List<Widget> _pages = const [
    HomeScreen(),
    ProfileScreen(),
    NotificationsScreen(),
    AchievementsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(mainShellIndexProvider);

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          ref.read(mainShellIndexProvider.notifier).state = index;
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined), 
            selectedIcon: Icon(Icons.home_rounded), 
            label: 'Home'
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline), 
            selectedIcon: Icon(Icons.person_rounded), 
            label: 'Profile'
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_none_rounded), 
            selectedIcon: Icon(Icons.notifications_rounded), 
            label: 'Alerts'
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined), 
            selectedIcon: Icon(Icons.analytics_rounded), 
            label: 'Progress'
          ),
        ],
      ),
    );
  }
}
