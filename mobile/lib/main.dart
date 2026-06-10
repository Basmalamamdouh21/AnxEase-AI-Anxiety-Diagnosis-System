import 'package:flutter/material.dart';
import 'features/splash/screen.dart';
import 'core/theme/_theme.dart';

void main() {
  runApp(const AnxEaseApp());
}

class AnxEaseApp extends StatelessWidget {
  const AnxEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
