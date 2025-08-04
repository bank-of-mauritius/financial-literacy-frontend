import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:financial_literacy_frontend/providers/chatbot_provider.dart';
import 'package:financial_literacy_frontend/styles/colors.dart';
import 'package:financial_literacy_frontend/styles/typography.dart';
import 'package:financial_literacy_frontend/widgets/loading_spinner.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  // Quick action suggestions
  final List<String> quickSuggestions = [
    'What is compound interest?',
    'How to create a budget?',
    'Investment basics',
    'Debt management tips',
    'What is an emergency fund?',
    'How to improve credit score?',
  ];

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _slideController.forward();

    // Check connection and add welcome message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatbotProvider = Provider.of<ChatbotProvider>(context, listen: false);
      chatbotProvider.checkConnection();
      chatbotProvider.addWelcomeMessage();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final chatbotProvider = Provider.of<ChatbotProvider>(context, listen: false);
    chatbotProvider.sendMessage(text.trim());
    _controller.clear();

    // Auto-scroll to bottom after a short delay
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Widget _buildMessagesList(ChatbotProvider chatbotProvider) {
    return Expanded(
      child: chatbotProvider.messages.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: chatbotProvider.messages.length + (chatbotProvider.isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == chatbotProvider.messages.length && chatbotProvider.isLoading) {
            return _buildTypingIndicator();
          }

          final message = chatbotProvider.messages[index];
          return _buildMessageBubble(message, index);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryLight.withOpacity(0.1), AppColors.secondaryLight.withOpacity(0.1)],
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            MdiIcons.chatProcessing,
            color: AppColors.primary,
            size: 40,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Ask me anything about finance!',
          style: AppTypography.h4.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: 8),
        Text(
          'I can help with budgeting, investing, loans, and more',
          style: AppTypography.body2.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        _buildQuickSuggestions(),
      ],
    );
  }

  Widget _buildQuickSuggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Try asking:',
            style: AppTypography.body2.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: quickSuggestions.map((suggestion) {
              return GestureDetector(
                onTap: () => _sendMessage(suggestion),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.accent.withOpacity(0.2)),
                  ),
                  child: Text(
                    suggestion,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(dynamic message, int index) {
    final isUser = message.isUser;
    final isError = message.isError ?? false;
    final isSystemMessage = message.isSystemMessage ?? false;

    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween<Offset>(
        begin: Offset(isUser ? 1 : -1, 0),
        end: Offset.zero,
      ),
      builder: (context, Offset offset, child) {
        return Transform.translate(
          offset: offset * 50,
          child: Opacity(
            opacity: 1 - offset.dx.abs(),
            child: Align(
              alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.8,
                ),
                decoration: BoxDecoration(
                  gradient: isUser
                      ? LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                  )
                      : null,
                  color: isUser
                      ? null
                      : isError
                      ? AppColors.errorLight
                      : isSystemMessage
                      ? AppColors.secondaryLight.withOpacity(0.1)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(18).copyWith(
                    bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(18),
                    bottomLeft: isUser ? const Radius.circular(18) : const Radius.circular(4),
                  ),
                  border: isError
                      ? Border.all(color: AppColors.error)
                      : isSystemMessage
                      ? Border.all(color: AppColors.secondaryLight.withOpacity(0.3))
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: isUser
                          ? AppColors.primary.withOpacity(0.2)
                          : AppColors.gray.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isUser)
                      Row(
                        children: [
                          Icon(
                            isError
                                ? Icons.error_outline
                                : isSystemMessage
                                ? MdiIcons.information
                                : MdiIcons.robot,
                            color: isError
                                ? AppColors.error
                                : isSystemMessage
                                ? AppColors.secondary
                                : AppColors.primary,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isError
                                ? 'Error'
                                : isSystemMessage
                                ? 'System'
                                : 'AI Assistant',
                            style: AppTypography.caption.copyWith(
                              color: isError
                                  ? AppColors.error
                                  : isSystemMessage
                                  ? AppColors.secondary
                                  : AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    if (!isUser) const SizedBox(height: 4),
                    Text(
                      message.text,
                      style: AppTypography.body1.copyWith(
                        color: isUser
                            ? AppColors.white
                            : isError
                            ? AppColors.error
                            : AppColors.text,
                        height: 1.4,
                      ),
                    ),
                    // Show confidence score for AI messages
                    if (!isUser && message.confidenceScore != null && !isError && !isSystemMessage)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.analytics_outlined,
                              size: 12,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Confidence: ${(message.confidenceScore * 100).toInt()}%',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18).copyWith(
            bottomLeft: const Radius.circular(4),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.gray.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              MdiIcons.robot,
              color: AppColors.primary,
              size: 14,
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 40,
              height: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(3, (index) {
                  return TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 600),
                    tween: Tween<double>(begin: 0.3, end: 1.0),
                    builder: (context, value, child) {
                      return AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          final delay = index * 0.2;
                          final animValue = (_pulseController.value + delay) % 1.0;
                          return Opacity(
                            opacity: 0.3 + (0.7 * animValue),
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.accent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection(ChatbotProvider chatbotProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.gray.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            if (chatbotProvider.error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.error),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        chatbotProvider.error!,
                        style: AppTypography.caption.copyWith(color: AppColors.error),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        chatbotProvider.clearError();
                        chatbotProvider.retryLastMessage();
                      },
                      child: Text(
                        'Retry',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: TextField(
                      controller: _controller,
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      enabled: !chatbotProvider.isLoading,
                      onSubmitted: (text) {
                        if (text.trim().isNotEmpty && chatbotProvider.isConnected) {
                          _sendMessage(text.trim());
                        }
                      },
                      onChanged: (value) {
                        // Force rebuild to update button state
                        setState(() {});
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.secondary, AppColors.secondaryLight],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () {
                      // Debug print to check conditions
                      if (_controller.text.trim().isNotEmpty &&
                          !chatbotProvider.isLoading &&
                          chatbotProvider.isConnected) {
                        _sendMessage(_controller.text.trim());
                      } else {
                        if (kDebugMode) {
                          print('Send button disabled due to conditions not met');
                        }
                      }
                    },
                    icon: Icon(
                      chatbotProvider.isLoading
                          ? MdiIcons.loading
                          : !chatbotProvider.isConnected
                          ? Icons.wifi_off
                          : Icons.send,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ChatbotProvider chatbotProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryLight,
          ],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            // Header content
            Row(
              children: [
                // AI Avatar with pulse animation
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.secondary, AppColors.secondaryLight],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.secondary.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          MdiIcons.robot,
                          color: AppColors.white,
                          size: 20,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Finance AI Assistant',
                        style: AppTypography.h4.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: chatbotProvider.isConnected ? AppColors.success : AppColors.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            chatbotProvider.isConnected ? 'Online' : 'Offline',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Retry connection button
                if (!chatbotProvider.isConnected)
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.refresh, color: AppColors.white),
                      onPressed: () => chatbotProvider.checkConnection(),
                    ),
                  ),
                const SizedBox(width: 8),
                // Close button
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: AppColors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatbotProvider = Provider.of<ChatbotProvider>(context);

    return SlideTransition(
      position: _slideAnimation,
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: AppColors.gray.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildHeader(chatbotProvider),
              _buildMessagesList(chatbotProvider),
              _buildInputSection(chatbotProvider),
            ],
          ),
        ),
      ),
    );
  }
}