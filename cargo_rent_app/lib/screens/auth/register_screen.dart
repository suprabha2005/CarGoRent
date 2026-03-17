import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/api_service.dart'; 

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _adminCodeController = TextEditingController();
  String _selectedRole = "customer";
  final _apiService = ApiService();
  bool _isLoading = false;

  final Color primaryDark = const Color(0xFF0F172A);
  final Color accentGold = const Color(0xFFFFD700);

  void _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnackBar("Please fill in all fields");
      return;
    }

    if (_selectedRole == 'admin' && _adminCodeController.text.isEmpty) {
      _showSnackBar("Admin code is required for this role");
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final success = await _apiService.register(
        name: name,
        email: email,
        password: password,
        role: _selectedRole,
        adminCode: _selectedRole == 'admin' ? _adminCodeController.text.trim() : null,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (success) {
        _showSnackBar("Success! Please login to continue.", isError: false);
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) Navigator.pushReplacementNamed(context, '/login');
        });
      } else {
        // This is where we catch the "False" return from API
        _showSnackBar("Registration Failed: Email might already be in use.");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar("An error occurred: ${e.toString().split(':').last}");
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryDark),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Join\nCarGoRent",
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, height: 1.1, color: Color(0xFF0F172A)),
            ).animate().fadeIn().slideX(begin: -0.2),
            
            const SizedBox(height: 10),
            const Text("India's premium car rental community.", style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 35),
            
            _buildField(_nameController, "Full Name", Icons.person_outline),
            const SizedBox(height: 15),
            _buildField(_emailController, "Email Address", Icons.email_outlined),
            const SizedBox(height: 15),
            _buildField(_passwordController, "Password", Icons.lock_outline, obscure: true),
            
            const SizedBox(height: 30),
            const Text("Register as:", style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1E293B), fontSize: 13)),
            const SizedBox(height: 12),
            Row(
              children: [
                _roleChip("customer", "User"),
                const SizedBox(width: 8),
                _roleChip("vendor", "Vendor"),
                const SizedBox(width: 8),
                _roleChip("admin", "Admin"),
              ],
            ),
            
            if (_selectedRole == 'admin') ...[
              const SizedBox(height: 15),
              _buildField(_adminCodeController, "Admin Access Code", Icons.verified_user_outlined).animate().fadeIn().slideY(begin: 0.1),
            ],
            
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: _isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                  : const Text("CREATE ACCOUNT", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.1)),
              ),
            ),
            
            const SizedBox(height: 25),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text.rich(
                  TextSpan(
                    text: "Already have an account? ",
                    style: const TextStyle(color: Colors.grey),
                    children: [
                      TextSpan(text: "Login", style: TextStyle(color: primaryDark, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _roleChip(String value, String label) {
    bool isSelected = _selectedRole == value;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedRole = value),
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? primaryDark : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
            border: isSelected ? null : Border.all(color: Colors.grey.shade300),
          ),
          child: Center(
            child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String hint, IconData icon, {bool obscure = false}) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        cursorColor: primaryDark,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          prefixIcon: Icon(icon, color: Colors.grey, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
        ),
      ),
    );
  }
}