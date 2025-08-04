import 'package:flutter/foundation.dart';
import 'package:financial_literacy_frontend/models/quiz.dart';
import 'package:financial_literacy_frontend/services/api_service.dart';

class Category {
  final String id;
  final String name;
  final String icon;
  final String color;

  Category({required this.id, required this.name, required this.icon, required this.color});
}

class QuizProvider with ChangeNotifier {
  List<Quiz> _quizzes = [];
  Quiz? _currentQuiz;
  int _currentQuestion = 0;
  List<String?> _selectedAnswers = [];
  QuizResult? _quizResult;
  Map<String, dynamic> _userProgress = {
    'totalPoints': 0,
    'completedQuizzes': 0,
    'streak': 0,
    'level': 'Beginner',
    'achievements': [],
  };
  List<dynamic> _leaderboard = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;

  final List<Category> _categories = [
    Category(id: 'investing', name: 'Investing', icon: 'trending-up', color: '#6366f1'),
    Category(id: 'budgeting', name: 'Budgeting', icon: 'account-balance-wallet', color: '#10b981'),
    Category(id: 'debt', name: 'Debt Management', icon: 'warning', color: '#f59e0b'),
    Category(id: 'savings', name: 'Savings', icon: 'savings', color: '#3b82f6'),
  ];

  List<Quiz> get quizzes => _quizzes;
  Quiz? get currentQuiz => _currentQuiz;
  int get currentQuestion => _currentQuestion;
  List<String?> get selectedAnswers => _selectedAnswers;
  QuizResult? get quizResult => _quizResult;
  Map<String, dynamic> get userProgress => _userProgress;
  List<dynamic> get leaderboard => _leaderboard;
  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;

  Question? get currentQuestionData => _currentQuiz?.questions?[_currentQuestion];
  bool get canProceed => _selectedAnswers[_currentQuestion] != null;
  bool get isLastQuestion => _currentQuiz != null && _currentQuestion == _currentQuiz!.questions!.length - 1;

  final ApiService _apiService = ApiService();

  Future<void> fetchQuizzes({String? category, String? difficulty}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      String endpoint = '/quizzes';
      Map<String, dynamic> params = {};
      if (category != null) {
        endpoint = '/quizzes/category/$category';
        if (difficulty != null) params['difficulty'] = difficulty;
      }
      //final response = await _apiService.get(endpoint, params: params);
      //_quizzes = (response as List).map((json) => Quiz.fromJson(json)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchQuizById(int quizId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _apiService.get('/quizzes/$quizId');
      _currentQuiz = Quiz.fromJson(response);
      _selectedAnswers = List<String?>.filled(_currentQuiz!.questions!.length, null);
      _currentQuestion = 0;
      _quizResult = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitQuiz(int quizId) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _apiService.post('/quizzes/$quizId/submit', {
        'answers': _selectedAnswers,
      });
      _quizResult = QuizResult.fromJson(response);
      _userProgress['totalPoints'] += response['score'] ?? 0;
      _userProgress['completedQuizzes'] += 1;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> fetchUserProgress() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _apiService.get('/user/progress');
      _userProgress = response;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchLeaderboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _apiService.get('/quizzes/leaderboard');
      _leaderboard = response;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void startQuiz(Quiz quiz) {
    _currentQuiz = quiz;
    _selectedAnswers = List<String?>.filled(quiz.questions!.length, null);
    _currentQuestion = 0;
    _quizResult = null;
    notifyListeners();
  }

  void selectAnswer(String answer) {
    _selectedAnswers[_currentQuestion] = answer;
    notifyListeners();
  }

  void nextQuestion() {
    if (_currentQuestion < _currentQuiz!.questions!.length - 1) {
      _currentQuestion++;
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (_currentQuestion > 0) {
      _currentQuestion--;
      notifyListeners();
    }
  }

  void resetQuiz() {
    _currentQuiz = null;
    _currentQuestion = 0;
    _selectedAnswers = [];
    _quizResult = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}