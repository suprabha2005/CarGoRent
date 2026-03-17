import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  String? _token;
  String? _role;
  String? _userId;
  bool _isLoading = false;

  String? get token => _token;
  String? get role => _role;
  String? get userId => _userId;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _token != null;

  // Call this when app starts to restore session
  Future<void> loadSession() async {
    _token = await _api.getToken();
    _role = await _api.getRole();
    _userId = await _api.getUserId();
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final result = await _api.login(email, password);

    if (result != null) {
      _token = result['token'];
      _role = result['user']['role'];
      _userId = result['user']['id'];
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    await _api.logout();
    _token = null;
    _role = null;
    _userId = null;
    notifyListeners();
  }
}