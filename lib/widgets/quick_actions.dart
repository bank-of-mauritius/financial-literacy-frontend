import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:financial_literacy_frontend/styles/colors.dart';
import 'package:financial_literacy_frontend/styles/typography.dart';

class QuickActions extends StatelessWidget {
  final VoidCallback onQuizTap;

  QuickActions({super.key, required this.onQuizTap});

  final List<Map<String, dynamic>> quickActions = [
    {'icon': MdiIcons.play, 'title': 'Daily Quiz', 'desc': 'Test your knowledge', 'gradient': [AppColors.secondary, AppColors.secondaryLight]},
    {'icon': MdiIcons.bookOpenVariant, 'title': 'Learn', 'desc': 'New lessons available', 'gradient': [AppColors.primary, AppColors.primaryLight]},
    {'icon': MdiIcons.chartLine, 'title': 'Portfolio', 'desc': 'Track investments', 'gradient': [AppColors.accent, AppColors.accent.withOpacity(0.8)]},
    {'icon': MdiIcons.trendingUp, 'title': 'Markets', 'desc': 'Live market data', 'gradient': [AppColors.primaryLight, AppColors.primary]},
  ];

  @override
  Widget build(BuildContext context) {
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
              onQuizTap();
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
}