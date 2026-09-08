import 'package:prokopa/src/core/date/local_date.dart';
import 'package:prokopa/src/profile/local_profile.dart';
import 'package:sqflite/sqflite.dart';

class ProfileStore {
  ProfileStore(this._database);

  static const _profileId = 'local';
  static const _onboardingKey = 'onboarding_completed';

  final Database _database;

  Future<LocalProfile?> load() async {
    final rows = await _database.query(
      'local_profiles',
      where: 'id = ?',
      whereArgs: [_profileId],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return _profileFromRow(rows.single);
  }

  Future<bool> isOnboardingComplete() async {
    final rows = await _database.query(
      'application_settings',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [_onboardingKey],
      limit: 1,
    );
    return rows.singleOrNull?['value'] == 'true';
  }

  Future<void> save(LocalProfile profile) {
    _validate(profile);
    final now = utcTimestamp(DateTime.now());
    return _database.insert('local_profiles', {
      'id': _profileId,
      'name': profile.name.trim(),
      'avatar': profile.avatar,
      'selected_theme': profile.appearance.value,
      'focus': profile.focus,
      'created_at': utcTimestamp(profile.createdAt),
      'updated_at': now,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> completeOnboarding(LocalProfile profile) async {
    _validate(profile);
    final now = utcTimestamp(DateTime.now());
    await _database.transaction((transaction) async {
      await transaction.insert('local_profiles', {
        'id': _profileId,
        'name': profile.name.trim(),
        'avatar': profile.avatar,
        'selected_theme': profile.appearance.value,
        'focus': profile.focus,
        'created_at': utcTimestamp(profile.createdAt),
        'updated_at': now,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      await transaction.insert('application_settings', {
        'key': _onboardingKey,
        'value': 'true',
        'updated_at': now,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  Future<void> updateAppearance(AppAppearance appearance) async {
    await _database.update(
      'local_profiles',
      {
        'selected_theme': appearance.value,
        'updated_at': utcTimestamp(DateTime.now()),
      },
      where: 'id = ?',
      whereArgs: [_profileId],
    );
  }

  LocalProfile _profileFromRow(Map<String, Object?> row) {
    return LocalProfile(
      id: row['id']! as String,
      name: row['name']! as String,
      avatar: (row['avatar'] as String?) ?? 'primary',
      appearance: AppAppearanceValue.fromValue(
        row['selected_theme']! as String,
      ),
      focus: row['focus'] as String?,
      createdAt: DateTime.parse(row['created_at']! as String),
    );
  }

  void _validate(LocalProfile profile) {
    if (profile.name.trim().isEmpty) {
      throw ArgumentError.value(
        profile.name,
        'name',
        'A local name is required.',
      );
    }
  }
}
