import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'add_car_screen.dart';

class VendorDashboard extends StatefulWidget {
  const VendorDashboard({super.key});

  @override
  State<VendorDashboard> createState() => _VendorDashboardState();
}

class _VendorDashboardState extends State<VendorDashboard> {
  final ApiService _apiService = ApiService();
  List<dynamic> _myCars = [];
  List<dynamic> _rentalRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    final userId = await _apiService.getUserId();
    if (userId != null) {
      final results = await Future.wait([
        _apiService.fetchVendorCars(userId),
        _apiService.fetchVendorRequests(),
      ]);
      setState(() {
        _myCars = results[0];
        _rentalRequests = results[1];
        _isLoading = false;
      });
    }
  }

  void _handleStatusUpdate(String bookingId, String status) async {
    final success = await _apiService.updateBookingStatus(bookingId, status);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Booking $status!")));
      _loadDashboardData(); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FB),
        appBar: AppBar(
          title: const Text("Vendor Panel", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(icon: const Icon(Icons.logout, color: Colors.redAccent), onPressed: () async {
              await _apiService.logout();
              Navigator.pushReplacementNamed(context, '/login');
            }),
          ],
          bottom: const TabBar(
            labelColor: Color(0xFF2D31FA),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF2D31FA),
            tabs: [
              Tab(text: "My Fleet"),
              Tab(text: "Requests"),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildFleetTab(),
                  _buildRequestsTab(),
                ],
              ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddCarScreen())).then((_) => _loadDashboardData()),
          backgroundColor: const Color(0xFF1A1A1A),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text("Add Car", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildFleetTab() {
    return _myCars.isEmpty
        ? const Center(child: Text("No cars listed yet."))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _myCars.length,
            itemBuilder: (context, i) {
              final car = _myCars[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(_apiService.getProxyUrl(car['imageUrl'] ?? ""), width: 80, height: 80, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.directions_car, size: 40)),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${car['brand']} ${car['name']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text("₹${car['pricePerDay']}/day", style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: car['isAvailable'] ? Colors.green[50] : Colors.orange[50], borderRadius: BorderRadius.circular(10)),
                      child: Text(car['isAvailable'] ? "Active" : "Rented", style: TextStyle(color: car['isAvailable'] ? Colors.green : Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                    )
                  ],
                ),
              );
            },
          );
  }

  Widget _buildRequestsTab() {
    return _rentalRequests.isEmpty
        ? const Center(child: Text("No active requests."))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _rentalRequests.length,
            itemBuilder: (context, i) {
              final req = _rentalRequests[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(req['carId']?['name'] ?? 'Car', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        Text(req['status'].toUpperCase(), style: TextStyle(color: req['status'] == 'confirmed' ? Colors.green : Colors.orange, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text("Customer: ${req['customerId']?['name'] ?? 'User'}", style: const TextStyle(color: Colors.grey)),
                    if (req['status'] == 'pending') ...[
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _handleStatusUpdate(req['_id'], 'cancelled'),
                              style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                              child: const Text("Reject", style: TextStyle(color: Colors.red)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _handleStatusUpdate(req['_id'], 'confirmed'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                              child: const Text("Accept", style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ],
                      )
                    ]
                  ],
                ),
              );
            },
          );
  }
}