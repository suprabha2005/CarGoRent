import 'package:flutter/material.dart';
import 'package:cargo_rent_app/screens/splash_screen.dart';
import 'package:cargo_rent_app/screens/landing_screen.dart'; 
import 'package:cargo_rent_app/screens/login_screen.dart';
import 'package:cargo_rent_app/screens/register_screen.dart';
import 'package:cargo_rent_app/screens/home_screen.dart';
import 'package:cargo_rent_app/screens/vendor_dashboard.dart';
import 'package:cargo_rent_app/screens/admin_dashboard.dart';
import 'package:cargo_rent_app/screens/vendor_verification_screen.dart';
import 'package:cargo_rent_app/screens/vehicle_listing_screen.dart';

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
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F172A),
          primary: const Color(0xFF0F172A),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto', 
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/landing': (context) => const LandingScreen(),
        '/login': (context) => const LoginScreen(), 
        '/register': (context) => const RegisterScreen(),
        '/vehicles': (context) => const VehicleListingScreen(),
        '/home': (context) => const HomeScreen(),
        '/vendor_dashboard': (context) => const VendorDashboard(),
        '/vendor_verification': (context) => const VendorVerificationScreen(),
        '/admin_dashboard': (context) => const AdminDashboard(),
      },
    );
  }
}