import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cargo_rent_app/services/api_service.dart';
import 'package:cargo_rent_app/models/car_model.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _pickupLocationController = TextEditingController();
  final TextEditingController _dropoffLocationController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  final GlobalKey _fleetKey = GlobalKey();
  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey _footerKey = GlobalKey();

  DateTime? _pickupDate;
  DateTime? _dropoffDate;
  List<Car> _availableCars = [];
  bool _isLoading = true;
  String _selectedFilter = "All";

  // Brand Colors
  final Color primaryBlue = const Color(0xFF0052CC); 
  final Color accentGold = const Color(0xFFFFD700); 
  final Color navyDark = const Color(0xFF0F172A);

  @override
  void initState() {
    super.initState();
    _fetchFleet();
  }

  Future<void> _fetchFleet() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final List<Car> cars = await _apiService.fetchCars(
        type: _selectedFilter == "All" ? null : _selectedFilter
      );
      if (mounted) {
        setState(() {
          _availableCars = cars;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _goToLogin() => Navigator.pushNamed(context, '/login');
  void _goToRegister() => Navigator.pushNamed(context, '/register');
  void _goToVehicles() => Navigator.pushNamed(context, '/vehicles');

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(context, duration: 800.ms, curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _navItem("HOME", () => _scrollController.animateTo(0, duration: 800.ms, curve: Curves.easeInOut)),
              _navItem("VEHICLES", _goToVehicles),
              _navItem("ABOUT US", () => _scrollToSection(_aboutKey)),
              _navItem("CONTACT US", () => _scrollToSection(_footerKey)),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: TextButton.icon(
              onPressed: _goToLogin,
              icon: const Icon(Icons.person_outline, size: 18, color: Color(0xFF1E293B)),
              label: const Text("LOGIN / SIGN UP", 
                style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w900, fontSize: 12)),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Hero Section
          SliverToBoxAdapter(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 400,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage('https://images.unsplash.com/photo-1503376780353-7e6692767b70?q=80&w=2070'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft, 
                        end: Alignment.centerRight,
                        colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                      ),
                    ),
                    child: const Text("Reliable car rentals\nacross India.",
                      style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, height: 1.1))
                        .animate().fadeIn(duration: 800.ms).slideX(),
                  ),
                ),
                Positioned(
                  bottom: -110,
                  left: 20,
                  right: 20,
                  child: _buildSearchBox(),
                ),
              ],
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 150)),
          
          // Promotional Banner
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const NetworkImage('https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?q=80&w=2070'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
                ),
              ),
              child: Column(
                children: [
                  const Text("BOOK NOW. PAY LATER.", 
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                  const SizedBox(height: 40),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSideBannerCard("Unlimited\nKilometres.", "Explore with zero mileage worries."),
                        const SizedBox(width: 15),
                        _buildMainBannerCard(),
                        const SizedBox(width: 15),
                        _buildSideBannerCard("Vehicles For\nEvery Need.", "Automatic & AC equipped for your comfort."),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Fleet Section Header
          SliverToBoxAdapter(
            key: _fleetKey,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Popular in our fleet", 
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                      TextButton(
                        onPressed: _goToVehicles,
                        child: const Text("VIEW ALL →", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildFilterChips(),
                ],
              ),
            ),
          ),

          // Car List
          _isLoading 
            ? const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()))
            : _availableCars.isEmpty 
              ? const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(20), child: Text("No vehicles available for this filter."))))
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildCarCard(_availableCars[index]),
                      childCount: _availableCars.length > 3 ? 3 : _availableCars.length,
                    ),
                  ),
                ),

          // About Section
          SliverToBoxAdapter(
            key: _aboutKey,
            child: Container(
              color: primaryBlue,
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 30),
              child: Column(
                children: [
                  const Text("Reasons To rent a vehicle from CarGoRent",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 40),
                  _buildReasonItem("1", "Wide Selection", "Reliable luxury and budget vehicles."),
                  _buildReasonItem("2", "Great Rates", "Competitive pricing with zero hidden costs."),
                  _buildReasonItem("3", "Secure Booking", "Book with confidence through our safe system."),
                ],
              ),
            ),
          ),

          // Footer Section
          SliverToBoxAdapter(
            key: _footerKey,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 30),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildContactItem(Icons.search, "BOOK ONLINE", "GET STARTED", _goToVehicles),
                      _buildContactItem(Icons.phone, "RESERVATION", "+91 98765 43210", () {}),
                    ],
                  ),
                  const SizedBox(height: 60),
                  const Divider(),
                  const SizedBox(height: 40),
                  Wrap(
                    spacing: 40,
                    runSpacing: 30,
                    alignment: WrapAlignment.center,
                    children: [
                      _footerColumn("CARGORENT INDIA", ["Airport Transfers", "+91 98765 43210"]),
                      _footerColumn("NAVIGATE", ["Vehicles", "Branches", "FAQ"]),
                      _footerColumn("INFORMATION", ["Terms", "Privacy", "Refunds"]),
                      SizedBox(
                        width: 250,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("MANAGE BOOKINGS", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                            const SizedBox(height: 15),
                            const Text("New here? Register to manage your rental details.", 
                                style: TextStyle(fontSize: 12, color: Colors.black54)),
                            const SizedBox(height: 15),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _goToRegister,
                                style: ElevatedButton.styleFrom(backgroundColor: accentGold, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                                child: const Text("REGISTER NOW", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 11)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),
                  const Text("© 2026 CARGORENT INDIA", style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget Builders ---

  Widget _buildSearchBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
      ),
      child: Column(
        children: [
          _buildInput("Pick-up Location", _pickupLocationController, Icons.location_on_outlined),
          const SizedBox(height: 10),
          _buildInput("Drop-off Location", _dropoffLocationController, Icons.location_on_outlined), 
          const SizedBox(height: 12),
          Row(
            children: [
              _buildDateTile("Pickup Date", _pickupDate, (d) => setState(() => _pickupDate = d)),
              const SizedBox(width: 12),
              _buildDateTile("Drop-off Date", _dropoffDate, (d) => setState(() => _dropoffDate = d)),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _goToVehicles,
            style: ElevatedButton.styleFrom(
              backgroundColor: navyDark,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            child: const Text("SEARCH VEHICLES", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildMainBannerCard() {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: primaryBlue, borderRadius: BorderRadius.circular(2)),
      child: Column(
        children: [
          const Text("Book With\nConfidence.", 
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 25),
          ElevatedButton(
            onPressed: _goToVehicles,
            style: ElevatedButton.styleFrom(backgroundColor: accentGold, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2))),
            child: const Text("BOOK A VEHICLE →", style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  Widget _buildSideBannerCard(String title, String desc) {
    return Container(
      width: 240,
      height: 200,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.95), borderRadius: BorderRadius.circular(2)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          const SizedBox(height: 10),
          Text(desc, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildReasonItem(String num, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(num, style: TextStyle(color: accentGold, fontSize: 32, fontWeight: FontWeight.w900)),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                Text(desc, style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String label, String action, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: primaryBlue, size: 28),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: accentGold,
            child: Text(action, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  Widget _navItem(String title, VoidCallback onTap) {
    return TextButton(
      onPressed: onTap,
      child: Text(title, style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w900, fontSize: 13)),
    );
  }

  Widget _buildInput(String hint, TextEditingController ctrl, IconData icon) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        hintText: hint, 
        prefixIcon: Icon(icon, size: 20),
        filled: true, 
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
      ),
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
            lastDate: DateTime.now().add(const Duration(days: 365))
          );
          if (d != null) onPick(d);
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              Text(date == null ? "Select" : DateFormat('dd MMM').format(date), style: const TextStyle(fontWeight: FontWeight.w900)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Row(
      children: ["All", "SUV", "Sedan"].map((t) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(t), 
          selected: _selectedFilter == t, 
          selectedColor: accentGold,
          onSelected: (s) { 
            if (s) {
              setState(() { 
                _selectedFilter = t; 
              }); 
              _fetchFleet();
            }
          },
        ),
      )).toList(),
    );
  }

  Widget _buildCarCard(Car car) {
    return InkWell(
      onTap: _goToVehicles,
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 0,
        shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(8)),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.network(
                car.imageUrl, 
                height: 160, 
                width: double.infinity, 
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.directions_car, size: 100, color: Colors.grey),
              ),
            ),
            ListTile(
              title: Text(car.name, style: const TextStyle(fontWeight: FontWeight.w900)),
              subtitle: Text("₹${car.pricePerDay}/day"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _footerColumn(String title, List<String> items) {
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
          const SizedBox(height: 20),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(item, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          )),
        ],
      ),
    );
  }
}