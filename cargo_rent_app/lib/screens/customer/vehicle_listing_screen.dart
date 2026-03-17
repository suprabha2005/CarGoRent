import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../services/api_service.dart';
import '../../../models/car_model.dart';

class VehicleListingScreen extends StatefulWidget {
  const VehicleListingScreen({super.key});

  @override
  State<VehicleListingScreen> createState() => _VehicleListingScreenState();
}

class _VehicleListingScreenState extends State<VehicleListingScreen> {
  final ApiService _apiService = ApiService();
  List<Car> _cars = [];
  List<Car> _filteredCars = [];
  bool _isLoading = true;
  String _selectedFilter = "All";

  // Brand Colors
  final Color primaryBlue = const Color(0xFF0052CC);
  final Color accentGold = const Color(0xFFFFD700);
  final Color navyDark = const Color(0xFF0F172A);

  final List<String> _filters = ["All", "Sedan", "SUV", "Luxury", "Electric"];

  // Search box controllers
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _dropoffController = TextEditingController();
  DateTime? _pickupDate;
  DateTime? _dropoffDate;

  @override
  void initState() {
    super.initState();
    _fetchCars();
  }

  Future<void> _fetchCars({String? type}) async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final cars = await _apiService.fetchCars(
        type: (type == null || type == "All") ? null : type,
      );
      if (mounted) {
        setState(() {
          _cars = cars;
          _filteredCars = cars;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        debugPrint("Error fetching cars: $e");
      }
    }
  }

  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      if (filter == "All") {
        _filteredCars = _cars;
      } else {
        _filteredCars = _cars
            .where((c) => c.type.toLowerCase() == filter.toLowerCase())
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: () => _fetchCars(type: _selectedFilter),
        child: CustomScrollView(
          slivers: [
            // ── Hero Banner ───────────────────────────────────────────
            SliverToBoxAdapter(
              child: Stack(
                children: [
                  // Background image
                  Container(
                    height: 260,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                            'https://images.unsplash.com/photo-1541899481282-d53bffe3c35d?w=2070'),
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.black.withOpacity(0.65),
                            Colors.black.withOpacity(0.2),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Back button
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 8,
                    left: 12,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ).animate().fadeIn(delay: 200.ms),
                  ),

                  // Hero text
                  Positioned(
                    bottom: 36,
                    left: 28,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: accentGold.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border:
                                Border.all(color: accentGold.withOpacity(0.5)),
                          ),
                          child: Text("CARGORENT INDIA",
                              style: TextStyle(
                                  color: accentGold,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2)),
                        ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.2),
                        const SizedBox(height: 10),
                        const Text("Our Vehicles",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 38,
                                    fontWeight: FontWeight.w900,
                                    height: 1.1))
                            .animate()
                            .fadeIn(delay: 450.ms, duration: 600.ms)
                            .slideX(begin: -0.3, curve: Curves.easeOut),
                        const SizedBox(height: 6),
                        Text(
                          "${_cars.length} vehicles available",
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13),
                        ).animate().fadeIn(delay: 600.ms),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Search Box ───────────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _pickupController,
                      decoration: InputDecoration(
                        hintText: "Pick-up Location",
                        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                        prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _dropoffController,
                      decoration: InputDecoration(
                        hintText: "Drop-off Location",
                        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                        prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildDateTile("Pickup Date", _pickupDate,
                            (d) => setState(() => _pickupDate = d)),
                        const SizedBox(width: 10),
                        _buildDateTile("Drop-off Date", _dropoffDate,
                            (d) => setState(() => _dropoffDate = d)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => _fetchCars(type: _selectedFilter),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: navyDark,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text("SEARCH VEHICLES",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                letterSpacing: 0.8)),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 700.ms, duration: 500.ms).slideY(begin: 0.2),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            // ── Filter Chips ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filters.asMap().entries.map((e) {
                      final isSelected = _selectedFilter == e.value;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => _applyFilter(e.value),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 9),
                            decoration: BoxDecoration(
                              color: isSelected ? navyDark : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? navyDark
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Text(
                              e.value,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black54,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(
                              delay: Duration(milliseconds: 80 * e.key),
                              duration: 300.ms)
                          .slideY(begin: 0.2, curve: Curves.easeOut);
                    }).toList(),
                  ),
                ),
              ),
            ),

            // ── Results Count Bar ─────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isLoading
                          ? "Loading..."
                          : "${_filteredCars.length} ${_selectedFilter == 'All' ? 'vehicles' : _selectedFilter + 's'} found",
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: Color(0xFF1E293B)),
                    ),
                    Icon(Icons.tune_rounded,
                        size: 20, color: Colors.grey.shade500),
                  ],
                ),
              ),
            ),

            // ── Car List ──────────────────────────────────────────────
            _isLoading
                ? const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 60),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  )
                : _filteredCars.isEmpty
                    ? SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 60),
                            child: Column(
                              children: [
                                Icon(Icons.directions_car_outlined,
                                    size: 60, color: Colors.grey.shade300),
                                const SizedBox(height: 16),
                                Text(
                                  "No $_selectedFilter vehicles available.",
                                  style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) =>
                                _buildVehicleCard(_filteredCars[index], index),
                            childCount: _filteredCars.length,
                          ),
                        ),
                      ),

            // ── Footer ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                color: const Color(0xFF0F172A),
                padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                child: Column(
                  children: [
                    // Top row — logo + tagline
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("CarGoRent",
                                style: TextStyle(
                                    color: accentGold,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5)),
                            const SizedBox(height: 6),
                            const Text("India's trusted car rental.",
                                style: TextStyle(
                                    color: Colors.white54, fontSize: 12)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: accentGold,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/register'),
                            child: const Text("REGISTER NOW",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 11)),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                    const Divider(color: Colors.white12),
                    const SizedBox(height: 28),

                    // Links row
                    Wrap(
                      spacing: 32,
                      runSpacing: 20,
                      alignment: WrapAlignment.center,
                      children: [
                        _footerColumn("NAVIGATE",
                            ["Home", "Vehicles", "Branches", "FAQ"]),
                        _footerColumn("INFORMATION",
                            ["Terms", "Privacy Policy", "Refunds"]),
                        _footerColumn("CONTACT",
                            ["Airport Transfers", "+91 98765 43210", "support@cargorent.in"]),
                      ],
                    ),

                    const SizedBox(height: 36),
                    const Divider(color: Colors.white12),
                    const SizedBox(height: 20),

                    // Contact bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _footerContactChip(Icons.search, "BOOK ONLINE"),
                        _footerContactChip(Icons.phone_outlined, "+91 98765 43210"),
                        _footerContactChip(Icons.email_outlined, "support@cargorent.in"),
                      ],
                    ),

                    const SizedBox(height: 28),
                    const Text("© 2026 CARGORENT INDIA · All rights reserved.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white24, fontSize: 11)),
                  ],
                ),
              ).animate().fadeIn(duration: 500.ms),
            ),
          ],
        ),
      ),
    );
  }

  Widget _footerColumn(String title, List<String> items) {
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 0.8)),
          const SizedBox(height: 14),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(item,
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 12)),
              )),
        ],
      ),
    );
  }

  Widget _footerContactChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: accentGold, size: 16),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(
                color: Colors.white60,
                fontSize: 11,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildDateTile(String label, DateTime? date, Function(DateTime) onPick) {
    return Expanded(
      child: InkWell(
        onTap: () async {
          final d = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (d != null) onPick(d);
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              const SizedBox(height: 2),
              Text(
                date == null
                    ? "Select"
                    : "${date.day} ${['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][date.month - 1]}",
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleCard(Car car, int index) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/login'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left — Info
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Type badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: navyDark,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            car.type.toUpperCase(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(car.name,
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A))),
                        const SizedBox(height: 4),
                        Text("Self Drive · AC · ${car.type}",
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey.shade500)),
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("₹${car.pricePerDay}",
                                style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: primaryBlue)),
                            const Padding(
                              padding: EdgeInsets.only(bottom: 2, left: 3),
                              child: Text("/day",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 9),
                          decoration: BoxDecoration(
                            color: navyDark,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text("RENT NOW →",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8)),
                        ),
                      ],
                    ),
                  ),
                ),
                // Right — Car Image
                Expanded(
                  flex: 4,
                  child: Container(
                    color: const Color(0xFFF0F4FF),
                    padding: const EdgeInsets.all(12),
                    child: Image.network(
                      car.imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(Icons.directions_car,
                          size: 70, color: Colors.grey.shade400),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
            delay: Duration(milliseconds: 100 + index * 120), duration: 500.ms)
        .slideY(begin: 0.25, curve: Curves.easeOut);
  }
}