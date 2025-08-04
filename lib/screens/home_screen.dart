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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  List<Map<String, dynamic>> economicData = [];
  bool isLoadingMarketData = false;
  String? marketDataError;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    //Provider.of<QuizProvider>(context, listen: false).fetchQuizzes();
    _fetchMarketData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchMarketData() async {
    setState(() {
      isLoadingMarketData = true;
      marketDataError = null;
    });

    // Load cached data if available
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('market_data');
    if (cachedData != null) {
      setState(() {
        economicData = List<Map<String, dynamic>>.from(jsonDecode(cachedData));
        isLoadingMarketData = false;
      });
      return;
    }

    try {
      final apiService = ApiService();
      final List<dynamic> marketData = await apiService.fetchMarketData('^GSPC,^IXIC');

      if (marketData.isEmpty) {
        throw Exception('Empty market data response');
      }

      final List<Map<String, dynamic>> tempData = [];
      for (var item in marketData) {
        final symbol = item['symbol'] as String;
        final price = double.parse(item['price'].toString());
        final changePercent = double.parse(item['changesPercentage'].toString()).toStringAsFixed(2);
        final isPositive = item['changesPercentage'] >= 0;

        tempData.add({
          'symbol': symbol == '^GSPC' ? 'S&P 500' : 'NASDAQ',
          'value': price.toStringAsFixed(2),
          'change': '$changePercent%',
          'positive': isPositive,
        });
      }

      // Cache the data
      await prefs.setInt('market_data_time', DateTime.now().millisecondsSinceEpoch);
      await prefs.setString('market_data', jsonEncode(tempData));

      setState(() {
        economicData = tempData;
        isLoadingMarketData = false;
      });
    } catch (e) {
      setState(() {
        marketDataError = 'Failed to load market data: $e';
        isLoadingMarketData = false;
        // Fallback to mock data
        economicData = [
          {'symbol': 'S&P 500', 'value': '4,823.52', 'change': '+1.2%', 'positive': true},
          {'symbol': 'NASDAQ', 'value': '15,180.43', 'change': '+0.8%', 'positive': true},
        ];
      });
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

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Container(
        color: AppColors.background,
        child: CustomScrollView(
          slivers: [
            // Custom App Bar with futuristic header
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: AppColors.primary,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, AppColors.primaryLight],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top bar with profile
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${_getGreeting()}, ${authProvider.user?.name ?? 'User'}',
                                    style: AppTypography.h3.copyWith(color: AppColors.white),
                                  ),
                                  Text(
                                    '${_getCurrentTime()} • Ready to learn?',
                                    style: AppTypography.body2.copyWith(color: AppColors.white.withOpacity(0.7)),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () => Navigator.pushNamed(context, '/profile'),
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.secondary.withOpacity(0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    color: AppColors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Progress Overview
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.white.withOpacity(0.2),
                                width: 1,
                              ),
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
                                    Text(
                                      '67%',
                                      style: AppTypography.h4.copyWith(
                                        color: AppColors.secondary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: AppColors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: 0.67,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [AppColors.secondary, AppColors.secondaryLight],
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '12 lessons completed • 6 more to go!',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.white.withOpacity(0.7),
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
              ),
            ),
            // Main content
            SliverToBoxAdapter(
              child: quizProvider.isLoading
                  ? const LoadingSpinner()
                  : FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      EconomicIndicators(
                        economicData: economicData,
                        isLoading: isLoadingMarketData,
                        error: marketDataError,
                      ),
                      const SizedBox(height: 24),
                      QuickActions(
                        onQuizTap: () {
                          Navigator.pushNamed(
                            context,
                            '/quiz',
                            arguments: quizProvider.quizzes.isNotEmpty ? quizProvider.quizzes.first.id : 1,
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      DailyChallenge(quizProvider: quizProvider),
                      const SizedBox(height: 24),
                      RecentAchievements(),
                      const SizedBox(height: 24),
                      QuickStats(),
                      const SizedBox(height: 24),
                      FeaturedQuizzes(quizProvider: quizProvider),
                      const SizedBox(height: 80), // Space for bottom nav
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const ChatbotScreen(),
          ),
          backgroundColor: AppColors.secondary,
          elevation: 0,
          child: Stack(
            children: [
              const Icon(Icons.chat_bubble, color: AppColors.white),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.accent.withOpacity(0.2),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.quiz), label: 'Quizzes'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onDestinationSelected: (index) {
          if (index == 1) {
            Navigator.pushNamed(
              context,
              '/quiz',
              arguments: quizProvider.quizzes.isNotEmpty ? quizProvider.quizzes.first.id : 1,
            );
          } else if (index == 2) {
            Navigator.pushNamed(context, '/profile');
          }
        },
      ),
    );
  }
}