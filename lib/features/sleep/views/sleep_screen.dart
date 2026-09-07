import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/core/utils/date_utils.dart';
import 'package:habitflow/features/sleep/providers/sleep_providers.dart';
import 'package:habitflow/features/sleep/widgets/sleep_chart.dart';
import 'package:habitflow/shared/models/enums.dart';

class SleepScreen extends ConsumerWidget {
  const SleepScreen({super.key});

  String _getEmojiForQuality(SleepQuality quality) {
    switch (quality) {
      case SleepQuality.poor:
        return '😩';
      case SleepQuality.fair:
        return '🥱';
      case SleepQuality.good:
        return '😌';
      case SleepQuality.excellent:
        return '🤩';
      default:
        return '😴';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latestSleepAsync = ref.watch(latestSleepProvider);
    final statsAsync = ref.watch(sleepStatsProvider);
    final historyAsync = ref.watch(allSleepRecordsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Sleep')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              latestSleepAsync.when(
                data: (record) {
                  if (record == null) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No sleep data for last night.'),
                      ),
                    );
                  }
                  final duration = record.sleepEnd.difference(
                    record.sleepStart,
                  );
                  final hours = duration.inHours;
                  final minutes = duration.inMinutes % 60;

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Text(
                            _getEmojiForQuality(
                              SleepQuality.fromScore(record.quality),
                            ),
                            style: const TextStyle(fontSize: 48),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Last Night',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '$hours h $minutes m',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${TimeOfDay.fromDateTime(record.sleepStart).format(context)} - ${TimeOfDay.fromDateTime(record.sleepEnd).format(context)}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Text('Error: $e'),
              ),
              const SizedBox(height: 24),

              const Text(
                'Last 7 Days',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 200, child: SleepChart()),
              const SizedBox(height: 24),

              statsAsync.when(
                data: (stats) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCard(
                      'Avg Duration',
                      '${stats.avgDuration.toStringAsFixed(1)} h',
                      context,
                    ),
                    _buildStatCard(
                      'Avg Quality',
                      stats.avgQuality.toStringAsFixed(1),
                      context,
                    ),
                    _buildStatCard(
                      'Consistency',
                      '${stats.consistency.toStringAsFixed(0)}%',
                      context,
                    ),
                  ],
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Text('Error: $e'),
              ),
              const SizedBox(height: 24),

              const Text(
                'History',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              historyAsync.when(
                data: (records) {
                  if (records.isEmpty) {
                    return const Text('No sleep history.');
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final record = records[index];
                      final duration = record.sleepEnd.difference(
                        record.sleepStart,
                      );

                      return ListTile(
                        leading: Text(
                          _getEmojiForQuality(
                            SleepQuality.fromScore(record.quality),
                          ),
                          style: const TextStyle(fontSize: 24),
                        ),
                        title: Text(
                          '${duration.inHours}h ${duration.inMinutes % 60}m',
                        ),
                        subtitle: Text(
                          AppDateUtils.formatDate(record.sleepStart),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Text('Error: $e'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/sleep/log'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
