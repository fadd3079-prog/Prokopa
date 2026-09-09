import 'package:flutter/material.dart';
import 'package:prokopa/src/achievements/achievement_store.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key, required this.store});

  final AchievementStore store;

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  List<AchievementState>? _achievements;
  String? _error;
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    try {
      final achievements = await widget.store.evaluate();
      if (mounted) {
        setState(() {
          _achievements = achievements;
          _error = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Pencapaian belum dapat dimuat. Coba lagi.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final achievements = _achievements;
    final visible = achievements
        ?.where(
          (achievement) => switch (_filter) {
            'Unlocked' => achievement.isUnlocked,
            'Locked' => !achievement.isUnlocked,
            'All' => true,
            _ => achievement.category == _filter,
          },
        )
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Pencapaian')),
      body: SafeArea(
        child: achievements == null
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
                child: FilledButton(
                  onPressed: _reload,
                  child: const Text('Coba lagi'),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: visible!.length + 1,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          'All',
                          'Unlocked',
                          'Locked',
                          'Habit',
                          'Journal',
                          'Sleep',
                          'Recovery',
                        ]
                            .map(
                              (filter) => FilterChip(
                                label: Text(filter),
                                selected: _filter == filter,
                                onSelected: (_) =>
                                    setState(() => _filter = filter),
                              ),
                            )
                            .toList(),
                      ),
                    );
                  }
                  final achievement = visible[index - 1];
                  final progress = achievement.progress > achievement.target
                      ? achievement.target
                      : achievement.progress;
                  return ListTile(
                    onTap: () => _showDetail(achievement),
                    leading: Icon(
                      achievement.isUnlocked
                          ? Icons.verified_outlined
                          : Icons.lock_outline,
                      semanticLabel: achievement.isUnlocked
                          ? 'Terbuka'
                          : 'Belum terbuka',
                    ),
                    title: Text(achievement.title),
                    subtitle: Text(
                      '${achievement.requirement}\n$progress/${achievement.target}',
                    ),
                    isThreeLine: true,
                  );
                },
              ),
      ),
    );
  }

  Future<void> _showDetail(AchievementState achievement) {
    final progress = achievement.progress.clamp(0, achievement.target);
    return showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(achievement.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(achievement.description),
              const SizedBox(height: 8),
              Text('Kategori: ${achievement.category}'),
              Text('Persyaratan: ${achievement.requirement}'),
              Text('Progres: $progress/${achievement.target}'),
              Text('Penghargaan: ${achievement.reward}'),
              if (achievement.earnedAt != null)
                Text('Terbuka: ${achievement.earnedAt!.toLocal()}')
              else
                const Text('Belum terbuka'),
            ],
          ),
        ),
      ),
    );
  }
}
