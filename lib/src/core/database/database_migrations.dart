import 'package:sqflite/sqflite.dart';

typedef DatabaseMigration = ({
  int version,
  String name,
  List<String> statements,
});

const databaseSchemaVersion = 4;

const databaseMigrations = <DatabaseMigration>[
  (
    version: 1,
    name: 'create_schema_migrations',
    statements: [
      '''
      CREATE TABLE schema_migrations (
        version INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        applied_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
      ''',
    ],
  ),
  (
    version: 2,
    name: 'create_local_product_data',
    statements: [
      '''
      CREATE TABLE application_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
      ''',
      '''
      CREATE TABLE local_profiles (
        id TEXT PRIMARY KEY,
        name TEXT,
        avatar TEXT,
        selected_theme TEXT NOT NULL DEFAULT 'system'
          CHECK (selected_theme IN ('light', 'dark', 'system')),
        focus TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
      ''',
      '''
      CREATE TABLE habits (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        purpose TEXT,
        category TEXT,
        icon TEXT,
        color TEXT,
        frequency TEXT NOT NULL
          CHECK (frequency IN ('daily', 'specific_days', 'weekly_target')),
        specific_days TEXT,
        weekly_target INTEGER,
        cue_when TEXT,
        cue_where TEXT,
        cue_action TEXT,
        minimum_version TEXT,
        reminder_time TEXT,
        start_date TEXT NOT NULL,
        end_date TEXT,
        state TEXT NOT NULL DEFAULT 'active'
          CHECK (state IN ('created', 'active', 'paused', 'archived')),
        paused_at TEXT,
        archived_at TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        CHECK (
          (frequency = 'daily' AND specific_days IS NULL AND weekly_target IS NULL) OR
          (frequency = 'specific_days' AND specific_days IS NOT NULL AND weekly_target IS NULL) OR
          (frequency = 'weekly_target' AND specific_days IS NULL AND weekly_target > 0)
        )
      )
      ''',
      '''
      CREATE TABLE habit_pauses (
        id TEXT PRIMARY KEY,
        habit_id TEXT NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (habit_id) REFERENCES habits(id) ON DELETE CASCADE
      )
      ''',
      'CREATE INDEX habit_pauses_by_habit ON habit_pauses (habit_id, start_date)',
      '''
      CREATE TABLE habit_configuration_history (
        id TEXT PRIMARY KEY,
        habit_id TEXT NOT NULL,
        effective_from TEXT NOT NULL,
        effective_until TEXT,
        configuration TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (habit_id) REFERENCES habits(id) ON DELETE CASCADE,
        UNIQUE (habit_id, effective_from)
      )
      ''',
      '''
      CREATE TABLE habit_executions (
        id TEXT PRIMARY KEY,
        habit_id TEXT NOT NULL,
        planned_date TEXT NOT NULL,
        state TEXT NOT NULL CHECK (state IN ('completed', 'skipped', 'missed')),
        skip_reason TEXT,
        note TEXT,
        configuration_snapshot TEXT NOT NULL,
        recorded_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (habit_id) REFERENCES habits(id) ON DELETE CASCADE,
        UNIQUE (habit_id, planned_date),
        CHECK (
          (state = 'skipped' AND skip_reason IS NOT NULL) OR
          (state IN ('completed', 'missed') AND skip_reason IS NULL)
        )
      )
      ''',
      'CREATE INDEX habit_executions_by_date ON habit_executions (planned_date)',
      'CREATE INDEX habit_executions_by_habit_date ON habit_executions (habit_id, planned_date)',
      '''
      CREATE TABLE journal_entries (
        id TEXT PRIMARY KEY,
        entry_date TEXT NOT NULL,
        type TEXT NOT NULL CHECK (type IN ('free', 'guided')),
        title TEXT,
        body TEXT NOT NULL DEFAULT '',
        mood TEXT,
        energy TEXT,
        tags TEXT NOT NULL DEFAULT '[]',
        guided_responses TEXT,
        prompt_index INTEGER NOT NULL DEFAULT 0,
        status TEXT NOT NULL CHECK (status IN ('draft', 'saved')),
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
      ''',
      'CREATE INDEX journal_entries_by_date ON journal_entries (entry_date DESC)',
      '''
      CREATE TABLE mood_records (
        id TEXT PRIMARY KEY,
        recorded_at TEXT NOT NULL,
        record_date TEXT NOT NULL,
        valence TEXT NOT NULL CHECK (valence IN ('very_low', 'low', 'neutral', 'good', 'very_good')),
        energy TEXT CHECK (energy IN ('low', 'medium', 'high')),
        emotion TEXT CHECK (emotion IN ('calm', 'happy', 'tired', 'anxious', 'frustrated', 'sad', 'other')),
        context TEXT CHECK (context IN ('work', 'sleep', 'family', 'health', 'social', 'weather', 'exercise')),
        note TEXT
      )
      ''',
      'CREATE INDEX mood_records_by_date ON mood_records (record_date DESC)',
      '''
      CREATE TABLE sleep_records (
        id TEXT PRIMARY KEY,
        sleep_start TEXT NOT NULL,
        sleep_end TEXT NOT NULL,
        wake_date TEXT NOT NULL,
        duration_minutes INTEGER NOT NULL CHECK (duration_minutes > 0 AND duration_minutes <= 1440),
        quality TEXT NOT NULL CHECK (quality IN ('poor', 'fair', 'good', 'excellent')),
        note TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        CHECK (sleep_end > sleep_start)
      )
      ''',
      'CREATE INDEX sleep_records_by_wake_date ON sleep_records (wake_date DESC)',
      '''
      CREATE TABLE reviews (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL CHECK (type IN ('weekly', 'monthly')),
        period_start TEXT NOT NULL,
        period_end TEXT NOT NULL,
        reflection TEXT,
        data TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        UNIQUE (type, period_start)
      )
      ''',
      '''
      CREATE TABLE insights (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        period_start TEXT NOT NULL,
        period_end TEXT NOT NULL,
        observation TEXT NOT NULL,
        evidence TEXT NOT NULL,
        action TEXT,
        dismissed_at TEXT,
        created_at TEXT NOT NULL,
        UNIQUE (type, period_start, period_end, observation)
      )
      ''',
      '''
      CREATE TABLE achievements (
        key TEXT PRIMARY KEY,
        earned_at TEXT NOT NULL,
        metadata TEXT NOT NULL DEFAULT '{}'
      )
      ''',
      '''
      CREATE TABLE notification_preferences (
        id TEXT PRIMARY KEY,
        kind TEXT NOT NULL CHECK (kind IN ('habit', 'journal', 'sleep', 'weekly_review')),
        habit_id TEXT,
        enabled INTEGER NOT NULL DEFAULT 0 CHECK (enabled IN (0, 1)),
        time_of_day TEXT,
        weekdays TEXT,
        privacy_mode TEXT NOT NULL DEFAULT 'generic' CHECK (privacy_mode IN ('generic', 'detailed')),
        updated_at TEXT NOT NULL,
        FOREIGN KEY (habit_id) REFERENCES habits(id) ON DELETE CASCADE
      )
      ''',
      'CREATE INDEX notification_preferences_by_habit ON notification_preferences (habit_id)',
      '''
      CREATE TABLE backup_metadata (
        id TEXT PRIMARY KEY,
        created_at TEXT NOT NULL,
        schema_version INTEGER NOT NULL,
        checksum TEXT NOT NULL,
        record_counts TEXT NOT NULL
      )
      ''',
    ],
  ),
  (
    version: 3,
    name: 'create_habit_recoveries',
    statements: [
      '''
      CREATE TABLE habit_recoveries (
        id TEXT PRIMARY KEY,
        habit_id TEXT NOT NULL,
        action TEXT NOT NULL
          CHECK (action IN ('continue', 'reduce_target', 'change_cue', 'pause')),
        recorded_at TEXT NOT NULL,
        FOREIGN KEY (habit_id) REFERENCES habits(id) ON DELETE CASCADE
      )
      ''',
      'CREATE INDEX habit_recoveries_by_habit ON habit_recoveries (habit_id, recorded_at DESC)',
    ],
  ),
  (
    version: 4,
    name: 'add_habit_reminder_days',
    statements: [
      'ALTER TABLE habits ADD COLUMN reminder_days TEXT',
    ],
  ),
];

Future<void> runDatabaseMigrations(
  DatabaseExecutor database,
  int oldVersion,
  int newVersion,
  List<DatabaseMigration> migrations,
) async {
  if (newVersion < oldVersion) {
    throw StateError('Database migrations are forward-only.');
  }

  final pending = migrations
      .where((step) => step.version > oldVersion && step.version <= newVersion)
      .toList();
  var expectedVersion = oldVersion + 1;
  for (final migration in pending) {
    if (migration.version != expectedVersion) {
      throw StateError('Expected migration $expectedVersion.');
    }
    expectedVersion++;
  }
  if (expectedVersion != newVersion + 1) {
    throw StateError('Missing migration $expectedVersion.');
  }

  for (final migration in pending) {
    try {
      for (final statement in migration.statements) {
        await database.execute(statement);
      }
      await database.insert('schema_migrations', {
        'version': migration.version,
        'name': migration.name,
      });
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        DatabaseMigrationException(migration.version, migration.name, error),
        stackTrace,
      );
    }
  }
}

class DatabaseMigrationException implements Exception {
  const DatabaseMigrationException(this.version, this.name, this.cause);

  final int version;
  final String name;
  final Object cause;

  @override
  String toString() => 'Migration $version ($name) failed: $cause';
}
