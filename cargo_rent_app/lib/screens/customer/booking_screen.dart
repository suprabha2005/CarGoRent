import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class BookingScreen extends StatefulWidget {
  final dynamic car;

  const BookingScreen({super.key, required this.car});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  final int _bookingDays = 2;

  void _confirmBooking() async {
    setState(() => _isLoading = true);

    final customerId = await _apiService.getUserId();

    final bookingData = {
      "carId": widget.car['_id'],
      "customerId": customerId,
      "vendorId": widget.car['vendorId'],
      "startDate": DateTime.now().toString(),
      "endDate": DateTime.now().add(Duration(days: _bookingDays)).toString(),
      "totalPrice": widget.car['pricePerDay'] * _bookingDays,
    };

    final result = await _apiService.createBooking(bookingData);
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Success!"),
          content: const Text("Booking request sent to the vendor."),
          actions: [
            TextButton(
              onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
              child: const Text("OK"),
            )
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? "Booking failed.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final car = widget.car;
    final String proxyImageUrl = "http://localhost:5000/api/proxy-image?url=${car['imageUrl']}";

    return Scaffold(
      appBar: AppBar(
        title: Text("Book ${car['name']}"),
        backgroundColor: Colors.indigo[900],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.network(
              proxyImageUrl,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 250,
                color: Colors.grey[200],
                child: const Icon(Icons.directions_car, size: 80, color: Colors.grey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${car['brand'] ?? ''} ${car['name']}",
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "₹${car['pricePerDay']} / day",
                    style: const TextStyle(fontSize: 20, color: Colors.green, fontWeight: FontWeight.w600),
                  ),
                  const Divider(height: 40),
                  const Text("Booking Summary",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Duration:"),
                      Text("$_bookingDays Days"),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total Price:",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("₹${car['pricePerDay'] * _bookingDays}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                  const SizedBox(height: 40),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo[900],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: _confirmBooking,
                            child: const Text("CONFIRM BOOKING",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}