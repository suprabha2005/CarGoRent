import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import '../models/car_model.dart';

class ApiService {
  // Use 10.0.2.2 if testing on Android Emulator, localhost for Web/iOS
  final String baseUrl = "http://localhost:5000/api"; 
  final _storage = const FlutterSecureStorage();

  String getProxyUrl(String originalUrl) {
    if (originalUrl.isEmpty) return "";
    if (originalUrl.startsWith('http')) {
      return "$baseUrl/proxy-image?url=${Uri.encodeComponent(originalUrl)}";
    }
    return originalUrl;
  }

  // --- AUTHENTICATION ---
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
        "role": role
      };
      if (role == 'admin' && adminCode != null) body["adminCode"] = adminCode;
      
      final response = await http.post(
        Uri.parse("$baseUrl/auth/register"), 
        headers: {"Content-Type": "application/json"}, 
        body: jsonEncode(body)
      );
      return response.statusCode == 201;
    } catch (e) { return false; }
  }

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/login"), 
        headers: {"Content-Type": "application/json"}, 
        body: jsonEncode({"email": email, "password": password})
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storage.write(key: 'token', value: data['token']);
        await _storage.write(key: 'userId', value: data['user']['id']); 
        await _storage.write(key: 'role', value: data['user']['role']);
        return data;
      } 
      return null;
    } catch (e) { return null; }
  }

  Future<void> logout() async { await _storage.deleteAll(); }
  Future<String?> getToken() async => await _storage.read(key: 'token');
  Future<String?> getRole() async => await _storage.read(key: 'role');
  Future<String?> getUserId() async => await _storage.read(key: 'userId');

  // --- CAR MANAGEMENT ---
  
  Future<List<Car>> fetchAllCars() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/cars"));
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) {
          Car car = Car.fromJson(item);
          return car.copyWith(imageUrl: getProxyUrl(car.imageUrl));
        }).toList().cast<Car>();
      }
      return [];
    } catch (e) { 
      debugPrint("API Error fetchAllCars: $e");
      return []; 
    }
  }

  Future<List<Car>> fetchCars({String? search, String? type}) async {
    // If no filters are applied, just call the clean fetchAllCars endpoint
    if ((search == null || search.isEmpty) && (type == null || type == "All")) {
      return fetchAllCars();
    }

    try {
      final queryParameters = <String, String>{};
      if (search != null && search.isNotEmpty) queryParameters['search'] = search;
      if (type != null && type != "All") queryParameters['type'] = type;

      final uri = Uri.parse("$baseUrl/cars").replace(queryParameters: queryParameters);
      
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) {
          Car car = Car.fromJson(item);
          return car.copyWith(imageUrl: getProxyUrl(car.imageUrl));
        }).toList().cast<Car>();
      }
      return [];
    } catch (e) { 
      debugPrint("API Error fetchCars: $e");
      return []; 
    }
  }

  Future<List<Car>> fetchVendorCars(String userId) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/cars/vendor/$userId"));
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) {
          Car car = Car.fromJson(item);
          return car.copyWith(imageUrl: getProxyUrl(car.imageUrl));
        }).toList().cast<Car>();
      }
      return [];
    } catch (e) { return []; }
  }

  Future<bool> addCar(Map<String, dynamic> carData) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse("$baseUrl/cars"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: jsonEncode(carData),
      );
      return response.statusCode == 201;
    } catch (e) { return false; }
  }

  // --- BOOKING SYSTEM ---
  
  Future<bool> createBooking(Map<String, dynamic> bookingData) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse("$baseUrl/bookings"),
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

  Future<bool> updateBookingStatus(String bookingId, String status) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse("$baseUrl/bookings/update-status"), 
        headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"}, 
        body: jsonEncode({"bookingId": bookingId, "status": status})
      );
      return response.statusCode == 200;
    } catch (e) { return false; }
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

  // --- ADMIN METHODS ---
  
  Future<Map<String, dynamic>> fetchAdminStats() async {
    try {
      final token = await getToken();
      final response = await http.get(Uri.parse("$baseUrl/admin/stats"), headers: {"Authorization": "Bearer $token"});
      return response.statusCode == 200 ? jsonDecode(response.body) : {};
    } catch (e) { return {}; }
  }

  Future<List<dynamic>> fetchPendingVendors() async {
    try {
      final token = await getToken();
      final response = await http.get(Uri.parse("$baseUrl/admin/pending-vendors"), headers: {"Authorization": "Bearer $token"});
      return response.statusCode == 200 ? jsonDecode(response.body) : [];
    } catch (e) { return []; }
  }

  Future<bool> approveVendor(String vendorId) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse("$baseUrl/admin/approve-vendor"), 
        headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"}, 
        body: jsonEncode({"vendorId": vendorId})
      );
      return response.statusCode == 200;
    } catch (e) { return false; }
  }

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
        })
      );
      return response.statusCode == 200;
    } catch (e) { return false; }
  }
}