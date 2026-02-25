import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddCarScreen extends StatefulWidget {
  const AddCarScreen({super.key});

  @override
  State<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageController = TextEditingController();
  final _typeController = TextEditingController();
  
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  void _submitData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final carData = {
      "name": _nameController.text.trim(),
      "brand": _brandController.text.trim(),
      "pricePerDay": double.parse(_priceController.text.trim()),
      "imageUrl": _imageController.text.trim(),
      "type": _typeController.text.trim(),
    };

    try {
      final success = await _apiService.addCar(carData);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Car Added Successfully!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Return to Home
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Vehicle"),
        backgroundColor: Colors.orange.shade800,
        foregroundColor: Colors.white,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(_nameController, "Car Name", Icons.directions_car),
                  _buildTextField(_brandController, "Brand", Icons.branding_watermark),
                  _buildTextField(_priceController, "Price per Day (\$)", Icons.attach_money, isNumber: true),
                  _buildTextField(_typeController, "Type (SUV, Sedan, etc.)", Icons.category),
                  _buildTextField(_imageController, "Image URL", Icons.image),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _submitData,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade800),
                      child: const Text("LIST VEHICLE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        validator: (value) => value!.isEmpty ? "Required field" : null,
      ),
    );
  }
}