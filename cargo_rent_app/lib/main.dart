import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_guard.dart';
import 'providers/auth_provider.dart';
import 'providers/car_provider.dart';
import 'providers/booking_provider.dart';
import 'screens/auth/landing_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/customer/home_screen.dart';
import 'screens/customer/vehicle_listing_screen.dart';
import 'screens/vendor/vendor_dashboard.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/vendor/vendor_verification_screen.dart';
import 'screens/vendor/vendor_pending_screen.dart';

void main() {
  runApp(const CarGoRentApp());
}

class CarGoRentApp extends StatelessWidget {
  const CarGoRentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..loadSession()),
        ChangeNotifierProvider(create: (_) => CarProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
      ],
      child: MaterialApp(
        title: 'CarGoRent',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        initialRoute: '/landing',
        routes: {
          '/landing':   (context) => const LandingScreen(),
          '/login':     (context) => const LoginScreen(),
          '/register':  (context) => const RegisterScreen(),
          '/home': (context) => AuthGuard(
            allowedRoles: ['customer'],
            child: const HomeScreen(),
          ),
          '/vehicles': (context) => AuthGuard(
            allowedRoles: ['customer'],
            child: const VehicleListingScreen(),
          ),
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
          '/admin_dashboard': (context) => AuthGuard(
            allowedRoles: ['admin'],
            child: const AdminDashboard(),
          ),
        },
      ),
    );
  }
}