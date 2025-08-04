import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:financial_literacy_frontend/styles/colors.dart';
import 'package:financial_literacy_frontend/styles/typography.dart';
import 'package:financial_literacy_frontend/widgets/card.dart';

class RecentAchievements extends StatelessWidget {
  RecentAchievements({super.key});

  final List<Map<String, dynamic>> achievements = [
    {'icon': MdiIcons.target, 'title': 'First Quiz', 'desc': 'Completed your first quiz!', 'recent': true},
    {'icon': MdiIcons.trophy, 'title': 'Streak Master', 'desc': '7 days learning streak', 'recent': false},
    {'icon': MdiIcons.brain, 'title': 'AI Explorer', 'desc': 'Asked 10 AI questions', 'recent': true},
  ];

  @override
  Widget build(BuildContext context) {
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
                            ? AppColors.secondaryLight.withOpacity(0.1)
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
                        decoration: const BoxDecoration(
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
}