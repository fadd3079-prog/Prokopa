import 'package:drift/drift.dart';

/// Users table for storing user profile data.
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withDefault(const Constant('User'))();
  TextColumn get avatar => text().withDefault(const Constant('default'))();
  TextColumn get theme => text().withDefault(const Constant('system'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

