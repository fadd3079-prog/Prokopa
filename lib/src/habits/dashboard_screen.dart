import 'package:flutter/material.dart';
import 'package:prokopa/src/app/app_theme.dart';
import 'package:prokopa/src/habits/dashboard_content.dart';
import 'package:prokopa/src/habits/dashboard_snapshot.dart';
import 'package:prokopa/src/habits/habit.dart';
import 'package:prokopa/src/habits/habit_store.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.store,
    this.profileName,
    this.refreshVersion = 0,
  });

  final HabitStore store;
  final String? profileName;
  final int refreshVersion;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DashboardSnapshot? _snapshot;
  String? _error;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void didUpdateWidget(covariant DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshVersion != widget.refreshVersion) {
      _reload();
    }
  }

  Future<void> _reload() async {
    try {
      final today = await widget.store.loadToday();
      final progress = await widget.store.progress();
      final activeProgress =
          progress
              .where((item) => item.habit.state == HabitState.active)
              .toList()
            ..sort((left, right) {
              final streakOrder = right.currentStreak.compareTo(
                left.currentStreak,
              );
              return streakOrder != 0
                  ? streakOrder
                  : left.habit.draft.title.compareTo(right.habit.draft.title);
            });
      if (!mounted) {
        return;
      }
      setState(() {
        _snapshot = DashboardSnapshot(
          completedToday: today.where((item) => item.isComplete).length,
          scheduledToday: today.length,
          habitProgress: List.unmodifiable(activeProgress),
        );
        _error = null;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Dashboard belum dapat dimuat. Coba lagi.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = _snapshot;
    if (snapshot == null && _error == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(semanticsLabel: 'Memuat dashboard'),
        ),
      );
    }
    if (_error case final error?) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: ProkopaSpacing.cardPadding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(error, textAlign: TextAlign.center),
                  const SizedBox(height: ProkopaSpacing.lg),
                  FilledButton(
                    onPressed: _reload,
                    child: const Text('Coba lagi'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return DashboardContent(
      snapshot: snapshot!,
      profileName: widget.profileName,
      onRefresh: _reload,
    );
  }
}
