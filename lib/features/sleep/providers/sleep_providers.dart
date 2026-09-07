import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/core/database/app_database.dart';
import 'package:habitflow/core/providers/core_providers.dart';

final allSleepRecordsProvider = StreamProvider<List<SleepRecord>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.sleepDao.watchAllRecords();
});

final latestSleepProvider = FutureProvider<SleepRecord?>((ref) async {
  final db = ref.watch(databaseProvider);
  final records = await db.sleepDao.getRecentRecords(1);
  return records.isNotEmpty ? records.first : null;
});

class SleepStats {
  final double avgDuration;
  final double avgQuality;
  final double consistency;

  SleepStats({
    required this.avgDuration,
    required this.avgQuality,
    required this.consistency,
  });
}

final sleepStatsProvider = FutureProvider<SleepStats>((ref) async {
  final db = ref.watch(databaseProvider);
  final last7Days = await db.sleepDao.getRecentRecords(7);
  final last30Days = await db.sleepDao.getRecentRecords(30);

  double avgDuration = 0;
  double avgQuality = 0;

  if (last7Days.isNotEmpty) {
    for (var record in last7Days) {
      final duration =
          record.sleepEnd.difference(record.sleepStart).inMinutes / 60.0;
      avgDuration += duration;
      avgQuality += record.quality;
    }
    avgDuration /= last7Days.length;
    avgQuality /= last7Days.length;
  }

  double consistency = 0;
  if (last30Days.isNotEmpty) {
    consistency = (last30Days.length / 30.0) * 100.0;
  }

  return SleepStats(
    avgDuration: avgDuration,
    avgQuality: avgQuality,
    consistency: consistency.clamp(0.0, 100.0),
  );
});

final weeklySleepDataProvider = FutureProvider<List<SleepRecord>>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.sleepDao.getRecentRecords(7);
});
