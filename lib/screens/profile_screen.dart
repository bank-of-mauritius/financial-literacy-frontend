import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:financial_literacy_frontend/models/user.dart';
import 'package:financial_literacy_frontend/providers/auth_provider.dart';
import 'package:financial_literacy_frontend/widgets/card.dart';
import 'package:financial_literacy_frontend/widgets/loading_spinner.dart';
import 'package:financial_literacy_frontend/styles/colors.dart';
import 'package:financial_literacy_frontend/styles/typography.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  bool _showAchievements = false;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<Map<String, dynamic>> stats = [
    {'label': 'Quizzes Completed', 'value': 15, 'icon': MdiIcons.medal, 'color': AppColors.primary, 'gradient': [Colors.blue.shade500, Colors.blue.shade700]},
    {'label': 'Total Points', 'value': 1250, 'icon': MdiIcons.star, 'color': AppColors.secondary, 'gradient': [Colors.amber.shade400, Colors.amber.shade600]},
    {'label': 'Learning Streak', 'value': '7 days', 'icon': MdiIcons.fire, 'color': AppColors.success, 'gradient': [Colors.orange.shade500, Colors.red.shade600]},
    {'label': 'Articles Read', 'value': 23, 'icon': MdiIcons.bookOpenVariant, 'color': AppColors.text, 'gradient': [Colors.green.shade500, Colors.green.shade700]},
  ];

  final List<Achievement> achievements = [
    Achievement(id: 1, title: 'First Steps', description: 'Complete your first quiz', icon: 'trophy', earned: true, points: 50, color: '#FFD700'),
    Achievement(id: 2, title: 'Knowledge Seeker', description: 'Read 10 articles', icon: 'school', earned: true, points: 100, color: '#10B981'),
    Achievement(id: 3, title: 'Quiz Master', description: 'Complete 10 quizzes', icon: 'quiz', earned: true, points: 200, color: '#1A237E'),
    Achievement(id: 4, title: 'Streak Champion', description: 'Maintain a 7-day learning streak', icon: 'fire', earned: true, points: 150, color: '#EF4444'),
    Achievement(id: 5, title: 'Investment Guru', description: 'Complete all investing quizzes', icon: 'trending-up', earned: false, points: 300, color: '#3B82F6'),
    Achievement(id: 6, title: 'Budget Pro', description: 'Master budgeting concepts', icon: 'wallet', earned: false, points: 250, color: '#10B981'),
  ];

  final List<Activity> recentActivity = [
    Activity(id: 1, type: 'quiz', title: 'Completed "Intro to Stocks" quiz', points: 80, date: '2024-01-20', icon: 'quiz'),
    Activity(id: 2, type: 'article', title: 'Read "Understanding Risk and Return"', points: 10, date: '2024-01-19', icon: 'book-open-variant'),
    Activity(id: 3, type: 'achievement', title: 'Earned "Quiz Master" achievement', points: 200, date: '2024-01-18', icon: 'trophy'),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: authProvider.isLoading || !authProvider.isInitialized
          ? const LoadingSpinner()
          : CustomScrollView(
        slivers: [
          _buildSliverAppBar(authProvider.user),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildStatsSection(),
                      const SizedBox(height: 24),
                      _buildAchievementsSection(),
                      const SizedBox(height: 24),
                      _buildRecentActivitySection(),
                      const SizedBox(height: 24),
                      _buildSettingsSection(authProvider),
                      const SizedBox(height: 80), // Space for bottom nav
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(User? user) {
    final progress = (user?.totalPoints ?? 0) % 500 / 500;
    final nextLevelPoints = ((user?.totalPoints ?? 0) ~/ 500 + 1) * 500;
    final currentLevel = (user?.totalPoints ?? 0) ~/ 500 + 1;

    return SliverAppBar(
      expandedHeight: 280, // Reduced from 320
      pinned: true,
      backgroundColor: AppColors.primary,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.primary.withOpacity(0.8),
                AppColors.secondary.withOpacity(0.3),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20), // Reduced from 40
                  // Profile Avatar with glow effect
                  Container(
                    width: 80, // Reduced from 100
                    height: 80, // Reduced from 100
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppColors.secondary, AppColors.secondary.withOpacity(0.7)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        user?.name?.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U',
                        style: AppTypography.h2.copyWith( // Reduced from h1
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12), // Reduced from 16
                  // User Info
                  Text(
                    user?.name ?? 'User',
                    style: AppTypography.h3.copyWith( // Reduced from h2
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user?.email ?? 'email@example.com',
                    style: AppTypography.body2.copyWith( // Reduced from body1
                      color: AppColors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 12), // Reduced from 16
                  // Edit Profile Button - Made more compact
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.white.withOpacity(0.3)),
                    ),
                    child: TextButton.icon(
                      onPressed: () => _showEditProfileDialog(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: const Icon(Icons.edit, color: AppColors.white, size: 16),
                      label: Text(
                        'Edit Profile',
                        style: AppTypography.body2.copyWith(color: AppColors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16), // Reduced from 20
                  // Level Progress - Made more compact
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(MdiIcons.chartBox, color: AppColors.primary, size: 24),
            const SizedBox(width: 8),
            Text(
              'Your Stats',
              style: AppTypography.h3.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
          children: stats.asMap().entries.map((entry) {
            final index = entry.key;
            final stat = entry.value;

            return TweenAnimationBuilder(
              duration: Duration(milliseconds: 500 + (index * 100)),
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: stat['gradient'],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: stat['gradient'][0].withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              stat['icon'],
                              color: AppColors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${stat['value']}',
                            style: AppTypography.h3.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            stat['label'],
                            style: AppTypography.caption.copyWith(
                              color: AppColors.white.withOpacity(0.9),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAchievementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(MdiIcons.trophy, color: AppColors.secondary, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Achievements',
                  style: AppTypography.h3.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () => setState(() => _showAchievements = !_showAchievements),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _showAchievements ? 'Show Less' : 'See All',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _showAchievements ? null : 140,
          child: _showAchievements
              ? _buildAllAchievements()
              : _buildFeaturedAchievements(),
        ),
      ],
    );
  }

  Widget _buildFeaturedAchievements() {
    final earnedAchievements = achievements.where((a) => a.earned).take(4).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: earnedAchievements.map((achievement) {
          return Container(
            width: 120,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(int.parse(achievement.color.replaceFirst('#', '0xFF'))),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(int.parse(achievement.color.replaceFirst('#', '0xFF'))).withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      _getIconFromString(achievement.icon),
                      color: AppColors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    achievement.title,
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '+${achievement.points} XP',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAllAchievements() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: achievements.map((achievement) {
        return Container(
          decoration: BoxDecoration(
            color: achievement.earned ? AppColors.white : AppColors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: achievement.earned
                ? null
                : Border.all(color: AppColors.border),
            boxShadow: achievement.earned
                ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ]
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: achievement.earned
                        ? Color(int.parse(achievement.color.replaceFirst('#', '0xFF')))
                        : AppColors.lightGray,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getIconFromString(achievement.icon),
                    color: achievement.earned ? AppColors.white : AppColors.textSecondary,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  achievement.title,
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: achievement.earned ? AppColors.text : AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '+${achievement.points} XP',
                  style: AppTypography.caption.copyWith(
                    color: achievement.earned ? AppColors.secondary : AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(MdiIcons.history, color: AppColors.primary, size: 24),
            const SizedBox(width: 8),
            Text(
              'Recent Activity',
              style: AppTypography.h3.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...recentActivity.asMap().entries.map((entry) {
          final index = entry.key;
          final activity = entry.value;

          return TweenAnimationBuilder(
            duration: Duration(milliseconds: 300 + (index * 100)),
            tween: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero),
            builder: (context, Offset offset, child) {
              return Transform.translate(
                offset: offset * 100,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.primary.withOpacity(0.1), AppColors.secondary.withOpacity(0.1)],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getIconFromString(activity.icon),
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activity.title,
                                style: AppTypography.body1.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                activity.date,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.green.shade500, Colors.green.shade600],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '+${activity.points}',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildSettingsSection(AuthProvider authProvider) {
    final settingsItems = [
      {'title': 'Notifications', 'icon': Icons.notifications, 'onTap': () {}},
      {'title': 'Privacy Policy', 'icon': Icons.privacy_tip, 'onTap': () {}},
      {'title': 'Help & Support', 'icon': Icons.help, 'onTap': () {}},
      {'title': 'Logout', 'icon': Icons.logout, 'onTap': () => _showLogoutDialog(authProvider), 'color': AppColors.error},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(MdiIcons.cog, color: AppColors.primary, size: 24),
            const SizedBox(width: 8),
            Text(
              'Settings',
              style: AppTypography.h3.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: settingsItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == settingsItems.length - 1;

              return Column(
                children: [
                  InkWell(
                    onTap: item['onTap'] as VoidCallback,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: (item['color'] as Color? ?? AppColors.primary).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              item['icon'] as IconData,
                              size: 20,
                              color: item['color'] as Color? ?? AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              item['title'] as String,
                              style: AppTypography.body1.copyWith(
                                color: item['color'] as Color? ?? AppColors.text,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            size: 20,
                            color: item['color'] as Color? ?? AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!isLast)
                    Divider(
                      height: 1,
                      indent: 60,
                      color: AppColors.border,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Profile'),
        content: const Text('Edit profile functionality will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: AppTypography.body1.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              authProvider.logout();
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
            },
            child: Text(
              'Logout',
              style: AppTypography.body1.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'trophy':
        return MdiIcons.trophy;
      case 'school':
        return MdiIcons.school;
      case 'quiz':
        return MdiIcons.school;
      case 'fire':
        return MdiIcons.fire;
      case 'trending-up':
        return MdiIcons.trendingUp;
      case 'wallet':
        return MdiIcons.wallet;
      case 'book-open-variant':
        return MdiIcons.bookOpenVariant;
      default:
        return MdiIcons.star;
    }
  }
}

// Mock classes for the achievements and activities
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
}