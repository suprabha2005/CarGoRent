import 'package:flutter/material.dart';
import '../../services/api_service.dart'; 

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final _apiService = ApiService();
  final _licenseController = TextEditingController();
  final _imageController = TextEditingController();
  bool _isLoading = false;

  void _submit() async {
    setState(() => _isLoading = true);
    // Updated method name to match ApiService
    bool success = await _apiService.submitVendorDocs(
      _licenseController.text,
      _imageController.text,
    );
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Verification submitted successfully!")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to submit verification.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Submit Verification")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _licenseController,
              decoration: const InputDecoration(labelText: "License Number"),
            ),
            TextField(
              controller: _imageController,
              decoration: const InputDecoration(labelText: "License Image URL"),
            ),
            const SizedBox(height: 20),
            _isLoading 
                ? const CircularProgressIndicator() 
                : ElevatedButton(onPressed: _submit, child: const Text("Submit")),
          ],
        ),
      ),
    );
  }
}