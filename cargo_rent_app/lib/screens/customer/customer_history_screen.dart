import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../services/api_service.dart';

class CustomerHistoryScreen extends StatefulWidget {
  const CustomerHistoryScreen({super.key});

  @override
  State<CustomerHistoryScreen> createState() => _CustomerHistoryScreenState();
}

class _CustomerHistoryScreenState extends State<CustomerHistoryScreen> {
  final ApiService _apiService = ApiService();
  late Razorpay _razorpay;

  List<dynamic> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _razorpay = Razorpay();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    _loadHistory();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final data = await _apiService.fetchMyBookings();
    setState(() {
      _bookings = data;
      _isLoading = false;
    });
  }

  // ===============================
  // RAZORPAY CHECKOUT TRIGGER
  // ===============================
  Future<void> _startPayment(dynamic booking) async {
    try {
      final orderData =
          await _apiService.createRazorpayOrder(booking['_id']);

      var options = {
        'key': orderData['keyId'],
        'amount': orderData['amount'], // already in paise
        'name': 'CarGoRent',
        'description': 'Car Booking Payment',
        'order_id': orderData['orderId'],
        'prefill': {
          'contact': '9999999999',
          'email': 'customer@email.com'
        },
        'theme': {
          'color': '#1A237E'
        }
      };

      _razorpay.open(options);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to initiate payment")),
      );
    }
  }

  // ===============================
  // PAYMENT SUCCESS
  // ===============================
  Future<void> _handlePaymentSuccess(
      PaymentSuccessResponse response) async {
    try {
      await _apiService.verifyPayment(
        paymentId: response.paymentId!,
        orderId: response.orderId!,
        signature: response.signature!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Payment Successful 🎉"),
          backgroundColor: Colors.green,
        ),
      );

      _loadHistory(); // Refresh bookings
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Payment verification failed"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ===============================
  // PAYMENT FAILURE
  // ===============================
  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Payment Failed: ${response.message}"),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("External Wallet: ${response.walletName}"),
      ),
    );
  }

  // ===============================
  // UI
  // ===============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Rental History"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _loadHistory,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _bookings.isEmpty
                ? const Center(
                    child: Text("You haven't booked any cars yet."),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: _bookings.length,
                    itemBuilder: (context, index) {
                      final booking = _bookings[index];
                      final car = booking['carId'];

                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: car != null
                                    ? Image.network(
                                        _apiService.getProxyUrl(
                                            car['imageUrl']),
                                        width: 60,
                                        fit: BoxFit.cover,
                                      )
                                    : const Icon(Icons.car_rental),
                                title: Text(
                                  car != null
                                      ? "${car['brand']} ${car['name']}"
                                      : "Deleted Car",
                                ),
                                subtitle: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 5),
                                    Text(
                                      "Status: ${booking['status'].toString().toUpperCase()}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: booking['status'] == 'paid'
                                            ? Colors.green
                                            : booking['status'] == 'pending'
                                                ? Colors.orange
                                                : Colors.red,
                                      ),
                                    ),
                                    Text(
                                        "Total: ₹${booking['totalPrice']}"),
                                  ],
                                ),
                              ),

                              // ===============================
                              // PAY BUTTON (ONLY IF PENDING)
                              // ===============================
                              if (booking['status'] == 'pending')
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton(
                                    onPressed: () =>
                                        _startPayment(booking),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.indigo,
                                    ),
                                    child: const Text("Pay Now"),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}