import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CarDetailsScreen extends StatefulWidget {
  final dynamic car;
  const CarDetailsScreen({super.key, required this.car});

  @override
  State<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  final ApiService _apiService = ApiService();
  DateTimeRange? _selectedRange;

  void _selectDates() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF1A237E)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedRange = picked);
      _showConfirmationDialog();
    }
  }

  void _showConfirmationDialog() {
    final days = _selectedRange!.duration.inDays + 1;
    final pricePerDay = widget.car['pricePerDay'] ?? 0;
    final total = days * (pricePerDay as num);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Your Booking"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Car: ${widget.car['name']}"),
            Text("Duration: $days days"),
            const SizedBox(height: 10),
            Text("Total Cost: \$${total.toStringAsFixed(2)}", 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A237E)),
            onPressed: () => _confirmBooking(total),
            child: const Text("Confirm", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmBooking(num total) async {
    Navigator.pop(context); // Close dialog
    
    // UPDATED: Using 'vendorId' to match your Backend model
    dynamic rawVendor = widget.car['vendorId']; 
    String? vendorId;

    if (rawVendor is Map) {
      vendorId = rawVendor['_id'];
    } else if (rawVendor is String) {
      vendorId = rawVendor;
    }

    if (vendorId == null || vendorId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: Owner information missing for this car."), backgroundColor: Colors.red),
      );
      return;
    }

    final success = await _apiService.createBooking({
      "carId": widget.car['_id'],
      "vendorId": vendorId,
      "startDate": _selectedRange!.start.toIso8601String(),
      "endDate": _selectedRange!.end.toIso8601String(),
      "totalPrice": total,
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booking Request Sent Successfully!"), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to create booking. Please try again."), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // UPDATED: Getting vendor name from 'vendorId' object
    final vendorName = (widget.car['vendorId'] is Map) 
        ? widget.car['vendorId']['name'] 
        : "Verified Vendor";

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            backgroundColor: const Color(0xFF1A237E),
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                _apiService.getProxyUrl(widget.car['imageUrl'] ?? ''),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => 
                    Container(color: Colors.grey[300], child: const Icon(Icons.directions_car, size: 100)),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.car['brand']?.toUpperCase() ?? 'CAR', 
                    style: const TextStyle(fontSize: 14, letterSpacing: 1.2, color: Colors.indigo, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(widget.car['name'] ?? 'Car Name', 
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 20),
                      const SizedBox(width: 4),
                      const Text("4.8 (Verified Car)", style: TextStyle(color: Colors.grey)),
                      const Spacer(),
                      Text("\$${widget.car['pricePerDay']}", 
                        style: const TextStyle(fontSize: 24, color: Colors.green, fontWeight: FontWeight.bold)),
                      const Text("/day", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const Divider(height: 40),
                  const Text("Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(widget.car['description'] ?? "No description available for this vehicle.", 
                    style: const TextStyle(color: Colors.grey, height: 1.5)),
                  const SizedBox(height: 20),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(backgroundColor: Colors.indigo, child: Icon(Icons.person, color: Colors.white)),
                    title: Text("Hosted by $vendorName"),
                    subtitle: const Text("Professional Host"),
                  ),
                  const SizedBox(height: 100), 
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, spreadRadius: 5)],
        ),
        child: ElevatedButton(
          onPressed: _selectDates,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A237E),
            minimumSize: const Size(double.infinity, 55),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text("CHECK AVAILABILITY & BOOK", 
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}