import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';
import '../models/user_model.dart';

class LoginResult {
  final User user;
  final String token;

  LoginResult({required this.user, required this.token});
}

class AuthService {
  final storage = const FlutterSecureStorage();

  Future<User?> getCurrentUser(String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.profileEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      developer.log('Get current user response status: ${response.statusCode}');
      developer.log('Get current user response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['user'] != null) {
          return User.fromJson(data['user']);
        }
      }
      return null;
    } catch (e) {
      developer.log('Error getting current user: $e');
      return null;
    }
  }

  Future<LoginResult> login(String email, String password) async {
    try {
      final url = Uri.parse(ApiConfig.loginEndpoint);
      developer.log('Attempting login to: $url');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      developer.log('Login response status: ${response.statusCode}');
      developer.log('Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final token = data['access_token'] as String;
        developer.log('Received token: $token');
        
        await storage.write(key: 'token', value: token);
        developer.log('Stored token in secure storage');

        if (data['user'] != null) {
          final userJson = Map<String, dynamic>.from(data['user']);
          final user = User.fromJson(userJson);
          return LoginResult(user: user, token: token);
        } else {
          throw Exception('Invalid response format: missing user data');
        }
      } else {
        final Map<String, dynamic> data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Login failed');
      }
    } catch (e) {
      developer.log('Login error: $e');
      rethrow;
    }
  }

  Future<LoginResult> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.registerEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      developer.log('Register response status: ${response.statusCode}');
      developer.log('Register response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final token = data['access_token'] as String;
        developer.log('Received token: $token');
        
        await storage.write(key: 'token', value: token);
        developer.log('Stored token in secure storage');

        if (data['user'] != null) {
          final userJson = Map<String, dynamic>.from(data['user']);
          final user = User.fromJson(userJson);
          return LoginResult(user: user, token: token);
        } else {
          throw Exception('Invalid response format: missing user data');
        }
      } else {
        final Map<String, dynamic> data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Registration failed');
      }
    } catch (e) {
      developer.log('Registration error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await storage.delete(key: 'token');
      developer.log('Token removed from secure storage');
    } catch (e) {
      developer.log('Error during logout: $e');
      rethrow;
    }
  }
}
