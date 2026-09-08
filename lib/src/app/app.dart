import 'package:flutter/material.dart';
import 'package:prokopa/src/app/app_shell.dart';
import 'package:prokopa/src/app/app_theme.dart';

class ProkopaApp extends StatelessWidget {
  const ProkopaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prokopa: Habits and Jurnaling',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: const AppShell(),
    );
  }
}
