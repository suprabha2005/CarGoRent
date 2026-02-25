import 'package:flutter/material.dart';
import 'screens/landing_screen.dart'; // <--- THIS LINE IS THE FIX
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CarGoRent',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      // Starting point is now the themed Landing Screen
      home: const LandingScreen(), 
    );
  }
}