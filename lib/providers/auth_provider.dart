import 'package:flutter/foundation.dart';
import 'package:financial_literacy_frontend/models/user.dart';
import 'package:financial_literacy_frontend/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  User? get user => _user;
  String? get token => _token;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isInitialized => _isInitialized;

  final ApiService _apiService = ApiService();

  Future<void> loadStoredAuth() async {
    _isLoading = true;
    notifyListeners();
    try {
      _user = await _apiService.loadStoredUser();
      if (_user != null) {
        final prefs = await SharedPreferences.getInstance();
        _token = prefs.getString('authToken');
        _isAuthenticated = true;
      }
      _isInitialized = true;
    } catch (e) {
      _error = 'Failed to load stored auth';
      _isInitialized = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _apiService.login(email, password);
      _user = User.fromJson(response['user']);
      _token = response['token'];
      _isAuthenticated = true;
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _apiService.register(name, email, password);
      _user = User.fromJson(response['user']);
      _token = response['token'];
      _isAuthenticated = true;
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _apiService.logout();
      _user = null;
      _token = null;
      _isAuthenticated = false;
      _error = null;
    } catch (e) {
      _error = 'Logout failed';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(Map<String, dynamic> profileData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _apiService.put('/auth/profile', profileData);
      _user = User.fromJson(response['user']);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}