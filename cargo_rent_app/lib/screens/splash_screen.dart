import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/api_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  void _navigateToNext() async {
    // 3-second delay for branding and background data checking
    await Future.delayed(const Duration(seconds: 3));
    
    // Fetch auth data from local storage/API service
    String? token = await _apiService.getToken();
    String? role = await _apiService.getRole();

    if (!mounted) return;

    // Logic to route users based on their session and role
    if (token != null && role != null) {
      if (role == 'admin') {
        Navigator.pushReplacementNamed(context, '/admin_dashboard');
      } else if (role == 'vendor') {
        Navigator.pushReplacementNamed(context, '/vendor_dashboard');
      } else {
        // Standard User/Customer
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      // No session found, send to Landing Screen
      Navigator.pushReplacementNamed(context, '/landing');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF0F172A), // Matching your theme color
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Icon
            const Icon(
              Icons.directions_car_filled_rounded, 
              size: 80, 
              color: Colors.white
            ).animate()
             .fadeIn(duration: 600.ms)
             .scale(delay: 200.ms)
             .shimmer(delay: 800.ms, duration: 1500.ms),

            const SizedBox(height: 24),

            // Animated Text
            const Text(
              "CarGoRent",
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),

            const SizedBox(height: 8),

            const Text(
              "INDIA'S PREMIUM RENTAL",
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.w400,
                letterSpacing: 4.0,
              ),
            ).animate().fadeIn(delay: 600.ms),

            const SizedBox(height: 80),

            // Loading Indicator
            const SizedBox(
              width: 40,
              child: LinearProgressIndicator(
                backgroundColor: Colors.white10,
                color: Color(0xFFFFD700), // Using your Accent Gold
              ),
            ).animate().fadeIn(delay: 800.ms),
          ],
        ),
      ),
    );
  }
}