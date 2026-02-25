import 'package:flutter/material.dart';
import '../models/car_model.dart';
import '../services/api_service.dart';
import 'add_car_screen.dart';
import 'car_details_screen.dart'; // Make sure to create this file next!

class HomeScreen extends StatefulWidget {
  final String role;
  const HomeScreen({super.key, required this.role});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _carsFuture;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carsFuture = _apiService.fetchCars();
  }

  void _refreshCars() {
    setState(() {
      _carsFuture = _apiService.fetchCars();
    });
  }

  void _handleLogout(BuildContext context) async {
    await _apiService.logout();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        title: const Text("CarGoRent", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      floatingActionButton: widget.role == 'vendor'
          ? FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddCarScreen()),
                );
                _refreshCars();
              },
              label: const Text("Add Car"),
              icon: const Icon(Icons.add),
              backgroundColor: Colors.orange.shade800,
            )
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PROFESSIONAL SEARCH HEADER (Inspired by the website)
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
            decoration: const BoxDecoration(
              color: Color(0xFF1A237E),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Search your dream car...",
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF1A237E)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Text(
              "Available Vehicles",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF263238)),
            ),
          ),

          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _carsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No cars available right now."));
                }

                final cars = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: cars.length,
                  itemBuilder: (context, index) {
                    final carData = cars[index];
                    final car = Car(
                      id: carData['_id'],
                      name: carData['name'],
                      brand: carData['brand'],
                      pricePerDay: (carData['pricePerDay'] as num).toDouble(),
                      imageUrl: carData['imageUrl'],
                      type: carData['type'],
                    );

                    // WRAPPED IN GESTURE DETECTOR FOR NAVIGATION
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CarDetailsScreen(car: car),
                          ),
                        );
                      },
                      child: _buildCarCard(car),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarCard(Car car) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  car.imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 180,
                    color: Colors.grey[200],
                    child: const Icon(Icons.directions_car, size: 50, color: Colors.grey),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade800,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    car.type,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${car.brand} ${car.name}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Row(
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.amber),
                        Text(" 4.8 (24 reviews)", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "\$${car.pricePerDay.toInt()}",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
                    ),
                    const Text("/ day", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}