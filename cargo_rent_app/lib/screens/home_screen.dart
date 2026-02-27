import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'car_details_screen.dart';
import 'login_screen.dart';
import 'my_bookings_screen.dart'; // We will create this file next!

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _cars = [];
  List<dynamic> _filteredCars = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCars();
  }

  void _fetchCars() async {
    setState(() => _isLoading = true);
    final cars = await _apiService.fetchAllCars();
    setState(() {
      _cars = cars;
      _filteredCars = cars;
      _isLoading = false;
    });
  }

  void _handleLogout() async {
    await _apiService.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _filterCars(String query) {
    setState(() {
      _filteredCars = _cars
          .where((car) =>
              (car['model'] ?? car['name'] ?? '')
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              (car['brand'] ?? '')
                  .toLowerCase()
                  .contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      drawer: Drawer(
        child: Column(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blueAccent),
              child: Center(
                child: Text(
                  "CarGoRent",
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Home"),
              onTap: () => Navigator.pop(context),
            ),
            // FIX: Linked My Bookings
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text("My Bookings"),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyBookingsScreen()),
                );
              },
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout"),
              onTap: _handleLogout,
            ),
          ],
        ),
      ),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "CarGoRent",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          // FIX: Bell Icon now does something!
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("You have no new notifications.")),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.redAccent),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async => _fetchCars(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildSearchBar(),
                    const SizedBox(height: 25),
                    _buildSectionHeader("Popular Cars"),
                    const SizedBox(height: 15),
                    _buildPopularCarsList(),
                    const SizedBox(height: 25),
                    _buildSectionHeader("All Available Fleet"),
                    const SizedBox(height: 15),
                    _buildAllCarsGrid(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _filterCars,
        decoration: const InputDecoration(
          icon: Icon(Icons.search, color: Colors.blueAccent),
          hintText: "Search for your dream car...",
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        TextButton(
          onPressed: () {
            _searchController.clear();
            _fetchCars();
          }, 
          child: const Text("View All", style: TextStyle(color: Colors.blueAccent))
        )
      ],
    );
  }

  Widget _buildPopularCarsList() {
    return SizedBox(
      height: 230,
      child: _cars.isEmpty 
        ? const Center(child: Text("No cars found"))
        : ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _cars.length > 5 ? 5 : _cars.length,
            itemBuilder: (context, index) {
              final car = _cars[index];
              return _buildCarCard(car, width: 280);
            },
          ),
    );
  }

  Widget _buildAllCarsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredCars.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemBuilder: (context, index) {
        final car = _filteredCars[index];
        return _buildCarCard(car);
      },
    );
  }

  Widget _buildCarCard(dynamic car, {double? width}) {
    String modelName = car['model'] ?? car['name'] ?? 'Unknown Model';
    String brandName = car['brand'] ?? 'Car';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CarDetailsScreen(car: car)),
      ),
      child: Container(
        width: width,
        margin: width != null ? const EdgeInsets.only(right: 15) : null,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, spreadRadius: 2)]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFFF2F2F2),
                  child: Image.network(
                    _apiService.getProxyUrl(car['imageUrl'] ?? ""),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => 
                        const Icon(Icons.directions_car, size: 50, color: Colors.grey),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(modelName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(brandName, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 8),
                  Text("₹${car['pricePerDay']}/day", style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}