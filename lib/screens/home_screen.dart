import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:financial_literacy_frontend/providers/quiz_provider.dart';
import 'package:financial_literacy_frontend/providers/auth_provider.dart';
import 'package:financial_literacy_frontend/services/api_service.dart';
import 'package:financial_literacy_frontend/styles/colors.dart';
import 'package:financial_literacy_frontend/styles/typography.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:financial_literacy_frontend/widgets/economic_indicators.dart';
import 'package:financial_literacy_frontend/widgets/quick_actions.dart';
import 'package:financial_literacy_frontend/widgets/daily_challenge.dart';
import 'package:financial_literacy_frontend/widgets/recent_achievements.dart';
import 'package:financial_literacy_frontend/widgets/quick_stats.dart';
import 'package:financial_literacy_frontend/widgets/featured_quizzes.dart';
import 'package:financial_literacy_frontend/widgets/loading_spinner.dart';
import 'chatbot_screen.dart';
import 'dart:convert';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late AnimationController _floatingController;
  late AnimationController _headerController;
  late AnimationController _notificationController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _floatingAnimation;
  late Animation<double> _headerSlideAnimation;
  late Animation<double> _notificationSlideAnimation;

  final ScrollController _scrollController = ScrollController();
  bool _showNotification = false;

  List<Map<String, dynamic>> economicData = [];
  bool isLoadingMarketData = false;
  String? marketDataError;
  double _scrollOffset = 0;
  bool _isHeaderExpanded = true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupScrollListener();
    _fetchMarketData();
    _triggerNotification();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _headerController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _notificationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutExpo,
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _floatingAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _headerSlideAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutCubic,
    );

    _notificationSlideAnimation = Tween<double>(begin: -100, end: 0).animate(
      CurvedAnimation(parent: _notificationController, curve: Curves.easeOutBack),
    );

    _fadeController.forward();
    _pulseController.repeat(reverse: true);
    _floatingController.repeat(reverse: true);
    _headerController.forward();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
        _isHeaderExpanded = _scrollOffset < 100;
      });
    });
  }

  void _triggerNotification() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showNotification = true;
          _notificationController.forward();
        });
        Future.delayed(const Duration(seconds: 15), () {
          if (mounted) {
            setState(() {
              _notificationController.reverse().then((_) {
                setState(() {
                  _showNotification = false;
                });
              });
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    _floatingController.dispose();
    _headerController.dispose();
    _notificationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchMarketData() async {
    setState(() {
      isLoadingMarketData = true;
      marketDataError = null;
    });

    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('market_data');
    if (cachedData != null) {
      setState(() {
        economicData = List<Map<String, dynamic>>.from(jsonDecode(cachedData));
        isLoadingMarketData = false;
      });
      return;
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildModernAppBar(AuthProvider authProvider) {
    final opacity = (_scrollOffset / 200).clamp(0.0, 1.0);

    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary.withOpacity(opacity),
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: AnimatedBuilder(
          animation: _headerSlideAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -50 * (1 - _headerSlideAnimation.value)),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryLight,
                      AppColors.primaryDark,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeaderContent(authProvider),
                        const Spacer(),
                        _buildProgressCard(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderContent(AuthProvider authProvider) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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
                          '${_getGreeting()}, ${authProvider.user?.name ?? 'User'}',
                          style: AppTypography.h3.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
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
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.white.withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 14,
                                    color: AppColors.white.withOpacity(0.8),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _getCurrentTime(),
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.white.withOpacity(0.9),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.success.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                'Ready to learn?',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w500,
                                ),
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
          TweenAnimationBuilder(
            duration: const Duration(milliseconds: 1200),
            tween: Tween<double>(begin: 0, end: 1),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: _buildProfileAvatar(authProvider),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar(AuthProvider authProvider) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/profile'),
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.secondary, AppColors.secondaryLight],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(28),
                  onTap: () => Navigator.pushNamed(context, '/profile'),
                  child: Center(
                    child: Text(
                      authProvider.user?.name.isNotEmpty == true
                          ? authProvider.user!.name[0].toUpperCase()
                          : 'U',
                      style: AppTypography.h4.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressCard() {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 1400),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.white.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Learning Progress',
                        style: AppTypography.body1.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.secondary, AppColors.secondaryLight],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '67%',
                          style: AppTypography.body1.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Stack(
                      children: [
                        TweenAnimationBuilder(
                          duration: const Duration(milliseconds: 2000),
                          tween: Tween<double>(begin: 0, end: 0.67),
                          curve: Curves.easeOutExpo,
                          builder: (context, progressValue, child) {
                            return FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: progressValue,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [AppColors.secondary, AppColors.secondaryLight],
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.secondary.withOpacity(0.5),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
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
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '12 lessons completed',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.white.withOpacity(0.8),
                        ),
                      ),
                      Text(
                        '6 more to go!',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.secondaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernFloatingActionButton() {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatingAnimation.value),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.secondary, AppColors.secondaryLight],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(28),
                onTap: () => _showChatbot(),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: 1 + (sin(_pulseController.value * 2 * pi) * 0.1),
                              child: const Icon(
                                Icons.chat_bubble_rounded,
                                color: AppColors.white,
                                size: 24,
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showChatbot() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ChatbotScreen(),
    );
  }

  Widget _buildNotificationWidget() {
    return AnimatedBuilder(
      animation: _notificationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _notificationSlideAnimation.value),
          child: FadeTransition(
            opacity: _notificationController,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _notificationController.reverse().then((_) {
                    setState(() {
                      _showNotification = false;
                    });
                  });
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.secondary, AppColors.secondaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Do you know?',
                          style: AppTypography.h4.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Transform.scale(
                          scale: 1 + (sin(_notificationController.value * 2 * pi) * 0.1),
                          child: Icon(
                            Icons.lightbulb_outline,
                            color: AppColors.white.withOpacity(0.8),
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'The Bank of Mauritius has launched a new bond offering a 3.5% quarterly yield!',
                      style: AppTypography.body2.copyWith(
                        color: AppColors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _notificationController.reverse().then((_) {
                              setState(() {
                                _showNotification = false;
                              });
                            });
                          });
                        },
                        child: Text(
                          'Got it!',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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

  Widget _buildModernContent(QuizProvider quizProvider) {
    return SliverToBoxAdapter(
      child: quizProvider.isLoading
          ? const LoadingSpinner()
          : FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
                children: [
            TweenAnimationBuilder(
            duration: const Duration(milliseconds: 600),
            tween: Tween<double>(begin: 0, end: 1),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 50 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: EconomicIndicators(
                    economicData: economicData,
                    isLoading: isLoadingMarketData,
                    error: marketDataError,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 28),
          TweenAnimationBuilder(
            duration: const Duration(milliseconds: 800),
            tween: Tween<double>(begin: 0, end: 1),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 50 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: QuickActions(
                    onQuizTap: () {
                      Navigator.pushNamed(
                        context,
                        '/quiz',
                        arguments: quizProvider.quizzes.isNotEmpty
                            ? quizProvider.quizzes.first.id
                            : 1,
                      );
                    },
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 28),
          TweenAnimationBuilder(
            duration: const Duration(milliseconds: 1000),
            tween: Tween<double>(begin: 0, end: 1),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 50 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: DailyChallenge(quizProvider: quizProvider),
                ),
              );
            },
          ),
          const SizedBox(height: 28),
          TweenAnimationBuilder(
            duration: const Duration(milliseconds: 1200),
            tween: Tween<double>(begin: 0, end: 1),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 50 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: RecentAchievements(),
                ),
              );
            },
          ),
          const SizedBox(height: 28),
      TweenAnimationBuilder(
        duration: const Duration(milliseconds: 1400),
        tween: Tween<double>(begin: 0, end: 1),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 50 * (1 - value)),
            child: Opacity(
              opacity: value,
              child: const QuickStats(),
            ),
          );
        },
      ),
      const SizedBox(height: 28),
      TweenAnimationBuilder(
        duration: const Duration(milliseconds: 1600),
        tween: Tween<double>(begin: 0, end: 1),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 50 * (1 - value)),
            child: Opacity(
              opacity: value,
              child: FeaturedQuizzes(quizProvider: quizProvider),
            ),
          );
        },
      ),
      const SizedBox(height: 120), // Increased to avoid overlap with nav bar
      ],
    ),
    ),
    ),
    );
  }

  Widget _buildFloatingNavigationBar(QuizProvider quizProvider) {
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = max(mediaQuery.padding.bottom, 16.0);

    return Positioned(
      left: 0,
      right: 0,
      bottom: bottomPadding,
      child: Center(
        child: Container(
          width: 240, // Adjusted to fit 3 icons comfortably
          height: bottomPadding + 64, // Height for icons + padding
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  offset: const Offset(0, 8),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    // Home is already selected, no action needed
                  },
                  child: Icon(
                    Icons.home_rounded,
                    color: AppColors.white,
                    size: 28,
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/quiz',
                      arguments: quizProvider.quizzes.isNotEmpty
                          ? quizProvider.quizzes.first.id
                          : 1,
                    );
                  },
                  child: Icon(
                    Icons.quiz_rounded,
                    color: AppColors.white.withOpacity(0.7),
                    size: 28,
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Navigator.pushNamed(context, '/profile');
                  },
                  child: Icon(
                    Icons.person_rounded,
                    color: AppColors.white.withOpacity(0.7),
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildModernAppBar(authProvider),
              _buildModernContent(quizProvider),
            ],
          ),
          _buildFloatingNavigationBar(quizProvider),
          if (_showNotification)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildNotificationWidget(),
            ),
        ],
      ),
      floatingActionButton: _buildModernFloatingActionButton(),
    );
  }
}