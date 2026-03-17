import 'package:flutter/material.dart';
import '../services/api_service.dart';

class BookingProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<dynamic> _myBookings = [];
  List<dynamic> _vendorRequests = [];
  bool _isLoading = false;
  String? _error;

  List<dynamic> get myBookings => _myBookings;
  List<dynamic> get vendorRequests => _vendorRequests;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchMyBookings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _myBookings = await _api.fetchMyBookings();
    } catch (e) {
      _error = "Failed to load bookings.";
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchVendorRequests() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _vendorRequests = await _api.fetchVendorRequests();
    } catch (e) {
      _error = "Failed to load requests.";
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> createBooking(
      Map<String, dynamic> bookingData) async {
    _isLoading = true;
    notifyListeners();

    final result = await _api.createBooking(bookingData);

    _isLoading = false;
    notifyListeners();
    return result;
  }
}