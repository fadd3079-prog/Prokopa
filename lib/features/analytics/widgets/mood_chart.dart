import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MoodTrend {
  final DateTime date;
  final int moodScore; // 1-5

  MoodTrend({required this.date, required this.moodScore});
}

class MoodChart extends StatelessWidget {
  final List<MoodTrend> data;

  const MoodChart({super.key, required this.data});

  Color _getMoodColor(double score) {
    if (score >= 4.5) return Colors.green;
    if (score >= 3.5) return Colors.lightGreen;
    if (score >= 2.5) return Colors.orangeAccent;
    if (score >= 1.5) return Colors.orange;
    return Colors.red;
  }

  String _getMoodEmoji(int score) {
    switch (score) {
      case 1:
        return '😫';
      case 2:
        return '😞';
      case 3:
        return '😐';
      case 4:
        return '🙂';
      case 5:
        return '🤩';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const Center(child: Text('No mood data'));

    final sortedData = List<MoodTrend>.from(data)
      ..sort((a, b) => a.date.compareTo(b.date));
    final spots = <FlSpot>[];

    for (int i = 0; i < sortedData.length; i++) {
      spots.add(FlSpot(i.toDouble(), sortedData[i].moodScore.toDouble()));
    }

    return AspectRatio(
      aspectRatio: 1.7,
      child: Padding(
        padding: const EdgeInsets.only(
          right: 18,
          left: 12,
          top: 24,
          bottom: 12,
        ),
        child: LineChart(
          LineChartData(
            minY: 1,
            maxY: 5,
            gridData: const FlGridData(show: false),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: sortedData.length > 7
                      ? (sortedData.length / 5).ceilToDouble()
                      : 1,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= 0 &&
                        value.toInt() < sortedData.length) {
                      final date = sortedData[value.toInt()].date;
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          '${date.day}/${date.month}',
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      _getMoodEmoji(value.toInt()),
                      style: const TextStyle(fontSize: 14),
                    );
                  },
                ),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: Theme.of(context).colorScheme.secondary,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(show: false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
