import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:financial_literacy_frontend/models/quiz.dart';
import 'package:financial_literacy_frontend/providers/quiz_provider.dart';
import 'package:financial_literacy_frontend/widgets/card.dart';
import 'package:financial_literacy_frontend/widgets/loading_spinner.dart';
import 'package:financial_literacy_frontend/styles/colors.dart';
import 'package:financial_literacy_frontend/styles/typography.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);
    final quizId = ModalRoute.of(context)!.settings.arguments as int;

    return Scaffold(
      appBar: AppBar(title: Text(quizProvider.currentQuiz?.title ?? 'Quiz', style: AppTypography.h3, selectionColor: AppColors.white), backgroundColor: AppColors.primary),
      body: quizProvider.isLoading || quizProvider.currentQuiz == null
          ? const LoadingSpinner()
          : quizProvider.quizResult != null
          ? _buildResultView(context, quizProvider)
          : _buildQuizView(context, quizProvider, quizId),
    );
  }

  Widget _buildQuizView(BuildContext context, QuizProvider quizProvider, int quizId) {
    final currentQuestion = quizProvider.currentQuestionData;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                Text(quizProvider.currentQuiz!.title, style: AppTypography.h3.copyWith(color: AppColors.white)),
                const SizedBox(height: 8),
                Text('Q${quizProvider.currentQuestion + 1} / ${quizProvider.currentQuiz!.questions!.length}', style: AppTypography.body2.copyWith(color: AppColors.white)),
              ],
            ),
          ),
          if (quizProvider.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(quizProvider.error!, style: AppTypography.body2.copyWith(color: AppColors.error)),
            ),
          const SizedBox(height: 16),
          AppCard(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(currentQuestion!.text, style: AppTypography.h4),
                  const SizedBox(height: 16),
                  ...currentQuestion.options.asMap().entries.map((entry) {
                    final index = entry.key;
                    final option = entry.value;
                    return AnimatedOpacity(
                      opacity: quizProvider.isLoading ? 0 : 1,
                      duration: Duration(milliseconds: (300 + index * 100).toInt()),
                      child: GestureDetector(
                        onTap: () => quizProvider.selectAnswer(option),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: quizProvider.selectedAnswers[quizProvider.currentQuestion] == option ? AppColors.primary : AppColors.border),
                            borderRadius: BorderRadius.circular(10),
                            color: quizProvider.selectedAnswers[quizProvider.currentQuestion] == option ? AppColors.primary.withOpacity(0.1) : null,
                          ),
                          child: Text(option, style: AppTypography.body1),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: quizProvider.currentQuestion == 0 ? null : () => quizProvider.previousQuestion(),
                child: const Row(children: [Icon(Icons.chevron_left), Text('Previous')]),
              ),
              ElevatedButton(
                onPressed: quizProvider.canProceed && !quizProvider.isSubmitting
                    ? () {
                  if (quizProvider.isLastQuestion) quizProvider.submitQuiz(quizId);
                  else quizProvider.nextQuestion();
                }
                    : null,
                child: Row(children: [Text(quizProvider.isLastQuestion ? 'Submit' : 'Next'), const Icon(Icons.chevron_right)]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultView(BuildContext context, QuizProvider quizProvider) {
    return Center(
      child: AppCard(
        elevation: 2,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Quiz Completed', style: AppTypography.h3.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Text('Score: ${quizProvider.quizResult!.score} / ${quizProvider.quizResult!.total}', style: AppTypography.h4.copyWith(color: AppColors.primary)),
            const SizedBox(height: 8),
            Text(quizProvider.quizResult!.message, style: AppTypography.body1.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false), child: const Text('Back to Home')),
          ],
        ),
      ),
    );
  }
}