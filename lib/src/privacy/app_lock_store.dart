import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:prokopa/src/core/date/local_date.dart';
import 'package:sqflite/sqflite.dart';

class AppLockStore {
  AppLockStore(
    this._database, {
    FlutterSecureStorage? secureStorage,
    LocalAuthentication? authentication,
  }) : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
       _authentication = authentication ?? LocalAuthentication();

  static const _enabledKey = 'app_lock_enabled';
  static const _timeoutKey = 'app_lock_timeout_minutes';
  static const _pinKey = 'app_lock_pin';

  final Database _database;
  final FlutterSecureStorage _secureStorage;
  final LocalAuthentication _authentication;

  Future<bool> isEnabled() async {
    final rows = await _database.query(
      'application_settings',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [_enabledKey],
      limit: 1,
    );
    return rows.singleOrNull?['value'] == 'true';
  }

  Future<int> timeoutMinutes() async {
    final rows = await _database.query(
      'application_settings',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [_timeoutKey],
      limit: 1,
    );
    return int.tryParse(rows.singleOrNull?['value'] as String? ?? '') ?? 1;
  }

  Future<void> enablePin(String pin, {int timeout = 1}) async {
    _validatePin(pin);
    final salt = List<int>.generate(16, (_) => Random.secure().nextInt(256));
    final encoded =
        '${base64UrlEncode(salt)}:${sha256.convert([...salt, ...utf8.encode(pin)]).toString()}';
    await _secureStorage.write(key: _pinKey, value: encoded);
    await _saveSetting(_enabledKey, 'true');
    await _saveSetting(_timeoutKey, timeout.toString());
  }

  Future<bool> verifyPin(String pin) async {
    final saved = await _secureStorage.read(key: _pinKey);
    if (saved == null || !saved.contains(':')) {
      return false;
    }
    final parts = saved.split(':');
    final salt = base64Url.decode(parts.first);
    final actual = sha256.convert([...salt, ...utf8.encode(pin)]).toString();
    return actual == parts.last;
  }

  Future<bool> unlockWithDevice() async {
    try {
      if (!await _authentication.isDeviceSupported()) {
        return false;
      }
      return await _authentication.authenticate(
        localizedReason: 'Buka Prokopa di perangkat ini.',
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    }
  }

  Future<bool> canUseDeviceAuthentication() async {
    try {
      return await _authentication.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  Future<void> disable() async {
    await _secureStorage.delete(key: _pinKey);
    await _saveSetting(_enabledKey, 'false');
  }

  Future<void> deleteAllData() async {
    const tables = [
      'notification_preferences',
      'habit_recoveries',
      'habit_pauses',
      'habit_executions',
      'habit_configuration_history',
      'habits',
      'journal_entries',
      'mood_records',
      'sleep_records',
      'reviews',
      'insights',
      'achievements',
      'backup_metadata',
      'local_profiles',
      'application_settings',
    ];
    await _database.transaction((transaction) async {
      for (final table in tables) {
        await transaction.delete(table);
      }
    });
    await _secureStorage.delete(key: _pinKey);
  }

  Future<void> _saveSetting(String key, String value) {
    return _database.insert('application_settings', {
      'key': key,
      'value': value,
      'updated_at': utcTimestamp(DateTime.now()),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  void _validatePin(String pin) {
    if (!RegExp(r'^\d{4,12}$').hasMatch(pin)) {
      throw ArgumentError.value(
        pin,
        'pin',
        'PIN harus terdiri dari 4 hingga 12 angka.',
      );
    }
  }
}
