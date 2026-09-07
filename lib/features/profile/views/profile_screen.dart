import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/features/profile/providers/profile_providers.dart';
import 'package:habitflow/core/providers/core_providers.dart';
import 'package:habitflow/core/services/notification_service.dart';
import 'package:habitflow/shared/widgets/stat_card.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);
    final statsAsync = ref.watch(userStatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            userAsync.when(
              data: (user) {
                final name = user.name.isNotEmpty ? user.name : 'User';
                final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

                return Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      child: Text(
                        initial,
                        style: const TextStyle(fontSize: 40),
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () {
                        _showEditNameDialog(context, ref, name);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.edit, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => const Text('Failed to load profile'),
            ),
            const SizedBox(height: 32),
            statsAsync.when(
              data: (stats) => Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Level ${stats.level}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${stats.totalXp} XP',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (stats.totalXp % 500) / 500.0,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 24),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      StatCard(
                        icon: const Icon(Icons.check_circle_outline),
                        value: stats.habitsCreated.toString(),
                        label: 'Habits Created',
                      ),
                      StatCard(
                        icon: const Icon(Icons.book_outlined),
                        value: stats.journalEntries.toString(),
                        label: 'Journal Entries',
                      ),
                      StatCard(
                        icon: const Icon(Icons.bedtime_outlined),
                        value: stats.sleepLogs.toString(),
                        label: 'Sleep Logs',
                      ),
                      StatCard(
                        icon: const Icon(Icons.calendar_today_outlined),
                        value: stats.daysActive.toString(),
                        label: 'Days Active',
                      ),
                    ],
                  ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => const Text('Failed to load stats'),
            ),
            const SizedBox(height: 32),
            Card(
              child: ListTile(
                leading: const Icon(Icons.brightness_6),
                title: const Text('Theme'),
                trailing: DropdownButton<String>(
                  value: switch (ref.watch(themeModeProvider)) {
                    ThemeMode.light => 'Light',
                    ThemeMode.dark => 'Dark',
                    _ => 'System',
                  },
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'Light', child: Text('Light')),
                    DropdownMenuItem(value: 'Dark', child: Text('Dark')),
                    DropdownMenuItem(value: 'System', child: Text('System')),
                  ],
                  onChanged: (val) {
                    if (val == null) return;
                    final mode = switch (val) {
                      'Light' => ThemeMode.light,
                      'Dark' => ThemeMode.dark,
                      _ => ThemeMode.system,
                    };
                    ref.read(themeModeProvider.notifier).setThemeMode(mode);
                    ref.read(databaseProvider).userDao.updateTheme(val.toLowerCase());
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Text(
                        'Reminders',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.notifications_active_outlined),
                      title: const Text('Habit Reminder'),
                      subtitle: const Text('Time to complete your habit.'),
                      trailing: IconButton(
                        icon: const Icon(Icons.send_outlined, size: 20),
                        tooltip: 'Send reminder',
                        onPressed: () async {
                          await ref.read(notificationServiceProvider).scheduleHabitReminder();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Habit reminder triggered!')),
                            );
                          }
                        },
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.edit_note_outlined),
                      title: const Text('Journal Reminder'),
                      subtitle: const Text('Reflect your day.'),
                      trailing: IconButton(
                        icon: const Icon(Icons.send_outlined, size: 20),
                        tooltip: 'Send reminder',
                        onPressed: () async {
                          await ref.read(notificationServiceProvider).scheduleJournalReminder();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Journal reminder triggered!')),
                            );
                          }
                        },
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.bedtime_outlined),
                      title: const Text('Sleep Reminder'),
                      subtitle: const Text('Prepare for better sleep.'),
                      trailing: IconButton(
                        icon: const Icon(Icons.send_outlined, size: 20),
                        tooltip: 'Send reminder',
                        onPressed: () async {
                          await ref.read(notificationServiceProvider).scheduleSleepReminder();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Sleep reminder triggered!')),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => context.push('/achievements'),
              icon: const Icon(Icons.emoji_events),
              label: const Text('View Achievements'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'HabitFlow v1.0.0',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditNameDialog(
    BuildContext context,
    WidgetRef ref,
    String currentName,
  ) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter your name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                final db = ref.read(databaseProvider);
                await db.userDao.updateName(newName);
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
