import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // Use '10.0.2.2' if testing on Android Emulator, 'localhost' for Chrome/Web
  final String baseUrl = "http://localhost:5000/api"; 
  final _storage = const FlutterSecureStorage();

  // --- 1. REGISTRATION ---
  Future<bool> register(String name, String email, String password, String role) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
          "role": role,
        }),
      ).timeout(const Duration(seconds: 10));
      return response.statusCode == 201;
    } catch (e) {
      print("Registration Error: $e");
      return false;
    }
  }

  // --- 2. LOGIN ---
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Save both token and user ID for later use in bookings
        await _storage.write(key: 'token', value: data['token']);
        await _storage.write(key: 'userId', value: data['user']['id']); 
        await _storage.write(key: 'role', value: data['user']['role']);
        return data;
      }
    } catch (e) {
      print("Login Error: $e");
    }
    return null;
  }

  // --- 3. CARS ---
  Future<List<dynamic>> fetchCars() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/cars/all"));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("Fetch Cars Error: $e");
    }
    return [];
  }

  Future<bool> addCar(Map<String, dynamic> carData) async {
    final token = await _storage.read(key: 'token');
    final response = await http.post(
      Uri.parse("$baseUrl/cars/add"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(carData),
    );
    return response.statusCode == 201;
  }

  // --- 4. BOOKINGS ---
  Future<bool> createBooking(Map<String, dynamic> bookingData) async {
    final token = await _storage.read(key: 'token');
    final userId = await _storage.read(key: 'userId');

    // Add the userId to the booking data automatically before sending
    final completeBookingData = {
      ...bookingData,
      "userId": userId,
    };

    final response = await http.post(
      Uri.parse("$baseUrl/bookings/create"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(completeBookingData),
    );
    
    return response.statusCode == 201;
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }
}