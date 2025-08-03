class User {
  final String name;
  final String email;
  final String level;
  final int totalPoints;
  final int completedQuizzes;
  final int streak;
  final String joinDate;

  User({
    required this.name,
    required this.email,
    required this.level,
    required this.totalPoints,
    required this.completedQuizzes,
    required this.streak,
    required this.joinDate,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      email: json['email'],
      level: json['level'] ?? 'Beginner',
      totalPoints: json['totalPoints'] ?? 0,
      completedQuizzes: json['completedQuizzes'] ?? 0,
      streak: json['streak'] ?? 0,
      joinDate: json['joinDate'] ?? DateTime.now().toIso8601String(),
    );
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

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.earned,
    required this.points,
    required this.color,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      icon: json['icon'],
      earned: json['earned'],
      points: json['points'],
      color: json['color'],
    );
  }
}

class Activity {
  final int id;
  final String type;
  final String title;
  final int points;
  final String date;
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
      id: json['id'],
      type: json['type'],
      title: json['title'],
      points: json['points'],
      date: json['date'],
      icon: json['icon'],
    );
  }
}