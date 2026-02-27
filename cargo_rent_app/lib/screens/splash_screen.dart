import 'package:flutter/material.dart';
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
    // Small delay for branding
    await Future.delayed(const Duration(seconds: 3));

    String? token = await _apiService.getToken();
    String? role = await _apiService.getRole();

    if (!mounted) return;

    if (token != null && role != null) {
      // Redirect based on role stored in SecureStorage
      if (role == 'admin') {
        Navigator.pushReplacementNamed(context, '/admin_dashboard');
      } else if (role == 'vendor') {
        Navigator.pushReplacementNamed(context, '/vendor_dashboard');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      // No token found, go to login
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF1A237E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_car_filled, size: 100, color: Colors.white),
            SizedBox(height: 20),
            Text(
              "CarGoRent",
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 10),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}