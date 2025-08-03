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
    required this.timeLimit,
    required this.points,
    required this.questionCount,
    this.questions,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      difficulty: json['difficulty'],
      timeLimit: json['timeLimit'],
      points: json['points'],
      questionCount: json['questionCount'],
      questions: json['questions'] != null
          ? (json['questions'] as List).map((q) => Question.fromJson(q)).toList()
          : null,
    );
  }
}

class Question {
  final String text;
  final List<String> options;

  Question({required this.text, required this.options});

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      text: json['text'],
      options: List<String>.from(json['options']),
    );
  }
}

class QuizResult {
  final int score;
  final int total;
  final String message;

  QuizResult({required this.score, required this.total, required this.message});

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      score: json['score'],
      total: json['total'],
      message: json['message'],
    );
  }
}