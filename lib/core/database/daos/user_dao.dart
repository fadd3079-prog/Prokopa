import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/users_table.dart';

part 'user_dao.g.dart';

/// Data access object for user profile operations.
@DriftAccessor(tables: [Users])
class UserDao extends DatabaseAccessor<AppDatabase> with _$UserDaoMixin {
  UserDao(super.db);

  /// Get the current user profile.
  Future<User> getUser() async {
    final users = await select(this.users).get();
    if (users.isEmpty) {
      // Create default user if none exists
      final id = await into(this.users).insert(UsersCompanion.insert());
      return (await (select(this.users)..where((t) => t.id.equals(id))).getSingle());
    }
    return users.first;
  }

  /// Watch the current user profile for reactive updates.
  Stream<User> watchUser() {
    return (select(users)..limit(1)).watchSingle();
  }

  /// Update user name.
  Future<void> updateName(String name) async {
    final user = await getUser();
    await (update(users)..where((t) => t.id.equals(user.id)))
        .write(UsersCompanion(name: Value(name)));
  }

  /// Update user avatar.
  Future<void> updateAvatar(String avatar) async {
    final user = await getUser();
    await (update(users)..where((t) => t.id.equals(user.id)))
        .write(UsersCompanion(avatar: Value(avatar)));
  }

  /// Update theme preference.
  Future<void> updateTheme(String theme) async {
    final user = await getUser();
    await (update(users)..where((t) => t.id.equals(user.id)))
        .write(UsersCompanion(theme: Value(theme)));
  }
}

