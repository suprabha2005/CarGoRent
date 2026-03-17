import 'package:flutter/material.dart';
import 'auth_guard.dart';
import 'screens/landing_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/vehicle_listing_screen.dart';
import 'screens/vendor_dashboard.dart';
import 'screens/admin_dashboard.dart';
import 'screens/vendor_verification_screen.dart';
import 'screens/vendor_pending_screen.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/landing',
      routes: {
        // ✅ Public routes — no guard needed
        '/landing': (context) => const LandingScreen(),
        '/login':   (context) => const LoginScreen(),
        '/register':(context) => const RegisterScreen(),

        // ✅ Customer routes — only logged in customers
        '/home': (context) => AuthGuard(
          allowedRoles: ['customer'],
          child: const HomeScreen(),
        ),
        '/vehicles': (context) => AuthGuard(
          allowedRoles: ['customer'],
          child: const VehicleListingScreen(),
        ),

        // ✅ Vendor routes — only vendors
        '/vendor_dashboard': (context) => AuthGuard(
          allowedRoles: ['vendor'],
          child: const VendorDashboard(),
        ),
        '/vendor_verification': (context) => AuthGuard(
          allowedRoles: ['vendor'],
          child: const VendorVerificationScreen(),
        ),
        '/vendor_pending': (context) => AuthGuard(
          allowedRoles: ['vendor'],
          child: const VendorPendingScreen(),
        ),

        // ✅ Admin routes — only admins
        '/admin_dashboard': (context) => AuthGuard(
          allowedRoles: ['admin'],
          child: const AdminDashboard(),
        ),
      },
    );
  }
}