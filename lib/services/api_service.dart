import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:financial_literacy_frontend/models/quiz.dart';
import 'package:financial_literacy_frontend/models/user.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080/api'; // Update with your backend URL

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String endpoint, {Map<String, dynamic>? params}) async {
    final uri = Uri.parse('$baseUrl$endpoint').replace(queryParameters: params?.map((k, v) => MapEntry(k, v.toString())));
    final headers = await _getHeaders();
    final response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch: ${response.reasonPhrase}');
    }
  }

  Future<dynamic> post(String endpoint, dynamic data) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to post: ${response.reasonPhrase}');
    }
  }

  Future<dynamic> put(String endpoint, dynamic data) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to put: ${response.reasonPhrase}');
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await post('/auth/login', {'email': email, 'password': password});
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', response['token']);
    await prefs.setString('user', jsonEncode(response['user']));
    return response;
  }

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final response = await post('/auth/register', {'name': name, 'email': email, 'password': password});
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', response['token']);
    await prefs.setString('user', jsonEncode(response['user']));
    return response;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    await prefs.remove('user');
  }

  Future<User?> loadStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }
}