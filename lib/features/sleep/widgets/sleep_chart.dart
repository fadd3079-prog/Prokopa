import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/features/sleep/providers/sleep_providers.dart';
import 'package:habitflow/shared/models/enums.dart';

class SleepChart extends ConsumerWidget {
  const SleepChart({super.key});

  Color _getColorForQuality(SleepQuality quality) {
    switch (quality) {
      case SleepQuality.excellent:
      case SleepQuality.good:
        return Colors.green;
      case SleepQuality.fair:
        return Colors.amber;
      case SleepQuality.poor:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyDataAsync = ref.watch(weeklySleepDataProvider);

    return weeklyDataAsync.when(
      data: (records) {
        final Map<int, double> hoursMap = {};
        final Map<int, SleepQuality> qualityMap = {};

        final now = DateTime.now();
        for (int i = 0; i < 7; i++) {
          final date = now.subtract(Duration(days: 6 - i));
          hoursMap[i] = 0.0;
          qualityMap[i] = SleepQuality.fair;

          for (var record in records) {
            if (record.sleepStart.year == date.year &&
                record.sleepStart.month == date.month &&
                record.sleepStart.day == date.day) {
              final duration = record.sleepEnd.difference(record.sleepStart);
              hoursMap[i] = duration.inMinutes / 60.0;
              qualityMap[i] = SleepQuality.fromScore(record.quality);
              break;
            }
          }
        }

        return BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 12,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    '${rod.toY.toStringAsFixed(1)} h',
                    const TextStyle(color: Colors.white),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index > 6) return const SizedBox.shrink();
                    final date = now.subtract(Duration(days: 6 - index));
                    final weekday = [
                      'Mon',
                      'Tue',
                      'Wed',
                      'Thu',
                      'Fri',
                      'Sat',
                      'Sun',
                    ][date.weekday - 1];
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        weekday,
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 3,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '${value.toInt()}h',
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barGroups: List.generate(7, (index) {
              final hours = hoursMap[index] ?? 0.0;
              final quality = qualityMap[index] ?? SleepQuality.fair;
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: hours > 0 ? hours : 0.1,
                    color: hours > 0
                        ? _getColorForQuality(quality)
                        : Colors.grey.shade300,
                    width: 16,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              );
            }),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }
}
