import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/splash/views/splash_screen.dart';
import '../../features/dashboard/views/dashboard_screen.dart';
import '../../features/habit/views/habit_screen.dart';
import '../../features/habit/views/habit_form_screen.dart';
import '../../features/habit/views/habit_detail_screen.dart';
import '../../features/journal/views/journal_screen.dart';
import '../../features/journal/views/journal_editor_screen.dart';
import '../../features/sleep/views/sleep_screen.dart';
import '../../features/sleep/views/sleep_log_screen.dart';
import '../../features/analytics/views/analytics_screen.dart';
import '../../features/profile/views/profile_screen.dart';
import '../../features/gamification/views/achievements_screen.dart';

/// Application router configuration using go_router.
///
/// Uses [StatefulShellRoute] for persistent bottom navigation
/// with 5 tabs: Dashboard, Habits, Journal, Sleep, Analytics.
final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    // Splash screen (no bottom nav)
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),

    // Main app with bottom navigation
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        // Tab 1: Dashboard
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),
        // Tab 2: Habits
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/habits',
              builder: (context, state) => const HabitScreen(),
              routes: [
                GoRoute(
                  path: 'new',
                  builder: (context, state) => const HabitFormScreen(),
                ),
                GoRoute(
                  path: ':id',
                  builder: (context, state) => HabitDetailScreen(
                    habitId: int.parse(state.pathParameters['id']!),
                  ),
                ),
                GoRoute(
                  path: ':id/edit',
                  builder: (context, state) => HabitFormScreen(
                    habitId: int.parse(state.pathParameters['id']!),
                  ),
                ),
              ],
            ),
          ],
        ),
        // Tab 3: Journal
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/journal',
              builder: (context, state) => const JournalScreen(),
              routes: [
                GoRoute(
                  path: 'new',
                  builder: (context, state) => const JournalEditorScreen(),
                ),
                GoRoute(
                  path: ':id',
                  builder: (context, state) => JournalEditorScreen(
                    journalId: int.parse(state.pathParameters['id']!),
                  ),
                ),
              ],
            ),
          ],
        ),
        // Tab 4: Sleep
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/sleep',
              builder: (context, state) => const SleepScreen(),
              routes: [
                GoRoute(
                  path: 'log',
                  builder: (context, state) => const SleepLogScreen(),
                ),
              ],
            ),
          ],
        ),
        // Tab 5: Analytics
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/analytics',
              builder: (context, state) => const AnalyticsScreen(),
            ),
          ],
        ),
      ],
    ),

    // Standalone routes (outside bottom nav)
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/achievements',
      builder: (context, state) => const AchievementsScreen(),
    ),
  ],
);

/// Shell widget with persistent bottom navigation bar.
class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _goBranch,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline),
            selectedIcon: Icon(Icons.check_circle),
            label: 'Habits',
          ),
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book),
            label: 'Journal',
          ),
          NavigationDestination(
            icon: Icon(Icons.bedtime_outlined),
            selectedIcon: Icon(Icons.bedtime),
            label: 'Sleep',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Analytics',
          ),
        ],
      ),
    );
  }
}

