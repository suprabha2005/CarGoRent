import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/api_service.dart';
import '../models/car_model.dart';

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
      setState(() {
        _availableCars = cars;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // 1. HERO SECTION
          SliverToBoxAdapter(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 450,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage('https://images.unsplash.com/photo-1503376780353-7e6692767b70?q=80&w=2070'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("CarGoRent", 
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold))
                            .animate().fadeIn(duration: 600.ms).slideX(),
                        const SizedBox(height: 40),
                        // REPLACED typewriter with fadeIn + shimmer effect
                        const Text("Reliable car rentals\nacross India.",
                          style: TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold, height: 1.1))
                            .animate()
                            .fadeIn(duration: 800.ms)
                            .slideY(begin: 0.3, end: 0)
                            .shimmer(delay: 1000.ms, duration: 1500.ms),
                      ],
                    ),
                  ),
                ),
                // SEARCH BOX
                Positioned(
                  bottom: -80,
                  left: 20,
                  right: 20,
                  child: _buildSearchBox()
                    .animate()
                    .fadeIn(delay: 400.ms)
                    .moveY(begin: 50, end: 0),
                ),
              ],
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 120)),

          // 2. FLEET SECTION
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Popular in our fleet", 
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)))
                    .animate().fadeIn().slideX(),
                  const SizedBox(height: 16),
                  _buildFilterChips(),
                ],
              ),
            ),
          ),

          _isLoading 
            ? const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(50), child: CircularProgressIndicator())))
            : SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildCarCard(_availableCars[index])
                        .animate()
                        .fadeIn(delay: (index * 100).ms)
                        .scale(begin: const Offset(0.9, 0.9)),
                    childCount: _availableCars.length,
                  ),
                ),
              ),

          // 3. REASONS TO RENT SECTION
          SliverToBoxAdapter(
            child: Container(
              color: const Color(0xFF0052CC), 
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
              child: Column(
                children: [
                  const Text("Reasons\nTo rent a vehicle from CarGoRent",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 40),
                  _buildReasonItem("1", "Wide Selection", "Choose from a diverse range of reliable vehicles."),
                  _buildReasonItem("2", "Great Rates", "Enjoy consistently competitive pricing with no hidden costs."),
                  _buildReasonItem("3", "Secure Booking", "Book online with confidence, paying through our safe system."),
                ],
              ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2, end: 0),
            ),
          ),

          // 4. BOOK TODAY CTA SECTION
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(40),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?q=80&w=1966'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                children: [
                  const Text("Book your rental today", 
                    style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 30),
                  Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildContactIcon(Icons.search, "BOOK ONLINE"),
                      _buildContactIcon(Icons.phone, "CALL US"),
                      _buildContactIcon(Icons.email, "EMAIL US"),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 5. FOOTER SECTION
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("CARGORENT", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            const SizedBox(height: 10),
                            Text("Making renting easy in India. Book online or visit our branches.", 
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text("STAY UPDATED", style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: 200,
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: "Email Address",
                                  hintStyle: const TextStyle(fontSize: 12),
                                  suffixIcon: const Icon(Icons.send, color: Colors.blue, size: 20),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 60),
                  const Text("© 2026 CARGORENT INDIA", style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- BUILDER METHODS ---

  Widget _buildSearchBox() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
      ),
      child: Column(
        children: [
          _buildInput("Pickup Location", _pickupLocationController, Icons.location_on),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildDateTile("Pickup Date", _pickupDate),
              const SizedBox(width: 12),
              _buildDateTile("Drop-off Date", _dropoffDate),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {}, 
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("SEARCH VEHICLES", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonItem(String num, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Row(
        children: [
          Text(num, style: const TextStyle(color: Colors.amber, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text(desc, style: const TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactIcon(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(backgroundColor: Colors.white24, child: Icon(icon, color: Colors.white)),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildCarCard(Car car) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.network(car.imageUrl, height: 180, width: double.infinity, fit: BoxFit.cover),
          ),
          ListTile(
            title: Text("${car.brand} ${car.name}", style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(car.type),
            trailing: Text("₹${car.pricePerDay}/day", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(String hint, TextEditingController ctrl, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(hintText: hint, icon: Icon(icon, size: 18), border: InputBorder.none),
      ),
    );
  }

  Widget _buildDateTile(String label, DateTime? date) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            Text(date == null ? "Select Date" : DateFormat('dd MMM').format(date), 
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
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
                setState(() { _selectedFilter = type; _fetchFleet(); });
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}