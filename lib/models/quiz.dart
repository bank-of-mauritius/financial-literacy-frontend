import 'dart:convert';

class Quiz {
  final int id;
  final String title;
  final String description;
  final String category;
  final String difficulty;
  final int timeLimit;
  final int points;
  final int questionCount;
  final List<Question>? questions;

  Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    this.timeLimit = 0,  // Default value
    this.points = 0,     // Default value
    this.questionCount = 0,  // Default value
    this.questions,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'] ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      difficulty: json['difficulty']?.toString() ?? '',
      timeLimit: json['timeLimit'] ?? json['time_limit'] ?? 0,
      points: json['points'] ?? 0,
      questionCount: json['questionCount'] ?? json['question_count'] ?? 0,
      questions: json['questions'] != null
          ? (json['questions'] as List).map((q) => Question.fromJson(q)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'difficulty': difficulty,
      'timeLimit': timeLimit,
      'points': points,
      'questionCount': questionCount,
      'questions': questions?.map((q) => q.toJson()).toList(),
    };
  }
}

class Question {
  final int? id;  // Added id field to match backend
  final String text;
  final List<String> options;
  final String? correctAnswer;  // Added for backend compatibility

  Question({
    this.id,
    required this.text,
    required this.options,
    this.correctAnswer,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    List<String> parsedOptions = [];

    // Handle different formats of options from backend
    if (json['options'] != null) {
      if (json['options'] is String) {
        // If options is a JSON string, parse it
        try {
          final decoded = jsonDecode(json['options'] as String);
          if (decoded is List) {
            parsedOptions = decoded.map((e) => e.toString()).toList();
          }
        } catch (e) {
          print('Error parsing options JSON: $e');
          parsedOptions = [];
        }
      } else if (json['options'] is List) {
        // If options is already a list
        parsedOptions = (json['options'] as List).map((e) => e.toString()).toList();
      }
    }

    return Question(
      id: json['id'],
      text: json['text']?.toString() ?? '',
      options: parsedOptions,
      correctAnswer: json['correctAnswer']?.toString() ?? json['correct_answer']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'options': options,
      'correctAnswer': correctAnswer,
    };
  }
}

class QuizResult {
  final int score;
  final int total;
  final String message;
  final bool? passed;  // Added for backend compatibility
  final DateTime? completedAt;  // Added timestamp
  final double? percentage;  // Added for quiz_provider compatibility

  QuizResult({
    required this.score,
    required this.total,
    required this.message,
    this.passed,
    this.completedAt,
    this.percentage,
  });

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      score: json['score'] ?? 0,
      total: json['total'] ?? 0,
      message: json['message']?.toString() ?? '',
      passed: json['passed'],
      percentage: json['percentage']?.toDouble(),
      completedAt: json['completedAt']?.toString() != null || json['completed_at']?.toString() != null
          ? DateTime.tryParse(json['completedAt']?.toString() ?? json['completed_at']?.toString() ?? '')
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'total': total,
      'message': message,
      'passed': passed,
      'percentage': percentage,
      'completedAt': completedAt?.toIso8601String(),
    };
  }
}