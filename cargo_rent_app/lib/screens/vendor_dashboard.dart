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
      final cars = await _apiService.fetchVendorCars(userId);
      final requests = await _apiService.fetchVendorRequests();
      setState(() {
        _myCars = cars;
        _rentalRequests = requests;
        _isLoading = false;
      });
    }
  }

  void _handleStatusUpdate(String bookingId, String status) async {
    final success = await _apiService.updateBookingStatus(bookingId, status);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Booking $status successfully!")),
      );
      _loadDashboardData(); // Refresh list
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Vendor Panel"),
          backgroundColor: Colors.indigo[900],
          foregroundColor: Colors.white,
          actions: [
            // ADDED: Logout Button
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await _apiService.logout();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.directions_car), text: "My Fleet"),
              Tab(icon: Icon(Icons.notifications), text: "Rental Requests"),
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
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => const AddCarScreen())
          ).then((_) => _loadDashboardData()),
          backgroundColor: Colors.indigo[900],
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildFleetTab() {
    return _myCars.isEmpty
        ? const Center(child: Text("No cars listed yet."))
        : ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: _myCars.length,
            itemBuilder: (context, i) => Card(
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    // FIXED: Using Proxy URL for images
                    _apiService.getProxyUrl(_myCars[i]['imageUrl'] ?? ""), 
                    width: 60, 
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.directions_car, size: 40),
                  ),
                ),
                title: Text("${_myCars[i]['brand']} ${_myCars[i]['name']}"),
                subtitle: Text("\$${_myCars[i]['pricePerDay']}/day"),
              ),
            ),
          );
  }

  Widget _buildRequestsTab() {
    return _rentalRequests.isEmpty
        ? const Center(child: Text("No active rental requests."))
        : ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: _rentalRequests.length,
            itemBuilder: (context, i) {
              final req = _rentalRequests[i];
              final bool isPending = req['status'] == 'pending';

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text("Booking for: ${req['carId'] != null ? req['carId']['name'] : 'Unknown Car'}"),
                  subtitle: Text(
                    "Customer: ${req['customerId'] != null ? req['customerId']['name'] : 'Guest'}\n"
                    "Status: ${req['status'].toUpperCase()}",
                    style: TextStyle(
                      color: req['status'] == 'confirmed' ? Colors.green : 
                             req['status'] == 'cancelled' ? Colors.red : Colors.orange,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  isThreeLine: true,
                  trailing: isPending 
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check_circle, color: Colors.green, size: 30),
                            onPressed: () => _handleStatusUpdate(req['_id'], 'confirmed'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.red, size: 30),
                            onPressed: () => _handleStatusUpdate(req['_id'], 'cancelled'),
                          ),
                        ],
                      )
                    : const Icon(Icons.history, color: Colors.grey),
                ),
              );
            },
          );
  }
}