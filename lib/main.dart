<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'package:prokopa/src/app/app.dart';

void main() {
  runApp(const ProkopaApp());
=======
import 'package:flutter/widgets.dart';
import 'package:prokopa/src/app/app.dart';
import 'package:prokopa/src/core/database/app_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = await openAppDatabase();
  runApp(ProkopaApp(database: database));
>>>>>>> ae41a87e6beda91e9f6606e3b2f76b10d3024898
}
