import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:financial_literacy_frontend/models/quiz.dart';
import 'package:financial_literacy_frontend/providers/quiz_provider.dart';
import 'package:financial_literacy_frontend/styles/colors.dart';
import 'package:financial_literacy_frontend/styles/typography.dart';

class DailyChallenge extends StatelessWidget {
  final QuizProvider quizProvider;

  const DailyChallenge({super.key, required this.quizProvider});

  @override
  Widget build(BuildContext context) {
    final featuredQuiz = quizProvider.quizzes.isNotEmpty ? quizProvider.quizzes.first : null;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.secondary, AppColors.secondaryLight],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 6),
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
              onTap: () => Navigator.pushNamed(context, '/quiz', arguments: featuredQuiz?.id ?? 1),
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
}