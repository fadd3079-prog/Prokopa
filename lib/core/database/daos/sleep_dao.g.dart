// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sleep_dao.dart';

// ignore_for_file: type=lint
mixin _$SleepDaoMixin on DatabaseAccessor<AppDatabase> {
  $SleepRecordsTable get sleepRecords => attachedDatabase.sleepRecords;
  SleepDaoManager get managers => SleepDaoManager(this);
}

class SleepDaoManager {
  final _$SleepDaoMixin _db;
  SleepDaoManager(this._db);
  $$SleepRecordsTableTableManager get sleepRecords =>
      $$SleepRecordsTableTableManager(_db.attachedDatabase, _db.sleepRecords);
}
