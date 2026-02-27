import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/car_model.dart';
import 'search_results_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _pickupLocationController = TextEditingController();
  final TextEditingController _dropoffLocationController = TextEditingController();
  
  DateTime? _pickupDate;
  DateTime? _dropoffDate;
  
  List<Car> _availableCars = [];
  bool _isLoading = true;
  String _selectedFilter = "All";

  @override
  void initState() {
    super.initState();
    _fetchFleet();
  }

  Future<void> _fetchFleet() async {
    setState(() => _isLoading = true);
    try {
      final List<Car> cars = await _apiService.fetchCars(
        type: _selectedFilter == "All" ? null : _selectedFilter
      );
      debugPrint("Fetched ${cars.length} cars from API"); // DEBUG LOG
      setState(() {
        _availableCars = cars;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching fleet: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context, bool isPickup) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isPickup) _pickupDate = picked; else _dropoffDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Hero & Search Header
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Hero Image Section
                Container(
                  height: 350,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage('https://images.unsplash.com/photo-1503376780353-7e6692767b70?q=80&w=2070'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    color: Colors.black.withOpacity(0.4),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("CarGoRent", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(height: 30),
                        Text("Reliable car rentals\nacross India.", 
                            style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, height: 1.2)),
                      ],
                    ),
                  ),
                ),

                // Search Box
                Transform.translate(
                  offset: const Offset(0, -60),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
                    ),
                    child: Column(
                      children: [
                        _buildLocationInput("Pickup Location", _pickupLocationController, Icons.location_on_outlined),
                        const SizedBox(height: 12),
                        _buildLocationInput("Drop-off Location", _dropoffLocationController, Icons.location_searching),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildDateTile("Pickup Date", _pickupDate, () => _selectDate(context, true)),
                            const SizedBox(width: 12),
                            _buildDateTile("Drop-off Date", _dropoffDate, () => _selectDate(context, false)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_pickupLocationController.text.trim().isNotEmpty) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SearchResultsScreen(location: _pickupLocationController.text),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Please enter a pickup location")),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F172A),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                            child: const Text("SEARCH VEHICLES", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Fleet Title & Chips
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Popular in our fleet", 
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  const SizedBox(height: 16),
                  _buildFilterChips(),
                ],
              ),
            ),
          ),

          // Fleet List (The actual cars)
          _isLoading 
            ? const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()))
            : _availableCars.isEmpty 
              ? const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(40), child: Text("No cars found matching your filter"))))
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildCarCard(_availableCars[index]),
                      childCount: _availableCars.length,
                    ),
                  ),
                ),
                
          const SliverToBoxAdapter(child: SizedBox(height: 40)), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ["All", "SUV", "Sedan", "Hatchback", "Luxury"].map((type) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(type),
              selected: _selectedFilter == type,
              onSelected: (val) {
                setState(() {
                  _selectedFilter = type;
                  _fetchFleet();
                });
              },
              selectedColor: const Color(0xFF0F172A),
              labelStyle: TextStyle(color: _selectedFilter == type ? Colors.white : Colors.black),
              backgroundColor: Colors.grey.shade100,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCarCard(Car car) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              car.imageUrl, 
              height: 200, 
              width: double.infinity, 
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(height: 200, color: Colors.grey[100], child: const Icon(Icons.car_rental, size: 50)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${car.brand} ${car.name}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 4),
                    Text(car.type, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                  ],
                ),
                Text("₹${car.pricePerDay.toInt()}/day", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInput(String hint, TextEditingController controller, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 14),
          border: InputBorder.none,
          icon: Icon(icon, color: Colors.blueGrey, size: 20),
        ),
      ),
    );
  }

  Widget _buildDateTile(String label, DateTime? date, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              const SizedBox(height: 4),
              Text(date == null ? "Select Date" : DateFormat('dd MMM').format(date),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}