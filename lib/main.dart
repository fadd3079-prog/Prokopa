import 'package:flutter/widgets.dart';
import 'package:prokopa/src/app/app.dart';
import 'package:prokopa/src/core/database/app_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = await openAppDatabase();
  runApp(ProkopaApp(database: database));
}
