import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/api_service.dart';

class AddCarScreen extends StatefulWidget {
  const AddCarScreen({super.key});

  @override
  State<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageController = TextEditingController();
  final _descController = TextEditingController();

  String _selectedType = 'Sedan';
  bool _isLoading = false;

  final Color navy = const Color(0xFF0F172A);
  final Color gold = const Color(0xFFFFD700);
  final Color blue = const Color(0xFF0052CC);

  final List<String> _carTypes = [
    'Sedan', 'SUV', 'Luxury', 'Electric', 'Hatchback', 'MUV'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final userId = await _apiService.getUserId();

    final carData = {
      "name": _nameController.text.trim(),
      "brand": _brandController.text.trim(),
      "type": _selectedType,
      "pricePerDay": double.tryParse(_priceController.text.trim()) ?? 0,
      "imageUrl": _imageController.text.trim(),
      "description": _descController.text.trim(),
      "vendorId": userId,
      "isAvailable": true,
    };

    final success = await _apiService.addCar(carData);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("✅ Car listed successfully!"),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("❌ Failed to add car. Please try again."),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: navy,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            Icon(Icons.add_circle_outline, color: gold, size: 20),
            const SizedBox(width: 8),
            const Text("List New Car",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18)),
          ],
        ),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Header card ──────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [navy, blue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: gold.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: gold.withOpacity(0.4)),
                      ),
                      child: Icon(Icons.directions_car_outlined, color: gold, size: 24),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Add Your Vehicle",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15)),
                          SizedBox(height: 3),
                          Text("Fill in the details below to list your car for rental.",
                              style: TextStyle(color: Colors.white60, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2),

              const SizedBox(height: 28),

              // ── Section: Basic Info ──────────────────────────────
              _sectionLabel("Basic Information"),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      controller: _nameController,
                      label: "Car Model",
                      hint: "e.g. City, Creta",
                      icon: Icons.directions_car_outlined,
                      delay: 100,
                      validator: (v) => v == null || v.isEmpty ? "Required" : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildField(
                      controller: _brandController,
                      label: "Brand",
                      hint: "e.g. Honda, Hyundai",
                      icon: Icons.branding_watermark_outlined,
                      delay: 150,
                      validator: (v) => v == null || v.isEmpty ? "Required" : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Type selector
              _sectionLabel("Vehicle Type", delay: 200),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _carTypes.map((type) {
                  final selected = _selectedType == type;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedType = type),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 9),
                      decoration: BoxDecoration(
                        color: selected ? navy : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected ? navy : Colors.grey.shade300,
                        ),
                        boxShadow: selected
                            ? [BoxShadow(
                                color: navy.withOpacity(0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 2))]
                            : [],
                      ),
                      child: Text(type,
                          style: TextStyle(
                              color: selected ? Colors.white : Colors.black54,
                              fontWeight: FontWeight.w700,
                              fontSize: 13)),
                    ),
                  );
                }).toList(),
              ).animate().fadeIn(delay: 220.ms).slideY(begin: 0.2),

              const SizedBox(height: 20),

              // ── Section: Pricing ─────────────────────────────────
              _sectionLabel("Pricing", delay: 250),
              const SizedBox(height: 12),

              _buildField(
                controller: _priceController,
                label: "Price Per Day (₹)",
                hint: "e.g. 1500",
                icon: Icons.currency_rupee,
                delay: 280,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return "Required";
                  if (double.tryParse(v) == null) return "Enter a valid number";
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // ── Section: Image ───────────────────────────────────
              _sectionLabel("Car Image URL", delay: 300),
              const SizedBox(height: 4),
              Text("Paste a direct link to your car's image",
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12))
                  .animate().fadeIn(delay: 310.ms),
              const SizedBox(height: 10),
              _buildField(
                controller: _imageController,
                label: "Image URL",
                hint: "https://example.com/car.jpg",
                icon: Icons.image_outlined,
                delay: 320,
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),

              // Image preview
              if (_imageController.text.isNotEmpty) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 140,
                    width: double.infinity,
                    color: const Color(0xFFF0F4FF),
                    child: Image.network(
                      _imageController.text,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Text("Invalid image URL",
                            style: TextStyle(color: Colors.grey)),
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // ── Section: Description ─────────────────────────────
              _sectionLabel("Description (optional)", delay: 350),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Any features, condition, notes...",
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(14),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: blue, width: 1.5)),
                ),
              ).animate().fadeIn(delay: 370.ms).slideY(begin: 0.2),

              const SizedBox(height: 32),

              // ── Submit Button ────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: navy,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline,
                                color: gold, size: 20),
                            const SizedBox(width: 8),
                            const Text("LIST MY CAR",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
                                    letterSpacing: 0.5)),
                          ],
                        ),
                ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label, {int delay = 100}) {
    return Text(label,
        style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 14,
            color: navy))
        .animate()
        .fadeIn(delay: Duration(milliseconds: delay));
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required int delay,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        prefixIcon: Icon(icon, size: 20, color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: blue, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.redAccent)),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideY(begin: 0.15);
  }
}