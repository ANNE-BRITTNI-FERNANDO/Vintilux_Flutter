import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  // Use HTTP for development
  static const String _baseUrl = 'http://16.171.152.57/api';
  static const int _timeout = 30; // increased timeout
  
  final String? authToken;
  
  ApiService({this.authToken});

  Future<Map<String, dynamic>> placeOrder(Map<String, dynamic> orderData) async {
    try {
      // Create a custom HTTP client
      final httpClient = HttpClient()
        ..connectionTimeout = const Duration(seconds: _timeout)
        ..badCertificateCallback = ((X509Certificate cert, String host, int port) => true);

      final request = await httpClient.postUrl(Uri.parse('$_baseUrl/orders'));
      
      // Add headers
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Accept', 'application/json');
      if (authToken != null) {
        request.headers.set('Authorization', 'Bearer $authToken');
      }

      // Add body
      request.write(json.encode(orderData));
      
      if (kDebugMode) {
        print('Sending request to: $_baseUrl/orders');
        print('Request headers: ${request.headers}');
        print('Request body: $orderData');
      }

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      if (kDebugMode) {
        print('Response status: ${response.statusCode}');
        print('Response body: $responseBody');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(responseBody);
      } else {
        throw Exception('Server error: ${response.statusCode}. Response: $responseBody');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error placing order: $e');
      }
      throw Exception('Failed to connect to server: $e');
    }
  }

  Future<List<dynamic>> getOrders() async {
    try {
      // Create a custom HTTP client
      final httpClient = HttpClient()
        ..connectionTimeout = const Duration(seconds: _timeout)
        ..badCertificateCallback = ((X509Certificate cert, String host, int port) => true);

      final request = await httpClient.getUrl(Uri.parse('$_baseUrl/orders'));
      
      // Add headers
      request.headers.set('Accept', 'application/json');
      if (authToken != null) {
        request.headers.set('Authorization', 'Bearer $authToken');
      }

      if (kDebugMode) {
        print('Sending request to: $_baseUrl/orders');
        print('Request headers: ${request.headers}');
      }

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      if (kDebugMode) {
        print('Response status: ${response.statusCode}');
        print('Response body: $responseBody');
      }

      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        return data['data'] as List;
      } else {
        throw Exception('Server error: ${response.statusCode}. Response: $responseBody');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching orders: $e');
      }
      throw Exception('Failed to connect to server: $e');
    }
  }
}
