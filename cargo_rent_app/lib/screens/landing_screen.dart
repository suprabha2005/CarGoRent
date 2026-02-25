import 'package:flutter/material.dart';
import 'login_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  String? selectedRole; // Memory for 'customer', 'vendor', or 'admin'

  void _navigateToLogin() {
    if (selectedRole != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(role: selectedRole!), // Pass role forward
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a role first!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1503376780353-7e6692767b70'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Dark Overlay
          Container(color: Colors.black.withOpacity(0.5)),
          // UI Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("CarGoRent", style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
                const SizedBox(height: 50),
                _roleButton("Customer", 'customer', Icons.person),
                _roleButton("Vendor", 'vendor', Icons.storefront),
                _roleButton("Admin", 'admin', Icons.admin_panel_settings),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _navigateToLogin,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15)),
                  child: const Text("Continue"),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _roleButton(String title, String roleKey, IconData icon) {
    bool isSelected = selectedRole == roleKey;
    return GestureDetector(
      onTap: () => setState(() => selectedRole = roleKey),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(15),
        width: 250,
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 20),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
      ),
    );
  }
}