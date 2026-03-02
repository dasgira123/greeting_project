import 'package:flutter/material.dart';
import 'package:greeting_project/views/main_screen.dart';

void main() {
  runApp(const TetGreetingApp());
}

class TetGreetingApp extends StatelessWidget {
  const TetGreetingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tết Greeting',
      theme: ThemeData(
        primaryColor: const Color(0xFFD32F2F),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        fontFamily: 'Roboto',
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}