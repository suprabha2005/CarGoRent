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
          type: _selectedFilter == "All" ? null : _selectedFilter);
      if (mounted) {
        setState(() {
          _availableCars = cars;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goToLogin() => Navigator.pushNamed(context, '/login');
  void _goToRegister() => Navigator.pushNamed(context, '/register');
  void _goToVehicles() => Navigator.pushNamed(context, '/vehicles');

  void _scrollToSection(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) Scrollable.ensureVisible(ctx, duration: 800.ms, curve: Curves.easeInOut);
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
              _navItem("HOME", () => _scrollController.animateTo(0, duration: 800.ms, curve: Curves.easeInOut), 0),
              _navItem("VEHICLES", _goToVehicles, 1),
              _navItem("ABOUT US", () => _scrollToSection(_aboutKey), 2),
              _navItem("CONTACT US", () => _scrollToSection(_footerKey), 3),
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
          ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
        ],
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // ── Hero Section ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 400,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage('https://images.unsplash.com/photo-1541899481282-d53bffe3c35d?w=2070'),
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Colors.black.withOpacity(0.65), Colors.transparent],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Pill badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0x33FFD700),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0x80FFD700)),
                          ),
                          child: const Text("🚗  INDIA'S TRUSTED CAR RENTAL",
                              style: TextStyle(color: Color(0xFFFFD700), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                        ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, curve: Curves.easeOut),
                        const SizedBox(height: 14),
                        // Headline
                        const Text("Reliable car rentals\nacross India.",
                            style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, height: 1.1))
                            .animate()
                            .fadeIn(delay: 200.ms, duration: 700.ms)
                            .slideX(begin: -0.2, curve: Curves.easeOut),
                        const SizedBox(height: 12),
                        const Text("Affordable. Safe. Everywhere.",
                            style: TextStyle(color: Colors.white70, fontSize: 14))
                            .animate()
                            .fadeIn(delay: 400.ms, duration: 600.ms)
                            .slideX(begin: -0.2, curve: Curves.easeOut),
                      ],
                    ),
                  ),
                ),
                // Search box slides up from below
                Positioned(
                  bottom: -110,
                  left: 20,
                  right: 20,
                  child: _buildSearchBox()
                      .animate()
                      .fadeIn(delay: 600.ms, duration: 700.ms)
                      .slideY(begin: 0.3, curve: Curves.easeOut),
                ),
              ],
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 150)),

          // ── Promo Banner ──────────────────────────────────────────
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
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1.2))
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .shimmer(delay: 800.ms, duration: 1200.ms, color: Colors.white30),
                  const SizedBox(height: 40),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSideBannerCard("Unlimited\nKilometres.", "Explore with zero mileage worries.")
                            .animate().fadeIn(delay: 200.ms, duration: 500.ms).slideX(begin: -0.3, curve: Curves.easeOut),
                        const SizedBox(width: 15),
                        _buildMainBannerCard()
                            .animate().fadeIn(delay: 350.ms, duration: 500.ms).scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOut),
                        const SizedBox(width: 15),
                        _buildSideBannerCard("Vehicles For\nEvery Need.", "Automatic & AC equipped for your comfort.")
                            .animate().fadeIn(delay: 500.ms, duration: 500.ms).slideX(begin: 0.3, curve: Curves.easeOut),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Fleet Section Header ──────────────────────────────────
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
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)))
                          .animate().fadeIn(duration: 500.ms).slideX(begin: -0.15, curve: Curves.easeOut),
                      TextButton(
                        onPressed: _goToVehicles,
                        child: const Text("VIEW ALL →", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildFilterChips(),
                ],
              ),
            ),
          ),

          // ── Car List ──────────────────────────────────────────────
          _isLoading
              ? const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()))
              : _availableCars.isEmpty
                  ? const SliverToBoxAdapter(
                      child: Center(child: Padding(padding: EdgeInsets.all(20), child: Text("No vehicles available for this filter."))))
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildCarCard(_availableCars[index], index),
                          childCount: _availableCars.length > 3 ? 3 : _availableCars.length,
                        ),
                      ),
                    ),

          // ── About Section ─────────────────────────────────────────
          SliverToBoxAdapter(
            key: _aboutKey,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0F172A), Color(0xFF0052CC)],
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0x26FFD700),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0x66FFD700)),
                    ),
                    child: const Text("WHY CARGORENT",
                        style: TextStyle(color: Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                  ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, curve: Curves.easeOut),
                  const SizedBox(height: 16),
                  const Text("Everything you need\nfor a perfect ride.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, height: 1.2))
                      .animate().fadeIn(delay: 150.ms, duration: 600.ms).slideY(begin: 0.2, curve: Curves.easeOut),
                  const SizedBox(height: 8),
                  const Text("Trusted by thousands of customers across India.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white54, fontSize: 13))
                      .animate().fadeIn(delay: 250.ms, duration: 500.ms),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStat("500+", "Vehicles")
                          .animate().fadeIn(delay: 300.ms, duration: 500.ms).scale(begin: const Offset(0.7, 0.7), curve: Curves.elasticOut),
                      _buildStatDivider().animate().fadeIn(delay: 350.ms),
                      _buildStat("50K+", "Customers")
                          .animate().fadeIn(delay: 400.ms, duration: 500.ms).scale(begin: const Offset(0.7, 0.7), curve: Curves.elasticOut),
                      _buildStatDivider().animate().fadeIn(delay: 450.ms),
                      _buildStat("4.8★", "Rating")
                          .animate().fadeIn(delay: 500.ms, duration: 500.ms).scale(begin: const Offset(0.7, 0.7), curve: Curves.elasticOut),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFeatureCard(Icons.directions_car_outlined, "Wide Selection", "Luxury & budget vehicles.")
                            .animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(begin: 0.3, curve: Curves.easeOut),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildFeatureCard(Icons.currency_rupee, "Best Rates", "Zero hidden costs.")
                            .animate().fadeIn(delay: 300.ms, duration: 500.ms).slideY(begin: 0.3, curve: Curves.easeOut),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFeatureCard(Icons.verified_user_outlined, "Secure Booking", "Safe & encrypted system.")
                            .animate().fadeIn(delay: 400.ms, duration: 500.ms).slideY(begin: 0.3, curve: Curves.easeOut),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildFeatureCard(Icons.route_outlined, "Unlimited KMs", "No mileage limits.")
                            .animate().fadeIn(delay: 500.ms, duration: 500.ms).slideY(begin: 0.3, curve: Curves.easeOut),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Footer Section ────────────────────────────────────────
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
                      _buildContactItem(Icons.search, "BOOK ONLINE", "GET STARTED", _goToVehicles)
                          .animate().fadeIn(duration: 500.ms).slideX(begin: -0.2, curve: Curves.easeOut),
                      _buildContactItem(Icons.phone, "RESERVATION", "+91 98765 43210", () {})
                          .animate().fadeIn(delay: 150.ms, duration: 500.ms).slideX(begin: 0.2, curve: Curves.easeOut),
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
                      _footerColumn("CARGORENT INDIA", ["Airport Transfers", "+91 98765 43210"])
                          .animate().fadeIn(delay: 100.ms, duration: 500.ms).slideY(begin: 0.2),
                      _footerColumn("NAVIGATE", ["Vehicles", "Branches", "FAQ"])
                          .animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(begin: 0.2),
                      _footerColumn("INFORMATION", ["Terms", "Privacy", "Refunds"])
                          .animate().fadeIn(delay: 300.ms, duration: 500.ms).slideY(begin: 0.2),
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
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accentGold,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                ),
                                child: const Text("REGISTER NOW",
                                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 11)),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 400.ms, duration: 500.ms).slideY(begin: 0.2),
                    ],
                  ),
                  const SizedBox(height: 60),
                  const Text("© 2026 CARGORENT INDIA", style: TextStyle(color: Colors.grey, fontSize: 12))
                      .animate().fadeIn(delay: 500.ms, duration: 600.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Widget Builders ───────────────────────────────────────────────

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
            child: const Text("SEARCH VEHICLES",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
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
            style: ElevatedButton.styleFrom(
                backgroundColor: accentGold,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2))),
            child: const Text("BOOK A VEHICLE →",
                style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.w900)),
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

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: accentGold, fontSize: 26, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
      ],
    );
  }

  Widget _buildStatDivider() => Container(width: 1, height: 40, color: Colors.white24);

  Widget _buildFeatureCard(IconData icon, String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: accentGold, size: 26),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900)),
          const SizedBox(height: 3),
          Text(desc, style: const TextStyle(color: Colors.white54, fontSize: 10), maxLines: 2, overflow: TextOverflow.ellipsis),
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

  Widget _navItem(String title, VoidCallback onTap, int index) {
    return TextButton(
      onPressed: onTap,
      child: Text(title, style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w900, fontSize: 13)),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 100 * index), duration: 400.ms)
        .slideY(begin: -0.3, curve: Curves.easeOut);
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
            lastDate: DateTime.now().add(const Duration(days: 365)),
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
              Text(date == null ? "Select" : DateFormat('dd MMM').format(date),
                  style: const TextStyle(fontWeight: FontWeight.w900)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ["All", "Sedan", "SUV", "Luxury", "Electric"];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.asMap().entries.map((e) {
          final isSelected = _selectedFilter == e.value;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(e.value),
              selected: isSelected,
              selectedColor: accentGold,
              backgroundColor: Colors.grey.shade100,
              labelStyle: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: isSelected ? Colors.black : Colors.black54,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? accentGold : Colors.grey.shade300,
                ),
              ),
              onSelected: (s) {
                if (s) {
                  setState(() => _selectedFilter = e.value);
                  _fetchFleet();
                }
              },
            ),
          )
              .animate()
              .fadeIn(delay: Duration(milliseconds: 100 * e.key), duration: 400.ms)
              .slideX(begin: -0.2, curve: Curves.easeOut);
        }).toList(),
      ),
    );
  }

  Widget _buildCarCard(Car car, int index) {
    return GestureDetector(
      onTap: _goToVehicles,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: navyDark, borderRadius: BorderRadius.circular(20)),
                          child: Text(car.type.toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                        ),
                        const SizedBox(height: 6),
                        Text(car.name,
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                        const SizedBox(height: 3),
                        Text("Self Drive · AC · ${car.type}",
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                        const SizedBox(height: 8),
                        const Divider(height: 1),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("₹${car.pricePerDay}",
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: primaryBlue)),
                            const Padding(
                              padding: EdgeInsets.only(bottom: 2, left: 3),
                              child: Text("/day", style: TextStyle(fontSize: 11, color: Colors.grey)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(color: navyDark, borderRadius: BorderRadius.circular(6)),
                          child: const Text("RENT NOW →",
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Container(
                    color: const Color(0xFFF0F4FF),
                    padding: const EdgeInsets.all(12),
                    child: Image.network(
                      car.imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(Icons.directions_car, size: 80, color: Colors.grey.shade400),
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
        .fadeIn(delay: Duration(milliseconds: 150 * index), duration: 500.ms)
        .slideX(begin: 0.15, curve: Curves.easeOut);
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