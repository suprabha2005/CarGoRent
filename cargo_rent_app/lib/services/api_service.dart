import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // Use localhost for Chrome/Web testing
  static const String baseUrl = 'http://localhost:5000/api';
  final _storage = const FlutterSecureStorage();

  // 1. Register User
  Future<http.Response> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'role': 'customer',
        }),
      );
      return response;
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  // 2. Login User & Save Token
  Future<http.Response> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storage.write(key: 'token', value: data['token']);
      }
      return response;
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  // 3. Logout
  Future<void> logout() async {
    await _storage.delete(key: 'token');
  }

  // 4. Get Stored Token
  Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }
}