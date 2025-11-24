import 'package:flutter/material.dart';
import 'package:studymate/screens/home_screen.dart';
// import 'screens/splash_screen.dart'; // nanti uncomment 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudyMate',
      theme: ThemeData(
        primaryColor: const Color(0xFF03045E),
        fontFamily: 'Inter',
      ),
      home: const HomePage(), // nanti ganti ke splash screen
      debugShowCheckedModeBanner: false,
    );
  }
}
