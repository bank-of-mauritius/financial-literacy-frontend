import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:financial_literacy_frontend/styles/colors.dart';
import 'package:financial_literacy_frontend/styles/typography.dart';
import '../screens/market_indicators_screen.dart';
import '../screens/learn_screen.dart';

class QuickActions extends StatelessWidget {
  final VoidCallback onQuizTap;

  QuickActions({super.key, required this.onQuizTap});

  final List<Map<String, dynamic>> quickActions = [
    {
      'icon': MdiIcons.play,
      'title': 'Daily Quiz',
      'desc': 'Test your knowledge',
      'gradient': [AppColors.secondary, AppColors.secondaryLight],
      'action': 'quiz'
    },
    {
      'icon': MdiIcons.bookOpenVariant,
      'title': 'Learn',
      'desc': 'New lessons available',
      'gradient': [AppColors.primary, AppColors.primaryLight],
      'action': 'learn'
    },
    {
      'icon': MdiIcons.chartLine,
      'title': 'Portfolio',
      'desc': 'Track investments',
      'gradient': [AppColors.accent, AppColors.accent.withOpacity(0.8)],
      'action': 'portfolio'
    },
    {
      'icon': MdiIcons.trendingUp,
      'title': 'Markets',
      'desc': 'Live market data',
      'gradient': [AppColors.primaryLight, AppColors.primary],
      'action': 'markets'
    },
  ];

  void _handleActionTap(BuildContext context, String action) {
    switch (action) {
      case 'quiz':
        onQuizTap();
        break;
      case 'learn':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LearnScreen(),
          ),
        );
        break;
      case 'portfolio':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Portfolio tracking coming soon!'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        break;
      case 'markets':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MarketIndicatorsScreen(),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: quickActions.asMap().entries.map((entry) {
        final index = entry.key;
        final action = entry.value;
        return TweenAnimationBuilder(
          duration: Duration(milliseconds: 600 + (index * 100)), // Staggered animation
          tween: Tween<double>(begin: 0, end: 1),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 50 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: GestureDetector(
                  onTap: () => _handleActionTap(context, action['action']),
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
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: AppColors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              action['icon'],
                              color: AppColors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            action['title'],
                            style: AppTypography.body1.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            action['desc'],
                            style: AppTypography.caption.copyWith(
                              color: AppColors.white.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.white.withOpacity(0.5),
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: AppColors.white,
                                  size: 16,
                                ),
                              ),
                            ],
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
      }).toList(),
    );
  }
}