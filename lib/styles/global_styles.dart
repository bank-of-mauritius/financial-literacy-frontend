import 'package:flutter/material.dart';
import 'package:financial_literacy_frontend/styles/colors.dart';
import 'package:financial_literacy_frontend/styles/typography.dart';

final ThemeData globalTheme = ThemeData(
  useMaterial3: true,
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.background,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    primary: AppColors.primary,
    onPrimary: AppColors.white,
    secondary: AppColors.secondary,
    onSecondary: AppColors.black,
    surface: AppColors.surface,
    onSurface: AppColors.text,
    error: AppColors.error,
    onError: AppColors.white,
    background: AppColors.background,
  ),
  cardTheme: CardThemeData(
    color: AppColors.white,
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
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
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
    fillColor: AppColors.lightGray,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: AppColors.white,
    indicatorColor: AppColors.primary.withOpacity(0.1),
    labelTextStyle: WidgetStateProperty.all(AppTypography.caption),
    iconTheme: WidgetStateProperty.all(const IconThemeData(color: AppColors.text)),
  ),
);