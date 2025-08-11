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
  final List<Quiz> _quizzes = [];
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
      final quizzes = await _apiService.getQuizzes(category: category, difficulty: difficulty);
      _quizzes.clear();
      _quizzes.addAll(quizzes);
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error fetching quizzes: $e');
      }
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
      final quiz = await _apiService.getQuizById(quizId);
      _currentQuiz = quiz;
      _selectedAnswers = List<String?>.filled(quiz.questions?.length ?? 0, null);
      _currentQuestion = 0;
      _quizResult = null;
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error fetching quiz: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitQuiz(int quizId) async {
    if (_currentQuiz == null) {
      _error = 'No quiz loaded';
      notifyListeners();
      return;
    }

    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.submitQuiz(quizId, _selectedAnswers);

      // Create QuizResult from response - now using the unified QuizResult class
      _quizResult = QuizResult(
        score: response['score'] ?? 0,
        total: response['total'] ?? _selectedAnswers.length,
        message: response['message'] ?? 'Quiz completed!',
        percentage: response['percentage']?.toDouble() ??
            ((response['score'] ?? 0) / (response['total'] ?? 1) * 100),
        passed: response['passed'] ?? ((response['score'] ?? 0) >= (response['total'] ?? 1) * 0.6),
      );

      // Update user progress
      if (response['score'] != null) {
        _userProgress['totalPoints'] = (_userProgress['totalPoints'] ?? 0) + response['score'];
        _userProgress['completedQuizzes'] = (_userProgress['completedQuizzes'] ?? 0) + 1;
      }

      if (kDebugMode) {
        print('Quiz submitted successfully: ${response['score']}/${response['total']}');
      }
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error submitting quiz: $e');
      }
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
      final response = await _apiService.getUserProgress();
      _userProgress = response;
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error fetching user progress: $e');
      }
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
      final response = await _apiService.getLeaderboard();
      _leaderboard = response;
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error fetching leaderboard: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void startQuiz(Quiz quiz) {
    _currentQuiz = quiz;
    _selectedAnswers = List<String?>.filled(quiz.questions?.length ?? 0, null);
    _currentQuestion = 0;
    _quizResult = null;
    _error = null;
    notifyListeners();
  }

  void selectAnswer(String answer) {
    if (_currentQuestion >= 0 && _currentQuestion < _selectedAnswers.length) {
      _selectedAnswers[_currentQuestion] = answer;
      notifyListeners();
    }
  }

  void nextQuestion() {
    if (_currentQuiz != null && _currentQuestion < _currentQuiz!.questions!.length - 1) {
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
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Initialize with sample data if needed
  void initializeSampleData() {
    if (_quizzes.isEmpty) {
      // Add some sample quizzes for testing
      // This can be removed once backend is fully connected
      if (kDebugMode) {
        print('Initializing sample quiz data');
      }
    }
  }
}