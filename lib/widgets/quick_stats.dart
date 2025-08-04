import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:financial_literacy_frontend/styles/colors.dart';
import 'package:financial_literacy_frontend/styles/typography.dart';
import 'package:financial_literacy_frontend/widgets/card.dart';

class QuickStats extends StatelessWidget {
  const QuickStats({super.key});

  @override
  Widget build(BuildContext context) {
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
                      color: AppColors.accent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(MdiIcons.bookOpenVariant, color: AppColors.accent, size: 16),
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
                      color: AppColors.accent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(MdiIcons.target, color: AppColors.accent, size: 16),
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
                      color: AppColors.accent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(MdiIcons.trophy, color: AppColors.accent, size: 16),
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
}