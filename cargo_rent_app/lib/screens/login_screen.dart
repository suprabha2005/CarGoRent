import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cargo_rent_app/services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService(); 
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final Color primaryBlue = const Color(0xFF0052CC);

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        final success = await _apiService.login(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        
        if (!mounted) return;
        setState(() => _isLoading = false);

        if (success) {
          // Navigating using the route name defined in main.dart
          Navigator.pushReplacementNamed(context, '/landing');
        } else {
          _showSnackBar("Invalid email or password.");
        }
      } catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        _showSnackBar("Connection error. Is your server running?");
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Welcome Back",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
                ).animate().fadeIn().slideY(begin: 0.3),
                const SizedBox(height: 10),
                const Text(
                  "Login to manage your car rentals.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 40),
                
                _buildTextField(
                  controller: _emailController,
                  label: "Email Address",
                  hint: "example@mail.com",
                  icon: Icons.email_outlined,
                  validator: (value) => (value != null && value.contains('@')) ? null : "Enter a valid email",
                ),
                const SizedBox(height: 20),

                _buildTextField(
                  controller: _passwordController,
                  label: "Password",
                  hint: "••••••••",
                  icon: Icons.lock_outline,
                  isPassword: true,
                  obscureText: !_isPasswordVisible,
                  togglePassword: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  validator: (value) => (value != null && value.length < 6) ? "Password too short" : null,
                ),
                
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text("Forgot Password?", style: TextStyle(color: Colors.grey, fontSize: 13)),
                  ),
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("LOGIN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                
                const SizedBox(height: 30),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/register'),
                      child: Text(
                        "Register Now",
                        style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? togglePassword,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20),
            suffixIcon: isPassword 
              ? IconButton(
                  icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, size: 20),
                  onPressed: togglePassword,
                )
              : null,
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}