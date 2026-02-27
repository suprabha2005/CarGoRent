import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'vendor_verification_screen.dart';

class LoginScreen extends StatefulWidget {
  final String? role; 
  const LoginScreen({super.key, this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiService = ApiService();
  bool _isLoading = false;

  void _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter email and password")),
      );
      return;
    }

    setState(() => _isLoading = true);
    final result = await _apiService.login(
      _emailController.text.trim(), 
      _passwordController.text.trim()
    );
    setState(() => _isLoading = false);

    if (result != null) {
      String role = result['user']['role'];
      String status = result['user']['verificationStatus'] ?? 'approved';

      if (role == 'admin') {
        Navigator.pushReplacementNamed(context, '/admin_dashboard');
      } 
      else if (role == 'vendor') {
        if (status == 'unverified') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const VendorVerificationScreen()),
          );
        } else if (status == 'pending') {
          _showPendingDialog();
        } else {
          Navigator.pushReplacementNamed(context, '/vendor_dashboard');
        }
      } 
      else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid Credentials")),
      );
    }
  }

  void _showPendingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Account Pending"),
        content: const Text("Admin is reviewing your docs. Please wait for approval."),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 100),
              const Text("Welcome\nBack", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, height: 1.2, color: Color(0xFF1A1A1A))),
              const SizedBox(height: 10),
              Text("Sign in to your account", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
              const SizedBox(height: 50),
              
              _buildTextField(_emailController, "Email", Icons.email_outlined, false),
              const SizedBox(height: 20),
              _buildTextField(_passwordController, "Password", Icons.lock_outline, true),
              
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D31FA),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text("LOGIN", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? ", style: TextStyle(color: Colors.grey)),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/register'),
                    child: const Text("Register Here", style: TextStyle(color: Color(0xFF2D31FA), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, bool obscure) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFF5F6F9), borderRadius: BorderRadius.circular(15)),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}