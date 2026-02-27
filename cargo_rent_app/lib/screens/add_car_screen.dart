import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddCarScreen extends StatefulWidget {
  const AddCarScreen({super.key});

  @override
  State<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  
  final _brandController = TextEditingController();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedType = "Sedan";
  bool _isSubmitting = false;

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final userId = await _apiService.getUserId();
    
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Session expired. Please login again."))
      );
      setState(() => _isSubmitting = false);
      return;
    }

    // Prepare data to match your Mongoose Schema exactly
    final carData = {
      "brand": _brandController.text.trim(),
      "name": _nameController.text.trim(),
      "pricePerDay": double.parse(_priceController.text.trim()),
      "type": _selectedType,
      "imageUrl": _imageUrlController.text.trim(),
      "description": _descriptionController.text.trim().isEmpty 
          ? "A premium ${_brandController.text} ${_nameController.text} available for rent." 
          : _descriptionController.text.trim(),
      "vendorId": userId, // MATCHES Car.js SCHEMA
      "isAvailable": true,
    };

    final success = await _apiService.addCar(carData);

    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Car listed successfully!"), backgroundColor: Colors.green)
      );
      Navigator.pop(context, true); // Return true to trigger refresh
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to add car. Check Node.js console for errors."), backgroundColor: Colors.red)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("List a New Car"),
        backgroundColor: Colors.indigo[900],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: "Public Image URL",
                  hintText: "https://images.unsplash.com/...",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link),
                ),
                validator: (v) => v!.isEmpty ? "Please paste a web image link" : null,
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _brandController,
                      decoration: const InputDecoration(labelText: "Brand", border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: "Model", border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: "Price/Day (\$)", border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: "Category", border: OutlineInputBorder()),
                items: ["Sedan", "SUV", "Luxury", "Electric"].map((t) => 
                  DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setState(() => _selectedType = v!),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: "Description", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo[900], foregroundColor: Colors.white),
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text("CONFIRM LISTING"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}