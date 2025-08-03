import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:financial_literacy_frontend/models/chatbot_message.dart';
import 'package:financial_literacy_frontend/services/api_service.dart';

class ChatbotProvider with ChangeNotifier {
  List<ChatbotMessage> _messages = [];
  bool _isLoading = false;
  String? _error;

  List<ChatbotMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final ApiService _apiService = ApiService();

  Future<void> sendMessage(String text) async {
    final userMessage = ChatbotMessage(
      id: const Uuid().v4(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    _messages.add(userMessage);
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.post('/chatbot', {'message': text});
      final botMessage = ChatbotMessage(
        id: const Uuid().v4(),
        text: response['response'] ?? 'I can help with financial questions! Ask away.',
        isUser: false,
        timestamp: DateTime.now(),
      );
      _messages.add(botMessage);
    } catch (e) {
      _error = 'Failed to get response: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    _messages = [];
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}