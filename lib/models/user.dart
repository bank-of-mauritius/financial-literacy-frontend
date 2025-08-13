class User {
  final String id;
  final String name;
  final String email;
  final String level;
  final int totalPoints;
  final int completedQuizzes;
  final int streak;
  final String joinDate;
  final DateTime? lastActivityDate;

  User({
    required this.id,  // Now required
    required this.name,
    required this.email,
    required this.level,
    required this.totalPoints,
    required this.completedQuizzes,
    required this.streak,
    required this.joinDate,
    this.lastActivityDate,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',  // Handle backend user ID
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      level: json['level']?.toString() ?? 'Beginner',  // Provide default
      totalPoints: json['totalPoints'] ?? json['total_points'] ?? 0,
      completedQuizzes: json['completedQuizzes'] ?? json['completed_quizzes'] ?? 0,
      streak: json['streak'] ?? json['learningStreak'] ?? json['learning_streak'] ?? 0,
      joinDate: json['joinDate']?.toString() ?? json['join_date']?.toString() ?? DateTime.now().toIso8601String().split('T')[0],
      lastActivityDate: json['lastActivityDate'] != null || json['last_activity_date'] != null
          ? DateTime.tryParse(json['lastActivityDate']?.toString() ?? json['last_activity_date']?.toString() ?? '')
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'level': level,
      'totalPoints': totalPoints,
      'completedQuizzes': completedQuizzes,
      'streak': streak,
      'joinDate': joinDate,
      'lastActivityDate': lastActivityDate?.toIso8601String(),
    };
  }
}

class Achievement {
  final int id;
  final String title;
  final String description;
  final String icon;
  final bool earned;
  final int points;
  final String color;
  final DateTime? earnedAt;  // Added to match backend
  final Map<String, dynamic>? criteria;  // Added to match backend

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.earned,
    required this.points,
    required this.color,
    this.earnedAt,
    this.criteria,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '',
      earned: json['earned'] ?? false,
      points: json['points'] ?? 0,
      color: json['color']?.toString() ?? '#000000',
      earnedAt: json['earnedAt']?.toString() != null || json['earned_at']?.toString() != null
          ? DateTime.tryParse(json['earnedAt']?.toString() ?? json['earned_at']?.toString() ?? '')
          : null,
      criteria: json['criteria'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'earned': earned,
      'points': points,
      'color': color,
      'earnedAt': earnedAt?.toIso8601String(),
      'criteria': criteria,
    };
  }
}

class Activity {
  final int id;
  final String type;
  final String title;
  final int points;
  final DateTime date;  // Changed to DateTime for better handling
  final String icon;

  Activity({
    required this.id,
    required this.type,
    required this.title,
    required this.points,
    required this.date,
    required this.icon,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] ?? 0,
      type: json['type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      points: json['points'] ?? 0,
      date: json['date'] != null
          ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      icon: json['icon']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'points': points,
      'date': date.toIso8601String(),
      'icon': icon,
    };
  }
}

// New LeaderboardEntry class to match backend response
class LeaderboardEntry {
  final String userId;
  final String name;
  final int totalPoints;
  final String level;

  LeaderboardEntry({
    required this.userId,
    required this.name,
    required this.totalPoints,
    required this.level,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      userId: json['userId']?.toString() ?? json['user_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      totalPoints: json['totalPoints'] ?? json['total_points'] ?? 0,
      level: json['level']?.toString() ?? 'Beginner',
    );
  }
}

// User stats for gamification
class UserStats {
  final int totalPoints;
  final int learningStreak;
  final int completedQuizzes;
  final String level;
  final DateTime? lastActivityDate;

  UserStats({
    required this.totalPoints,
    required this.learningStreak,
    required this.completedQuizzes,
    required this.level,
    this.lastActivityDate,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalPoints: json['totalPoints'] ?? json['total_points'] ?? 0,
      learningStreak: json['learningStreak'] ?? json['learning_streak'] ?? 0,
      completedQuizzes: json['completedQuizzes'] ?? json['completed_quizzes'] ?? 0,
      level: json['level']?.toString() ?? 'Beginner',
      lastActivityDate: json['lastActivityDate']?.toString() != null || json['last_activity_date']?.toString() != null
          ? DateTime.tryParse(json['lastActivityDate']?.toString() ?? json['last_activity_date']?.toString() ?? '')
          : null,
    );
  }
}