import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/car_model.dart';

class CarProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<Car> _cars = [];
  bool _isLoading = false;
  String? _error;

  List<Car> get cars => _cars;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCars({String? search, String? type}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cars = await _api.fetchCars(search: search, type: type);
    } catch (e) {
      _error = "Failed to load cars. Please try again.";
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchVendorCars(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cars = await _api.fetchVendorCars(userId);
    } catch (e) {
      _error = "Failed to load your cars.";
    }

    _isLoading = false;
    notifyListeners();
  }
}