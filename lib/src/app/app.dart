import 'package:flutter/material.dart';
import 'package:prokopa/src/app/bootstrap_screen.dart';

class ProkopaApp extends StatelessWidget {
  const ProkopaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Prokopa: Habits and Jurnaling',
      debugShowCheckedModeBanner: false,
      home: BootstrapScreen(),
    );
  }
}
