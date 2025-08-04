import 'package:flutter/material.dart';
import 'package:financial_literacy_frontend/styles/colors.dart';
import 'package:financial_literacy_frontend/styles/typography.dart';

final ThemeData globalTheme = ThemeData(
  useMaterial3: true,
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.background,
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.white,
    primaryContainer: AppColors.primaryLight,
    onPrimaryContainer: AppColors.text,
    secondary: AppColors.secondary,
    onSecondary: AppColors.text,
    secondaryContainer: AppColors.secondaryLight,
    onSecondaryContainer: AppColors.text,
    surface: AppColors.surface,
    onSurface: AppColors.text,
    error: AppColors.error,
    onError: AppColors.white,
    errorContainer: AppColors.errorLight,
    onErrorContainer: AppColors.text,
    surfaceContainerHighest: AppColors.lightGray,
    onSurfaceVariant: AppColors.textSecondary,
  ),
  cardTheme: CardThemeData(
    color: AppColors.surface,
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: const EdgeInsets.all(0),
  ),
  textTheme: const TextTheme(
    displayLarge: AppTypography.h1,
    displayMedium: AppTypography.h2,
    displaySmall: AppTypography.h3,
    headlineMedium: AppTypography.h4,
    headlineSmall: AppTypography.h5,
    titleLarge: AppTypography.h6,
    bodyLarge: AppTypography.body1,
    bodyMedium: AppTypography.body2,
    labelLarge: AppTypography.button,
    bodySmall: AppTypography.caption,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      textStyle: AppTypography.button,
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: AppColors.accent,
      foregroundColor: AppColors.text,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      textStyle: AppTypography.button,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: AppColors.border),
    ),
    filled: true,
    fillColor: AppColors.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: AppColors.surface,
    indicatorColor: AppColors.accent.withOpacity(0.2),
    labelTextStyle: WidgetStateProperty.all(AppTypography.caption),
    iconTheme: WidgetStateProperty.all(const IconThemeData(color: AppColors.text)),
  ),
);