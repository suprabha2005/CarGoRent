import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/vendor_dashboard.dart';
import 'screens/admin_dashboard.dart';
import 'screens/vendor_verification_screen.dart';

void main() {
  runApp(const CarGoRentApp());
}

class CarGoRentApp extends StatelessWidget {
  const CarGoRentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CarGoRent',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        
        // Customer Panel
        '/home': (context) => const HomeScreen(),
        
        // Vendor Panel
        '/vendor_dashboard': (context) => const VendorDashboard(),
        '/vendor_verification': (context) => const VendorVerificationScreen(),
        
        // Admin Panel
        '/admin_dashboard': (context) => const AdminDashboard(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        );
      },
    );
  }
}