import 'package:flutter/material.dart';
import 'package:financial_literacy_frontend/providers/quiz_provider.dart';
import 'package:financial_literacy_frontend/styles/colors.dart';
import 'package:financial_literacy_frontend/styles/typography.dart';
import 'package:financial_literacy_frontend/widgets/card.dart';

class FeaturedQuizzes extends StatelessWidget {
  final QuizProvider quizProvider;

  const FeaturedQuizzes({super.key, required this.quizProvider});

  @override
  Widget build(BuildContext context) {
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