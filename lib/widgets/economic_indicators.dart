import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:financial_literacy_frontend/styles/colors.dart';
import 'package:financial_literacy_frontend/styles/typography.dart';
import 'package:financial_literacy_frontend/widgets/card.dart';
import 'package:financial_literacy_frontend/widgets/loading_spinner.dart';

class EconomicIndicators extends StatelessWidget {
  final List<Map<String, dynamic>> economicData;
  final bool isLoading;
  final String? error;

  const EconomicIndicators({
    super.key,
    required this.economicData,
    required this.isLoading,
    required this.error,
  });

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
                Text('Market Overview', style: AppTypography.h4.copyWith(color: AppColors.primary)),
                Icon(MdiIcons.trendingUp, color: AppColors.secondary, size: 20),
              ],
            ),
            const SizedBox(height: 16),
            if (isLoading)
              const Center(child: LoadingSpinner())
            else if (error != null)
              Text(
                error!,
                style: AppTypography.caption.copyWith(color: AppColors.error),
              )
            else
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.5, // Adjusted for two items
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
                          color: item['positive'] ? AppColors.success : AppColors.error,
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
}