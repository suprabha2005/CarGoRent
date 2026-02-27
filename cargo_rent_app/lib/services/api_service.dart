import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // Use 10.0.2.2 for Android Emulator, localhost for Chrome/Web, or your IP for physical devices
  final String baseUrl = "http://localhost:5000/api"; 
  final _storage = const FlutterSecureStorage();

  // Helper to handle image proxying and avoid CORS/Loading issues
  String getProxyUrl(String originalUrl) {
    if (originalUrl.isEmpty) return "";
    return "$baseUrl/proxy-image?url=${Uri.encodeComponent(originalUrl)}";
  }

  // --- 1. AUTHENTICATION & SESSION ---
  Future<bool> register({
    required String name, 
    required String email, 
    required String password, 
    required String role, 
    String? adminCode
  }) async {
    try {
      Map<String, dynamic> body = {
        "name": name,
        "email": email,
        "password": password,
        "role": role,
      };
      if (role == 'admin' && adminCode != null) body["adminCode"] = adminCode;

      final response = await http.post(
        Uri.parse("$baseUrl/auth/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
      return response.statusCode == 201;
    } catch (e) { return false; }
  }

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storage.write(key: 'token', value: data['token']);
        await _storage.write(key: 'userId', value: data['user']['id']); 
        await _storage.write(key: 'role', value: data['user']['role']);
        await _storage.write(key: 'verificationStatus', value: data['user']['verificationStatus']);
        return data;
      } 
      return null;
    } catch (e) { return null; }
  }

  Future<void> logout() async { await _storage.deleteAll(); }

  Future<String?> getToken() async => await _storage.read(key: 'token');
  Future<String?> getRole() async => await _storage.read(key: 'role');
  Future<String?> getUserId() async => await _storage.read(key: 'userId');
  Future<String?> getVerificationStatus() async => await _storage.read(key: 'verificationStatus');

  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse("$baseUrl/auth/profile"),
        headers: {"Authorization": "Bearer $token"},
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (e) { print("Profile Error: $e"); }
    return null;
  }

  // --- 2. VENDOR DOCS SUBMISSION ---
  Future<bool> submitVendorDocs(String license, String idProof) async {
    try {
      final userId = await getUserId();
      final response = await http.post(
        Uri.parse("$baseUrl/auth/submit-docs"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": userId,
          "businessLicense": license,
          "idProofUrl": idProof
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storage.write(key: 'verificationStatus', value: data['status']);
        return true;
      }
      return false;
    } catch (e) { return false; }
  }

  // --- 3. CAR METHODS ---
  Future<List<dynamic>> fetchCars({String? search, String? type}) async {
    try {
      String url = "$baseUrl/cars?";
      if (search != null && search.isNotEmpty) url += "search=$search&";
      if (type != null && type != "All") url += "type=$type";
      
      final response = await http.get(Uri.parse(url));
      return response.statusCode == 200 ? jsonDecode(response.body) : [];
    } catch (e) { return []; }
  }

  Future<List<dynamic>> fetchVendorCars(String vendorId) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/cars/vendor/$vendorId"));
      return response.statusCode == 200 ? jsonDecode(response.body) : [];
    } catch (e) { return []; }
  }

  Future<bool> addCar(Map<String, dynamic> carData) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse("$baseUrl/cars/add"),
        headers: {
          "Content-Type": "application/json", 
          "Authorization": "Bearer $token"
        },
        body: jsonEncode(carData),
      );
      return response.statusCode == 201;
    } catch (e) { return false; }
  }

  // --- 4. BOOKING METHODS ---
  Future<bool> createBooking(Map<String, dynamic> bookingData) async {
    try {
      final token = await getToken();
      final userId = await getUserId();
      bookingData['customerId'] = userId;

      final response = await http.post(
        Uri.parse("$baseUrl/bookings/create"),
        headers: {
          "Content-Type": "application/json", 
          "Authorization": "Bearer $token"
        },
        body: jsonEncode(bookingData),
      );
      return response.statusCode == 201;
    } catch (e) { return false; }
  }

  Future<List<dynamic>> fetchMyBookings() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse("$baseUrl/bookings/my-bookings"), 
        headers: {"Authorization": "Bearer $token"}
      );
      return response.statusCode == 200 ? jsonDecode(response.body) : [];
    } catch (e) { return []; }
  }

  Future<List<dynamic>> fetchVendorRequests() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse("$baseUrl/bookings/vendor-requests"), 
        headers: {"Authorization": "Bearer $token"}
      );
      return response.statusCode == 200 ? jsonDecode(response.body) : [];
    } catch (e) { return []; }
  }

  Future<bool> updateBookingStatus(String bookingId, String status) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse("$baseUrl/bookings/update-status"),
        headers: {
          "Content-Type": "application/json", 
          "Authorization": "Bearer $token"
        },
        body: jsonEncode({
          "bookingId": bookingId,
          "status": status,
        }),
      );
      return response.statusCode == 200;
    } catch (e) { return false; }
  }

  // --- 5. ADMIN & VERIFICATION ---
  Future<Map<String, dynamic>> fetchAdminStats() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/admin/stats"));
      return response.statusCode == 200 ? jsonDecode(response.body) : {};
    } catch (e) { return {}; }
  }

  Future<List<dynamic>> fetchPendingVendors() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/admin/pending-vendors"));
      return response.statusCode == 200 ? jsonDecode(response.body) : [];
    } catch (e) { return []; }
  }

  Future<bool> approveVendor(String userId) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/admin/approve-vendor"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userId": userId}),
      );
      return response.statusCode == 200;
    } catch (e) { return false; }
  }
}