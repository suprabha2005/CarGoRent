import 'package:flutter/material.dart';
import '../models/car_model.dart';
import '../services/api_service.dart'; // Ensure this import exists
import 'package:intl/intl.dart';

class CarDetailsScreen extends StatefulWidget {
  final Car car;
  const CarDetailsScreen({super.key, required this.car});

  @override
  State<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  DateTimeRange? _selectedDateRange;
  final ApiService _apiService = ApiService(); // Initialize ApiService

  void _selectDates() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedDateRange,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1A237E),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  double _calculateTotal() {
    if (_selectedDateRange == null) return 0.0;
    int days = _selectedDateRange!.duration.inDays;
    return (days == 0 ? 1 : days) * widget.car.pricePerDay;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                widget.car.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.directions_car, size: 100, color: Colors.grey),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.car.brand.toUpperCase(),
                        style: TextStyle(
                            color: Colors.orange.shade800,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(widget.car.type,
                            style: const TextStyle(color: Colors.blue)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.car.name,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Vehicle Description",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Experience premium comfort and performance with this vehicle. Perfect for long trips or city driving. Includes full insurance and 24/7 roadside assistance.",
                    style: TextStyle(color: Colors.grey, height: 1.5),
                  ),
                  const SizedBox(height: 30),
                  const Text("Select Rental Period",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: _selectDates,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month, color: Color(0xFF1A237E)),
                          const SizedBox(width: 15),
                          Text(
                            _selectedDateRange == null
                                ? "Pick start and end dates"
                                : "${DateFormat('MMM dd').format(_selectedDateRange!.start)} - ${DateFormat('MMM dd').format(_selectedDateRange!.end)}",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 100), // Space for bottom bar
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 1)
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Total Price", style: TextStyle(color: Colors.grey)),
                Text(
                  "\$${_calculateTotal().toStringAsFixed(0)}",
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E)),
                ),
              ],
            ),
            SizedBox(
              width: 180,
              height: 50,
              child: ElevatedButton(
                onPressed: _selectedDateRange == null
                    ? null
                    : () async {
                        // START BOOKING LOGIC
                        final bookingData = {
                          "carId": widget.car.id,
                          "startDate": _selectedDateRange!.start.toIso8601String(),
                          "endDate": _selectedDateRange!.end.toIso8601String(),
                          "totalPrice": _calculateTotal(),
                        };

                        final success = await _apiService.createBooking(bookingData);

                        if (success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Booking Successful!"),
                                backgroundColor: Colors.green),
                          );
                          Navigator.pop(context); // Go back to home screen
                        } else if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Booking Failed. Try again."),
                                backgroundColor: Colors.red),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("BOOK NOW",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}