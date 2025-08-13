import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:financial_literacy_frontend/models/quiz.dart';
import 'package:financial_literacy_frontend/models/user.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.64.1:8080/api';

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
      throw Exception('Failed to fetch: ${response.statusCode} ${response.reasonPhrase}');
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
      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      }
      return null; // For endpoints that return no content
    } else {
      throw Exception('Failed to post: ${response.statusCode} ${response.reasonPhrase}');
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
      throw Exception('Failed to put: ${response.statusCode} ${response.reasonPhrase}');
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
      return response ?? {'success': false, 'error': 'No response from server'};
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  Future<Map<String, dynamic>> checkHealth() async {
    try {
      return await get('/health') ?? {'status': 'unknown'};
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

  // Helper method to get current user ID
  Future<String?> getCurrentUserId() async {
    final user = await loadStoredUser();
    return user?.id;
  }

  // Gamification APIs
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    return await get('/users/$userId/stats');
  }

  Future<List<dynamic>> getUserAchievements(String userId) async {
    return await get('/users/$userId/achievements');
  }

  Future<void> awardAchievement(String userId, int achievementId) async {
    await post('/users/$userId/achievements', {'achievementId': achievementId});
  }

  Future<List<dynamic>> getUserActivities(String userId) async {
    return await get('/users/$userId/activities');
  }

  Future<void> logActivity(String userId, Map<String, dynamic> activity) async {
    await post('/users/$userId/activities', activity);
  }

  // Updated to match backend expectations
  Future<void> submitQuizResult(String userId, int quizId, int score, int total) async {
    await post('/users/$userId/quiz-results', {
      'quizId': quizId,
      'score': score,
      'total': total,
    });
  }

  // New method for quiz submission with answers (matches QuizProvider usage)
  Future<Map<String, dynamic>> submitQuiz(int quizId, List<String?> answers, {String? userId}) async {
    userId ??= await getCurrentUserId();
    if (userId == null) throw Exception('User not authenticated');

    final response = await post('/quizzes/$quizId/submit', {
      'answers': answers,
      'userId': userId,
    });
    return response ?? {'score': 0, 'total': answers.length, 'message': 'Quiz submitted'};
  }

  Future<List<Quiz>> getAllQuizzes() async {
    final data = await get('/quizzes');
    return (data as List).map((json) => Quiz.fromJson(json)).toList();
  }

  // New method to get quizzes by category (used in QuizProvider)
  Future<List<Quiz>> getQuizzesByCategory(String category, {String? difficulty}) async {
    String endpoint = '/quizzes/category/$category';
    Map<String, dynamic>? params = difficulty != null ? {'difficulty': difficulty} : null;
    final data = await get(endpoint, params: params);
    return (data as List).map((json) => Quiz.fromJson(json)).toList();
  }

  Future<Quiz> getQuizById(int quizId) async {
    final data = await get('/quizzes/$quizId');
    return Quiz.fromJson(data);
  }

  Future<void> submitAnswer(String userId, int quizId, int questionId, String selectedAnswer) async {
    await post('/users/$userId/quizzes/$quizId/answers', {
      'questionId': questionId,
      'selectedAnswer': selectedAnswer,
    });
  }

  // New methods to match QuizProvider expectations
  Future<Map<String, dynamic>> getUserProgress({String? userId}) async {
    userId ??= await getCurrentUserId();
    if (userId == null) throw Exception('User not authenticated');

    Map<String, dynamic>? params = {'userId': userId};
    return await get('/user/progress', params: params);
  }

  Future<List<dynamic>> getLeaderboard() async {
    return await get('/quizzes/leaderboard');
  }

  // Method to get quizzes with optional filters
  Future<List<Quiz>> getQuizzes({String? category, String? difficulty}) async {
    if (category != null) {
      return await getQuizzesByCategory(category, difficulty: difficulty);
    } else {
      return await getAllQuizzes();
    }
  }
}