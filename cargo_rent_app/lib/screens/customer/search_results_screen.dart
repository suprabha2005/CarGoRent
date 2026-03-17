import 'package:flutter/material.dart';
import '../../../models/car_model.dart';
import '../../../services/api_service.dart';

class SearchResultsScreen extends StatefulWidget {
  final String location;
  const SearchResultsScreen({super.key, required this.location});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final ApiService _apiService = ApiService();
  
  // Filter States
  double _maxPrice = 15000;
  String _selectedType = "All";
  List<Car> _allCars = [];
  List<Car> _filteredCars = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Fetching based on location from the API
      final results = await _apiService.fetchCars(search: widget.location);
      setState(() {
        _allCars = results;
        _filteredCars = results;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading search results: $e");
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredCars = _allCars.where((car) {
        bool matchesPrice = car.pricePerDay <= _maxPrice;
        bool matchesType = _selectedType == "All" || car.type == _selectedType;
        return matchesPrice && matchesType;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF0F172A),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Available Rentals", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(widget.location, style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
          ],
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.tune_rounded),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      // --- FILTER DRAWER ---
      endDrawer: Drawer(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Filters", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                  ],
                ),
                const SizedBox(height: 30),
                const Text("Price Range (per day)", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("₹500", style: TextStyle(color: Colors.grey)),
                    Text("Up to ₹${_maxPrice.toInt()}", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  ],
                ),
                Slider(
                  value: _maxPrice,
                  min: 500,
                  max: 15000,
                  divisions: 29,
                  activeColor: const Color(0xFF0F172A),
                  inactiveColor: const Color(0xFFE2E8F0),
                  onChanged: (val) {
                    setState(() => _maxPrice = val);
                    _applyFilters();
                  },
                ),
                const SizedBox(height: 30),
                const Text("Vehicle Type", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ["All", "SUV", "Sedan", "Hatchback", "Luxury"].map((type) {
                    return ChoiceChip(
                      label: Text(type),
                      selected: _selectedType == type,
                      selectedColor: const Color(0xFF0F172A),
                      labelStyle: TextStyle(
                        color: _selectedType == type ? Colors.white : const Color(0xFF0F172A),
                      ),
                      onSelected: (val) {
                        setState(() => _selectedType = type);
                        _applyFilters();
                      },
                    );
                  }).toList(),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Apply Filters", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F172A)))
          : _filteredCars.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredCars.length,
                  itemBuilder: (context, index) => _buildCarResultCard(_filteredCars[index]),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.car_rental_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("No cars match your filters", style: TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              setState(() {
                _maxPrice = 15000;
                _selectedType = "All";
                _filteredCars = _allCars;
              });
            },
            child: const Text("Reset all filters", style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildCarResultCard(Car car) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  car.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => Container(
                    height: 200, 
                    color: Colors.grey[200], 
                    child: const Icon(Icons.image_not_supported, color: Colors.grey)
                  ),
                ),
              ),
              // FIXED: Positioned widget instead of Position
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9), 
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
                  ),
                  child: Text(
                    car.type, 
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${car.brand} ${car.name}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          const Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 14),
                              SizedBox(width: 4),
                              Text("4.8 (120+ trips)", style: TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("₹${car.pricePerDay.toInt()}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                        const Text("/day", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _specIcon(Icons.settings_outlined, "Manual"),
                    _specIcon(Icons.local_gas_station_outlined, "Petrol"),
                    _specIcon(Icons.person_outline, "5 Seats"),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F172A),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          // Navigate to Booking Screen
                        },
                        child: const Text("Book Now"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _specIcon(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF64748B)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
        const SizedBox(width: 12),
      ],
    );
  }
}