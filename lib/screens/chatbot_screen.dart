import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:financial_literacy_frontend/providers/chatbot_provider.dart';
import 'package:financial_literacy_frontend/styles/colors.dart';
import 'package:financial_literacy_frontend/styles/typography.dart';

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
  late AnimationController _typingController;
  late AnimationController _fabController;

  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fabScaleAnimation;

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
    _initializeAnimations();
    _setupChatbot();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _typingController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _fabScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabController,
      curve: Curves.elasticOut,
    ));

    _slideController.forward();
    _pulseController.repeat(reverse: true);
    _fabController.forward();
  }

  void _setupChatbot() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatbotProvider = Provider.of<ChatbotProvider>(
          context, listen: false);
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
    _typingController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text
        .trim()
        .isEmpty) return;

    final chatbotProvider = Provider.of<ChatbotProvider>(
        context, listen: false);
    chatbotProvider.sendMessage(text.trim());
    _controller.clear();

    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Widget _buildModernHeader(ChatbotProvider chatbotProvider) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryLight,
            AppColors.primaryDark,
          ],
          stops: [0.0, 0.7, 1.0],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Drag handle with animation
            TweenAnimationBuilder(
              duration: const Duration(milliseconds: 600),
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                );
              },
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Row(
                children: [
                  // AI Avatar with enhanced animation
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.secondary,
                                AppColors.secondaryLight
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.secondary.withOpacity(0.4),
                                blurRadius: 16,
                                spreadRadius: 2,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.smart_toy_rounded,
                            color: AppColors.white,
                            size: 24,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(width: 16),

                  // Header text with stagger animation
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TweenAnimationBuilder(
                          duration: const Duration(milliseconds: 800),
                          tween: Tween<double>(begin: 0, end: 1),
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(-30 * (1 - value), 0),
                              child: Opacity(
                                opacity: value,
                                child: Text(
                                  'Finance AI Assistant',
                                  style: AppTypography.h4.copyWith(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        TweenAnimationBuilder(
                          duration: const Duration(milliseconds: 1000),
                          tween: Tween<double>(begin: 0, end: 1),
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(-20 * (1 - value), 0),
                              child: Opacity(
                                opacity: value,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: chatbotProvider.isConnected
                                            ? AppColors.success
                                            : AppColors.error,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: (chatbotProvider.isConnected
                                                ? AppColors.success
                                                : AppColors.error).withOpacity(
                                                0.5),
                                            blurRadius: 6,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      chatbotProvider.isConnected
                                          ? 'Online'
                                          : 'Offline',
                                      style: AppTypography.caption.copyWith(
                                        color: AppColors.white.withOpacity(0.9),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // Action buttons with enhanced styling
                  Row(
                    children: [
                      if (!chatbotProvider.isConnected)
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.white.withOpacity(0.2),
                            ),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.refresh_rounded,
                                color: AppColors.white),
                            onPressed: () => chatbotProvider.checkConnection(),
                            tooltip: 'Retry connection',
                          ),
                        ),

                      const SizedBox(width: 8),

                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.white.withOpacity(0.2),
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.close_rounded, color: AppColors
                              .white),
                          onPressed: () => Navigator.pop(context),
                          tooltip: 'Close chat',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList(ChatbotProvider chatbotProvider) {
    return Expanded(
      child: chatbotProvider.messages.isEmpty
          ? _buildModernEmptyState()
          : ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        itemCount: chatbotProvider.messages.length +
            (chatbotProvider.isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == chatbotProvider.messages.length &&
              chatbotProvider.isLoading) {
            return _buildModernTypingIndicator();
          }

          final message = chatbotProvider.messages[index];
          return _buildModernMessageBubble(message, index);
        },
      ),
    );
  }

  Widget _buildModernEmptyState() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),

          // Animated icon
          TweenAnimationBuilder(
            duration: const Duration(milliseconds: 1200),
            tween: Tween<double>(begin: 0, end: 1),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryLight.withOpacity(0.1),
                        AppColors.secondaryLight.withOpacity(0.1)
                      ],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.1),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: AppColors.primary,
                    size: 48,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Welcome text with stagger animation
          TweenAnimationBuilder(
            duration: const Duration(milliseconds: 800),
            tween: Tween<double>(begin: 0, end: 1),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 30 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: Text(
                    'Ask me anything about finance!',
                    style: AppTypography.h4.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          TweenAnimationBuilder(
            duration: const Duration(milliseconds: 1000),
            tween: Tween<double>(begin: 0, end: 1),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'I can help with budgeting, investing, loans, and more',
                      style: AppTypography.body2.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 40),
          _buildModernQuickSuggestions(),
        ],
      ),
    );
  }

  Widget _buildModernQuickSuggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TweenAnimationBuilder(
            duration: const Duration(milliseconds: 1200),
            tween: Tween<double>(begin: 0, end: 1),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(-20 * (1 - value), 0),
                child: Opacity(
                  opacity: value,
                  child: Text(
                    'Try asking:',
                    style: AppTypography.body1.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: quickSuggestions
                .asMap()
                .entries
                .map((entry) {
              final index = entry.key;
              final suggestion = entry.value;

              return TweenAnimationBuilder(
                duration: Duration(milliseconds: 1400 + (index * 100)),
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _sendMessage(suggestion),
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppColors.accent.withOpacity(0.2),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            suggestion,
                            style: AppTypography.body2.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildModernMessageBubble(dynamic message, int index) {
    final isUser = message.isUser;
    final isError = message.isError ?? false;
    final isSystemMessage = message.isSystemMessage ?? false;

    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 400 + (index * 50)),
      tween: Tween<Offset>(
        begin: Offset(isUser ? 1 : -1, 0),
        end: Offset.zero,
      ),
      curve: Curves.easeOutCubic,
      builder: (context, Offset offset, child) {
        return Transform.translate(
          offset: offset * 30,
          child: Opacity(
            opacity: 1 - offset.dx.abs(),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: isUser
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (!isUser) ...[
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isError
                              ? [AppColors.error, AppColors.errorLight]
                              : isSystemMessage
                              ? [AppColors.secondary, AppColors.secondaryLight]
                              : [AppColors.primary, AppColors.primaryLight],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isError
                            ? Icons.error_outline_rounded
                            : isSystemMessage
                            ? Icons.info_outline_rounded
                            : Icons.smart_toy_rounded,
                        color: AppColors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],

                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery
                            .of(context)
                            .size
                            .width * 0.75,
                      ),
                      decoration: BoxDecoration(
                        gradient: isUser
                            ? const LinearGradient(
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
                        borderRadius: BorderRadius.circular(24).copyWith(
                          bottomRight: isUser
                              ? const Radius.circular(8)
                              : const Radius.circular(24),
                          bottomLeft: isUser
                              ? const Radius.circular(24)
                              : const Radius.circular(8),
                        ),
                        border: isError
                            ? Border.all(color: AppColors.error.withOpacity(
                            0.3))
                            : isSystemMessage
                            ? Border.all(
                            color: AppColors.secondaryLight.withOpacity(0.3))
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: isUser
                                ? AppColors.primary.withOpacity(0.15)
                                : AppColors.gray.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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

                          // Confidence score
                          if (!isUser && message.confidenceScore != null &&
                              !isError && !isSystemMessage)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.analytics_outlined,
                                      size: 12,
                                      color: AppColors.primary.withOpacity(0.7),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Confidence: ${(message.confidenceScore *
                                          100).toInt()}%',
                                      style: AppTypography.caption.copyWith(
                                        color: AppColors.primary.withOpacity(
                                            0.7),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  if (isUser) ...[
                    const SizedBox(width: 12),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.secondary,
                            AppColors.secondaryLight
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: AppColors.white,
                        size: 18,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernTypingIndicator() {
    _typingController.repeat();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: AppColors.white,
              size: 18,
            ),
          ),

          const SizedBox(width: 12),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24).copyWith(
                bottomLeft: const Radius.circular(8),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gray.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SizedBox(
              width: 60,
              height: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(3, (index) {
                  return AnimatedBuilder(
                    animation: _typingController,
                    builder: (context, child) {
                      final delay = index * 0.2;
                      final animValue = ((_typingController.value - delay) %
                          1.0);
                      final opacity = animValue < 0.5
                          ? (animValue * 2).clamp(0.3, 1.0)
                          : ((1 - animValue) * 2).clamp(0.3, 1.0);

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 100),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(opacity),
                          shape: BoxShape.circle,
                        ),
                      );
                    },
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernInputSection(ChatbotProvider chatbotProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Error banner
            if (chatbotProvider.error != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.error_outline_rounded,
                        color: AppColors.error,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        chatbotProvider.error!,
                        style: AppTypography.body2.copyWith(
                            color: AppColors.error),
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          chatbotProvider.clearError();
                          chatbotProvider.retryLastMessage();
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: Text(
                            'Retry',
                            style: AppTypography.body2.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Input row
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: AppColors.borderLight,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _controller,
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      enabled: !chatbotProvider.isLoading,
                      style: AppTypography.body1,
                      decoration: InputDecoration(
                        hintText: 'Ask me anything about finance...',
                        hintStyle: AppTypography.body1.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                      ),
                      onSubmitted: (text) {
                        if (text
                            .trim()
                            .isNotEmpty && chatbotProvider.isConnected) {
                          _sendMessage(text.trim());
                        }
                      },
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Send button with enhanced animation
                AnimatedBuilder(
                  animation: _fabScaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _fabScaleAnimation.value,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: (_controller.text
                                .trim()
                                .isNotEmpty &&
                                !chatbotProvider.isLoading &&
                                chatbotProvider.isConnected)
                                ? [
                              AppColors.secondary,
                              AppColors.secondaryLight
                            ]
                                : [AppColors.lightGray, AppColors.gray],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.secondary.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(28),
                            onTap: () {
                              if (_controller.text
                                  .trim()
                                  .isNotEmpty &&
                                  !chatbotProvider.isLoading &&
                                  chatbotProvider.isConnected) {
                                _sendMessage(_controller.text.trim());
                              } else {
                                if (kDebugMode) {
                                  print(
                                      'Send button disabled due to conditions not met');
                                }
                              }
                            },
                            child: Center(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                  chatbotProvider.isLoading
                                      ? Icons.more_horiz_rounded
                                      : !chatbotProvider.isConnected
                                      ? Icons.wifi_off_rounded
                                      : Icons.send_rounded,
                                  color: AppColors.primaryDark,
                                  size: 24,
                                  key: ValueKey(chatbotProvider.isLoading),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
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
        maxChildSize: 0.95,
        builder: (_, controller) =>
            Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 30,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildModernHeader(chatbotProvider),
                  _buildMessagesList(chatbotProvider),
                  _buildModernInputSection(chatbotProvider),
                ],
              ),
            ),
      ),
    );
  }
}