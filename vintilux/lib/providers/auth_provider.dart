import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  User? _user;
  String? _token;
  String _error = '';
  bool _isLoading = false;
  String? _userId;

  AuthProvider(this._authService);

  User? get user => _user;
  String? get token => _token;
  String get error => _error;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null && _user != null;

  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      developer.log('Attempting login for email: $email');
      final loginResult = await _authService.login(email, password);
      
      if (loginResult.token == null || loginResult.user == null) {
        throw Exception('Invalid credentials');
      }
      
      _user = loginResult.user;
      _token = loginResult.token;
      
      developer.log('Login successful');
      developer.log('Token: $_token');
      developer.log('User: ${_user?.toJson()}');
      
      _error = '';
      return true;
    } catch (e) {
      developer.log('Login error: $e');
      _error = e.toString();
      _user = null;
      _token = null;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String name, String email, String password) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      developer.log('Attempting registration for email: $email');
      final loginResult = await _authService.register(name, email, password);
      
      _user = loginResult.user;
      _token = loginResult.token;
      
      developer.log('Registration successful');
      developer.log('Token: $_token');
      developer.log('User: ${_user?.toJson()}');
      
      _error = '';
      return true;
    } catch (e) {
      developer.log('Registration error: $e');
      _error = e.toString();
      _user = null;
      _token = null;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      developer.log('Logging out user');
      await _authService.logout();
      
      _token = null;
      _user = null;
      
      developer.log('Logout successful');
    } catch (e) {
      developer.log('Logout error: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkAuthStatus() async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = _token;
      if (token == null) {
        developer.log('No stored token found');
        return;
      }

      developer.log('Checking auth status with token: $token');
      final user = await _authService.getCurrentUser(token);
      
      if (user != null) {
        _user = user;
        developer.log('Auth check successful, user: ${user.toJson()}');
      } else {
        _token = null;
        _user = null;
        developer.log('Auth check failed, no valid user found');
      }
    } catch (e) {
      developer.log('Auth check error: $e');
      _error = e.toString();
      _token = null;
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchProfile() async {
    try {
      final token = _token;
      if (token == null) {
        _error = 'No auth token available';
        notifyListeners();
        return;
      }

      final response = await http.get(
        Uri.parse(ApiConfig.profileEndpoint),
        headers: ApiConfig.getAuthHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success' && data['data'] != null) {
          _user = User(
            id: _userId ?? '',
            name: data['data']['name'],
            email: data['data']['email'],
            phone: data['data']['phone'],
            address: data['data']['address'] != null
                ? UserAddress(
                    street: data['data']['address']['street'],
                    city: data['data']['address']['city'],
                    postalCode: data['data']['address']['postal_code'],
                  )
                : null,
          );
          _error = '';
        }
      } else if (response.statusCode == 401) {
        _error = 'Session expired. Please login again.';
        _token = null;
        _user = null;
      } else {
        final data = json.decode(response.body);
        _error = data['message'] ?? 'Failed to fetch profile';
      }
    } catch (e) {
      _error = 'An error occurred while fetching profile';
    }
    notifyListeners();
  }

  Future<void> updateProfile({
    required String name,
    String? phone,
    UserAddress? address,
  }) async {
    try {
      final token = _token;
      if (token == null) {
        _error = 'No auth token available';
        notifyListeners();
        return;
      }

      _isLoading = true;
      notifyListeners();

      final response = await http.put(
        Uri.parse(ApiConfig.profileEndpoint),
        headers: ApiConfig.getAuthHeaders(token),
        body: json.encode({
          'name': name,
          'phone': phone,
          'address': address?.toJson(),
        }),
      );

      if (response.statusCode == 200) {
        await fetchProfile(); // Refresh profile after update
      } else if (response.statusCode == 401) {
        _error = 'Session expired. Please login again.';
        _token = null;
        _user = null;
      } else {
        final data = json.decode(response.body);
        _error = data['message'] ?? 'Failed to update profile';
      }
    } catch (e) {
      _error = 'An error occurred while updating profile';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}
