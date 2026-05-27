import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const CampusTourApp());
}

class CampusTourApp extends StatelessWidget {
  const CampusTourApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '西南大学校园导览',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.green,
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
