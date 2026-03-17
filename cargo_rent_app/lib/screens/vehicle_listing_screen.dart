import 'package:flutter/material.dart';
import 'package:cargo_rent_app/services/api_service.dart';
import 'package:cargo_rent_app/models/car_model.dart';

class VehicleListingScreen extends StatefulWidget {
  const VehicleListingScreen({super.key});

  @override
  State<VehicleListingScreen> createState() => _VehicleListingScreenState();
}

class _VehicleListingScreenState extends State<VehicleListingScreen> {
  final ApiService _apiService = ApiService();
  List<Car> _cars = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCars();
  }

  Future<void> _fetchCars() async {
    try {
      final cars = await _apiService.fetchCars();
      if (mounted) {
        setState(() {
          _cars = cars;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("AVAILABLE VEHICLES", 
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cars.isEmpty 
            ? const Center(child: Text("No vehicles available right now."))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _cars.length,
                itemBuilder: (context, index) => _buildVehicleCard(_cars[index]),
              ),
    );
  }

  Widget _buildVehicleCard(Car car) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            child: Image.network(
              car.imageUrl, 
              height: 200, 
              width: double.infinity, 
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 200,
                color: Colors.grey.shade200,
                child: const Icon(Icons.directions_car, size: 50, color: Colors.grey),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(car.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(car.type, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "₹${car.pricePerDay}/day", 
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0052CC))
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // REDIRECT TO LOGIN
                          Navigator.pushNamed(context, '/login');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD700), 
                          foregroundColor: Colors.black, 
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        child: const Text("BOOK NOW", 
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}