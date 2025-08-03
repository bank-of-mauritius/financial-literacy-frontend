import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:financial_literacy_frontend/models/quiz.dart';
import 'package:financial_literacy_frontend/providers/quiz_provider.dart';
import 'package:financial_literacy_frontend/providers/auth_provider.dart';
import 'package:financial_literacy_frontend/widgets/card.dart';
import 'package:financial_literacy_frontend/widgets/loading_spinner.dart';
import 'package:financial_literacy_frontend/styles/colors.dart';
import 'package:financial_literacy_frontend/styles/typography.dart';
import 'chatbot_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Mock data for economic indicators
  final List<Map<String, dynamic>> economicData = [
    {'symbol': 'S&P 500', 'value': '4,823.52', 'change': '+1.2%', 'positive': true},
    {'symbol': 'NASDAQ', 'value': '15,180.43', 'change': '+0.8%', 'positive': true},
    {'symbol': 'BTC', 'value': '\$43,250', 'change': '-2.1%', 'positive': false},
    {'symbol': 'EUR/USD', 'value': '1.0845', 'change': '+0.3%', 'positive': true},
  ];

  // Mock achievements data
  final List<Map<String, dynamic>> achievements = [
    {'icon': MdiIcons.target, 'title': 'First Quiz', 'desc': 'Completed your first quiz!', 'recent': true},
    {'icon': MdiIcons.trophy, 'title': 'Streak Master', 'desc': '7 days learning streak', 'recent': false},
    {'icon': MdiIcons.brain, 'title': 'AI Explorer', 'desc': 'Asked 10 AI questions', 'recent': true},
  ];

  // Quick actions data
  final List<Map<String, dynamic>> quickActions = [
    {'icon': MdiIcons.play, 'title': 'Daily Quiz', 'desc': 'Test your knowledge', 'gradient': [Colors.yellow.shade400, Colors.yellow.shade600]},
    {'icon': MdiIcons.bookOpenVariant, 'title': 'Learn', 'desc': 'New lessons available', 'gradient': [Colors.blue.shade500, Colors.blue.shade700]},
    {'icon': MdiIcons.chartLine, 'title': 'Portfolio', 'desc': 'Track investments', 'gradient': [Colors.green.shade500, Colors.green.shade700]},
    {'icon': MdiIcons.trendingUp, 'title': 'Markets', 'desc': 'Live market data', 'gradient': [Colors.purple.shade500, Colors.purple.shade700]},
  ];

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
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
                                  child: Icon(
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
                                        gradient: LinearGradient(
                                          colors: [AppColors.secondary, AppColors.secondary.withOpacity(0.8)],
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
                      _buildEconomicIndicators(),
                      const SizedBox(height: 24),
                      _buildQuickActions(),
                      const SizedBox(height: 24),
                      _buildDailyChallenge(quizProvider),
                      const SizedBox(height: 24),
                      _buildRecentAchievements(),
                      const SizedBox(height: 24),
                      _buildQuickStats(),
                      const SizedBox(height: 24),
                      _buildFeaturedQuizzesSection(quizProvider),
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
                    color: Colors.red,
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
        backgroundColor: AppColors.white,
        indicatorColor: AppColors.primary.withOpacity(0.1),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.quiz), label: 'Quizzes'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onDestinationSelected: (index) {
          if (index == 1) Navigator.pushNamed(context, '/quiz');
          else if (index == 2) Navigator.pushNamed(context, '/profile');
        },
      ),
    );
  }

  Widget _buildEconomicIndicators() {
    return AppCard(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Market Overview', style: AppTypography.h4.copyWith(color: AppColors.primary)),
                Icon(MdiIcons.trendingUp, color: AppColors.secondary, size: 20),
              ],
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2,
              children: economicData.map((item) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['symbol'],
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['value'],
                      style: AppTypography.body1.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    Text(
                      item['change'],
                      style: AppTypography.caption.copyWith(
                        color: item['positive'] ? Colors.green.shade600 : Colors.red.shade500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: quickActions.map((action) {
        return GestureDetector(
          onTap: () {
            if (action['title'] == 'Daily Quiz') {
              Navigator.pushNamed(context, '/quiz');
            }
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: action['gradient'],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: action['gradient'][0].withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    action['icon'],
                    color: AppColors.white,
                    size: 24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    action['title'],
                    style: AppTypography.body1.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    action['desc'],
                    style: AppTypography.caption.copyWith(
                      color: AppColors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDailyChallenge(QuizProvider quizProvider) {
    final featuredQuiz = quizProvider.quizzes.isNotEmpty ? quizProvider.quizzes.first : null;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.secondary, AppColors.secondary.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(MdiIcons.flash, color: AppColors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Daily Challenge',
                        style: AppTypography.body1.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    featuredQuiz?.title ?? 'Compound Interest Quiz',
                    style: AppTypography.h4.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${featuredQuiz?.questionCount ?? 5} questions • 2 min • ${featuredQuiz?.points ?? 50} XP',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/quiz', arguments: featuredQuiz?.id),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(MdiIcons.play, color: AppColors.white, size: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAchievements() {
    return AppCard(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Achievements', style: AppTypography.h4.copyWith(color: AppColors.primary)),
                Icon(MdiIcons.trophy, color: AppColors.secondary, size: 20),
              ],
            ),
            const SizedBox(height: 16),
            ...achievements.map((achievement) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: achievement['recent']
                            ? AppColors.secondary.withOpacity(0.1)
                            : AppColors.lightGray,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        achievement['icon'],
                        color: achievement['recent']
                            ? AppColors.secondary
                            : AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            achievement['title'],
                            style: AppTypography.body1.copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            achievement['desc'],
                            style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    if (achievement['recent'])
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: AppCard(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(MdiIcons.bookOpenVariant, color: Colors.blue.shade600, size: 16),
                  ),
                  const SizedBox(height: 8),
                  Text('12', style: AppTypography.h3.copyWith(fontWeight: FontWeight.bold)),
                  Text('Lessons', style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: AppCard(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(MdiIcons.target, color: Colors.green.shade600, size: 16),
                  ),
                  const SizedBox(height: 8),
                  Text('7', style: AppTypography.h3.copyWith(fontWeight: FontWeight.bold)),
                  Text('Day Streak', style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: AppCard(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.purple.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(MdiIcons.trophy, color: Colors.purple.shade600, size: 16),
                  ),
                  const SizedBox(height: 8),
                  Text('850', style: AppTypography.h3.copyWith(fontWeight: FontWeight.bold)),
                  Text('XP Points', style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedQuizzesSection(QuizProvider quizProvider) {
    final featuredQuizzes = quizProvider.quizzes.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Featured Quizzes', style: AppTypography.h4.copyWith(color: AppColors.primary)),
        const SizedBox(height: 12),
        if (featuredQuizzes.isEmpty)
          const Center(child: Text('No quizzes available', style: AppTypography.body1))
        else
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: featuredQuizzes.length,
              itemBuilder: (context, index) {
                final quiz = featuredQuizzes[index];
                return Container(
                  width: 280,
                  margin: const EdgeInsets.only(right: 16),
                  child: AppCard(
                    elevation: 2,
                    child: InkWell(
                      onTap: () => Navigator.pushNamed(context, '/quiz', arguments: quiz.id),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(quiz.title, style: AppTypography.h4),
                            const SizedBox(height: 8),
                            Text(
                              quiz.description,
                              style: AppTypography.body2,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    quiz.difficulty,
                                    style: AppTypography.caption.copyWith(color: AppColors.white),
                                  ),
                                ),
                                Text(
                                  '${quiz.points} XP',
                                  style: AppTypography.caption.copyWith(color: AppColors.primary),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}