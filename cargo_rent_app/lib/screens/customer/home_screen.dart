import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/api_service.dart';
import '../../models/car_model.dart';
import 'car_details_screen.dart';
import '../auth/login_screen.dart';
import 'my_bookings_screen.dart';
import '../../utils/cached_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  List<Car> _cars = [];
  List<Car> _filteredCars = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  final Color primaryBlue = const Color(0xFF0052CC);
  final Color accentGold = const Color(0xFFFFD700);
  final Color navyDark = const Color(0xFF0F172A);

  @override
  void initState() {
    super.initState();
    _fetchCars();
  }

  Future<void> _fetchCars() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final cars = await _apiService.fetchCars();
      if (mounted) {
        setState(() {
          _cars = cars;
          _filteredCars = cars;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleLogout() async {
    await _apiService.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false);
    }
  }

  void _filterCars(String query) {
    setState(() {
      _filteredCars = query.isEmpty
          ? _cars
          : _cars
              .where((car) =>
                  car.name.toLowerCase().contains(query.toLowerCase()) ||
                  car.type.toLowerCase().contains(query.toLowerCase()))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: _buildDrawer(),
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchCars,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeBanner(),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildSearchBar(),
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildQuickStats(),
                    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
                    const SizedBox(height: 28),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildSectionHeader("Popular Cars", onViewAll: () {
                        _searchController.clear();
                        _fetchCars();
                      }),
                    ).animate().fadeIn(delay: 400.ms),
                    const SizedBox(height: 12),
                    _buildPopularCarsList(),
                    const SizedBox(height: 28),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildSectionHeader("All Available Fleet", onViewAll: () {
                        _searchController.clear();
                        _fetchCars();
                      }),
                    ).animate().fadeIn(delay: 500.ms),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildAllCarsList(),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      iconTheme: IconThemeData(color: navyDark),
      title: Text("CarGoRent",
          style: TextStyle(color: navyDark, fontWeight: FontWeight.w900, fontSize: 20)),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none),
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No new notifications."), behavior: SnackBarBehavior.floating),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.redAccent),
            onPressed: _handleLogout,
          ),
        ),
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 56, 24, 28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [navyDark, primaryBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: accentGold, borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.directions_car, color: navyDark, size: 26),
                ),
                const SizedBox(height: 14),
                Text("CarGoRent",
                    style: TextStyle(color: accentGold, fontSize: 22, fontWeight: FontWeight.w900)),
                const Text("India's trusted car rental",
                    style: TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _drawerItem(Icons.home_outlined, "Home", () => Navigator.pop(context)),
          _drawerItem(Icons.calendar_today_outlined, "My Bookings", () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const MyBookingsScreen()));
          }),
          _drawerItem(Icons.directions_car_outlined, "Browse Vehicles", () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/vehicles');
          }),
          const Spacer(),
          const Divider(),
          _drawerItem(Icons.logout, "Logout", _handleLogout, color: Colors.redAccent),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? navyDark, size: 22),
      title: Text(title,
          style: TextStyle(fontWeight: FontWeight.w600, color: color ?? const Color(0xFF1E293B))),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [navyDark, primaryBlue],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentGold.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: accentGold.withOpacity(0.4)),
                  ),
                  child: Text("WELCOME BACK",
                      style: TextStyle(
                          color: accentGold, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2),
                const SizedBox(height: 10),
                const Text("Find your\nperfect ride.",
                        style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, height: 1.2))
                    .animate()
                    .fadeIn(delay: 200.ms)
                    .slideX(begin: -0.2),
                const SizedBox(height: 6),
                Text("${_cars.length} vehicles available",
                        style: const TextStyle(color: Colors.white60, fontSize: 13))
                    .animate()
                    .fadeIn(delay: 350.ms),
              ],
            ),
          ),
          Icon(Icons.directions_car, size: 72, color: Colors.white.withOpacity(0.08))
              .animate()
              .fadeIn(delay: 300.ms)
              .scale(begin: const Offset(0.8, 0.8)),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        _statCard(Icons.directions_car_outlined, "${_cars.length}", "Vehicles", primaryBlue),
        const SizedBox(width: 12),
        _statCard(Icons.star_outline, "4.8", "Rating", Colors.orange),
        const SizedBox(width: 12),
        _statCard(Icons.support_agent_outlined, "24/7", "Support", Colors.green),
      ],
    );
  }

  Widget _statCard(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: navyDark)),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _filterCars,
        decoration: InputDecoration(
          icon: Icon(Icons.search, color: primaryBlue),
          hintText: "Search by name or type...",
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {required VoidCallback onViewAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: navyDark)),
        TextButton(
          onPressed: onViewAll,
          child: Text("View All →",
              style: TextStyle(color: primaryBlue, fontWeight: FontWeight.w700, fontSize: 12)),
        ),
      ],
    );
  }

  // ── Popular Cars — horizontal scroll ─────────────────────────────────

  Widget _buildPopularCarsList() {
    if (_cars.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 185,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16, right: 8),
        itemCount: _cars.length > 5 ? 5 : _cars.length,
        itemBuilder: (context, index) => _buildPopularCard(_cars[index], index),
      ),
    );
  }

  Widget _buildPopularCard(Car car, int index) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CarDetailsScreen(car: car))),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: Container(
                height: 100,
                width: double.infinity,
                color: const Color(0xFFF0F4FF),
                child: CachedImage(
                  imageUrl: car.imageUrl,
                  fit: BoxFit.contain,
                  iconSize: 40,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(car.name,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(car.type, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                  const SizedBox(height: 5),
                  Text("₹${car.pricePerDay}/day",
                      style: TextStyle(color: primaryBlue, fontWeight: FontWeight.w900, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 100 + index * 100), duration: 400.ms)
        .slideX(begin: 0.2, curve: Curves.easeOut);
  }

  // ── All Cars — vertical horizontal cards (same as landing page) ───────

  Widget _buildAllCarsList() {
    if (_filteredCars.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30),
          child: Column(
            children: [
              Icon(Icons.search_off, size: 48, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              const Text("No cars match your search.", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredCars.length,
      itemBuilder: (context, index) => _buildCarCard(_filteredCars[index], index),
    );
  }

  Widget _buildCarCard(Car car, int index) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CarDetailsScreen(car: car))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3))],
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
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: navyDark, borderRadius: BorderRadius.circular(20)),
                          child: Text(car.type.toUpperCase(),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                        ),
                        const SizedBox(height: 8),
                        Text(car.name,
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                        const SizedBox(height: 3),
                        Text("Self Drive · AC · ${car.type}",
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                        const SizedBox(height: 10),
                        const Divider(height: 1),
                        const SizedBox(height: 10),
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
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(color: navyDark, borderRadius: BorderRadius.circular(6)),
                          child: const Text("RENT NOW →",
                              style: TextStyle(
                                  color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                        ),
                      ],
                    ),
                  ),
                ),
                // Right — Image
                Expanded(
                  flex: 4,
                  child: Container(
                    color: const Color(0xFFF0F4FF),
                    padding: const EdgeInsets.all(10),
                    child: Image.network(
                      car.imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) =>
                          Icon(Icons.directions_car, size: 60, color: Colors.grey.shade400),
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
        .fadeIn(delay: Duration(milliseconds: 80 + index * 100), duration: 400.ms)
        .slideY(begin: 0.2, curve: Curves.easeOut);
  }
}