import 'package:flutter/material.dart';
import 'package:financial_literacy_frontend/styles/colors.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? elevation; // Add elevation parameter

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.elevation, // Default to null for optional use
  });

  @override
  Widget build(BuildContext context) {
    // Calculate boxShadow based on elevation (Material Design elevation mapping)
    final double effectiveElevation = elevation ?? 1; // Default to 1 if not specified
    final double blurRadius = effectiveElevation * 2;
    final double offsetY = effectiveElevation;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1 * (effectiveElevation / 4).clamp(0.1, 0.25)), // Adjust opacity with elevation
            offset: Offset(0, offsetY),
            blurRadius: blurRadius,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(20),
          child: child,
        ),
      ),
    );
  }
}