import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const CodeLevelApp());
}

class CodeLevelApp extends StatelessWidget {
  const CodeLevelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CodeLevel',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const LoginScreen(),
    );
  }
}
