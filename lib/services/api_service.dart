import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:financial_literacy_frontend/models/quiz.dart';
import 'package:financial_literacy_frontend/models/user.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.64.1:8080/api';
  static const String fmpBaseUrl = 'https://financialmodelingprep.com/api';
  static const String fmpApiKey = 'MhJK8Ox8Mt5cDicSUMU6JDDcxX7LBUGE'; // Replace with your Financial Modeling Prep API key

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String endpoint, {Map<String, String>? params, bool isFmp = false}) async {
    try {
      final base = isFmp ? fmpBaseUrl : baseUrl;
      final uri = Uri.parse('$base$endpoint').replace(
        queryParameters: {
          if (isFmp) 'apikey': fmpApiKey,
          ...?params,
        },
      );
      final Map<String, String>? headers = isFmp ? {} : await _getHeaders();

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded.containsKey('error')) {
          throw Exception('API Error: ${decoded['error']}');
        }
        if (decoded is Map && decoded.isEmpty) {
          throw Exception('Empty response from API');
        }
        return decoded;
      } else {
        throw Exception('Failed to fetch: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<dynamic> post(String endpoint, dynamic data) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl$endpoint');

      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to post: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<dynamic> put(String endpoint, dynamic data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to put: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Chatbot-specific method
  Future<Map<String, dynamic>> sendChatMessage(String message, {String? userId}) async {
    try {
      final data = {
        'message': message,
        'user_id': userId ?? 'anonymous',
      };

      final response = await post('/chatbot', data);
      return response;
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  // Health check method
  Future<Map<String, dynamic>> checkHealth() async {
    try {
      return await get('/health');
    } catch (e) {
      throw Exception('Service unavailable: $e');
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

  // Fetch market data for multiple symbols (US stocks only)
  Future<List<dynamic>> fetchMarketData(String symbols) async {
    return await get('/v3/quote/$symbols', isFmp: true);
  }
}