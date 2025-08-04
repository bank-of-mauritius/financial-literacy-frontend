class ChatbotMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final double? confidenceScore;
  final bool isSystemMessage;
  final bool isError;

  ChatbotMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.confidenceScore,
    this.isSystemMessage = false,
    this.isError = false,
  });

  factory ChatbotMessage.fromJson(Map<String, dynamic> json) {
    return ChatbotMessage(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      isUser: json['isUser'] ?? false,
      timestamp: DateTime.parse(json['timestamp']),
      confidenceScore: json['confidenceScore']?.toDouble(),
      isSystemMessage: json['isSystemMessage'] ?? false,
      isError: json['isError'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'confidenceScore': confidenceScore,
      'isSystemMessage': isSystemMessage,
      'isError': isError,
    };
  }

  ChatbotMessage copyWith({
    String? id,
    String? text,
    bool? isUser,
    DateTime? timestamp,
    double? confidenceScore,
    bool? isSystemMessage,
    bool? isError,
  }) {
    return ChatbotMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      isSystemMessage: isSystemMessage ?? this.isSystemMessage,
      isError: isError ?? this.isError,
    );
  }
}