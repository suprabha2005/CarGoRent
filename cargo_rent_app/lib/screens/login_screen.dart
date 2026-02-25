import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'register_screen.dart';
import 'home_screen.dart'; 

class LoginScreen extends StatefulWidget {
  final String role;
  const LoginScreen({super.key, required this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  Color get _roleColor => widget.role == 'admin' ? Colors.red.shade800 : 
                          widget.role == 'vendor' ? Colors.orange.shade800 : 
                          const Color(0xFF1A237E);

  void _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      // UPDATED: Only passing email and password as per our new ApiService
      final responseData = await _apiService.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;

      // UPDATED: ApiService returns Map if successful, null if failed
      if (responseData != null) {
        String userRole = responseData['user']['role'];

        // Security Check: Ensure the user is logging into the correct portal
        if (userRole != widget.role) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Access Denied: You are registered as a $userRole'),
              backgroundColor: Colors.red,
            ),
          );
          await _apiService.logout(); // Clear the mismatched token
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login Successful!'), backgroundColor: Colors.green)
        );

        await Future.delayed(const Duration(milliseconds: 500));

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(role: userRole),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid credentials for ${widget.role}'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.role.toUpperCase()} Login"), 
        backgroundColor: _roleColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 80, color: _roleColor),
            const SizedBox(height: 30),
            TextField(
              controller: _emailController, 
              decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder())
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _passwordController, 
              decoration: const InputDecoration(labelText: "Password", border: OutlineInputBorder()), 
              obscureText: true
            ),
            const SizedBox(height: 30),
            _isLoading 
              ? const CircularProgressIndicator() 
              : SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _handleLogin, 
                    style: ElevatedButton.styleFrom(backgroundColor: _roleColor),
                    child: const Text("LOGIN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterScreen(role: widget.role)),
                );
              },
              child: Text(
                "New ${widget.role}? Create account",
                style: TextStyle(color: _roleColor, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}