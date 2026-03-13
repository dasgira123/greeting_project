import 'package:flutter/material.dart';
import 'package:greeting_project/views/home/main_screen.dart';
import 'package:provider/provider.dart';
import 'di.dart';
// THÊM DÒNG NÀY: Import file main_screen.dart của bạn vào

void main() {
  runApp(
    MultiProvider(
      providers: globalProviders,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Greeting App',
      theme: ThemeData(
        primarySwatch: Colors.red, // Đổi sang màu đỏ cho có không khí Tết
        useMaterial3: true,        // Bật Material 3 để thanh điều hướng đẹp hơn
      ),
      debugShowCheckedModeBanner: false,

      // QUAN TRỌNG NHẤT Ở ĐÂY:
      // Sửa HomeScreen() thành MainScreen()
      home: const MainScreen(),
    );
  }
}