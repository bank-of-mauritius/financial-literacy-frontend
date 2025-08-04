import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:financial_literacy_frontend/models/chatbot_message.dart';
import 'package:financial_literacy_frontend/services/api_service.dart';

class ChatbotProvider with ChangeNotifier {
  List<ChatbotMessage> _messages = [];
  bool _isLoading = false;
  String? _error;
  bool _isConnected = false;

  List<ChatbotMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isConnected => _isConnected;

  final ApiService _apiService = ApiService();

  // Check connection to backend
  Future<void> checkConnection() async {
    try {
      await _apiService.checkHealth();
      _isConnected = true;
      _error = null;
    } catch (e) {
      _isConnected = false;
      _error = 'Unable to connect to service';
    }
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message immediately
    final userMessage = ChatbotMessage(
      id: const Uuid().v4(),
      text: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );

    _messages.add(userMessage);
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Send message to backend
      final response = await _apiService.sendChatMessage(text.trim());

      // Check if response is successful
      if (response['success'] == true) {
        final botMessage = ChatbotMessage(
          id: const Uuid().v4(),
          text: response['response'] ?? 'I received your message but couldn\'t generate a response.',
          isUser: false,
          timestamp: DateTime.now(),
          confidenceScore: response['confidenceScore']?.toDouble(),
        );
        _messages.add(botMessage);

        // Handle low confidence suggestions
        if (response['suggestTicket'] == true) {
          final suggestionMessage = ChatbotMessage(
            id: const Uuid().v4(),
            text: '💡 Would you like me to help you find more specific information about this topic?',
            isUser: false,
            timestamp: DateTime.now(),
            isSystemMessage: true,
          );
          _messages.add(suggestionMessage);
        }
      } else {
        // Handle API error response
        final errorMessage = ChatbotMessage(
          id: const Uuid().v4(),
          text: response['error'] ?? 'Sorry, I encountered an error processing your request.',
          isUser: false,
          timestamp: DateTime.now(),
          isError: true,
        );
        _messages.add(errorMessage);
      }

    } catch (e) {
      _error = 'Failed to get response. Please check your connection.';

      // Add error message to chat
      final errorMessage = ChatbotMessage(
        id: const Uuid().v4(),
        text: 'Sorry, I\'m having trouble connecting right now. Please try again in a moment.',
        isUser: false,
        timestamp: DateTime.now(),
        isError: true,
      );
      _messages.add(errorMessage);
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

  // Add welcome message
  void addWelcomeMessage() {
    if (_messages.isEmpty) {
      final welcomeMessage = ChatbotMessage(
        id: const Uuid().v4(),
        text: 'Hello! I\'m your financial literacy assistant. I can help you with budgeting, investing, loans, savings, and other financial topics. What would you like to learn about today?',
        isUser: false,
        timestamp: DateTime.now(),
        isSystemMessage: true,
      );
      _messages.add(welcomeMessage);
      notifyListeners();
    }
  }

  // Retry last message
  void retryLastMessage() {
    if (_messages.isNotEmpty) {
      // Find the last user message
      for (int i = _messages.length - 1; i >= 0; i--) {
        if (_messages[i].isUser) {
          sendMessage(_messages[i].text);
          break;
        }
      }
    }
  }
}