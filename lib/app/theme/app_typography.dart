import 'package:flutter/material.dart';
import 'app_colors.dart';

/// TARL App Typography System
/// Modern, readable typography following Material Design 3 principles
class AppTypography {
  AppTypography._();

  // Font weights
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // Base font family
  static const String fontFamily = 'Inter'; // We'll use system font for now

  // Display styles (Large headlines)
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: bold,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: bold,
    height: 1.3,
    letterSpacing: -0.25,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 24,
    fontWeight: semiBold,
    height: 1.3,
  );

  // Headline styles
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 22,
    fontWeight: semiBold,
    height: 1.4,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: semiBold,
    height: 1.4,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 18,
    fontWeight: semiBold,
    height: 1.4,
  );

  // Title styles
  static const TextStyle titleLarge = TextStyle(
    fontSize: 16,
    fontWeight: semiBold,
    height: 1.5,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 14,
    fontWeight: medium,
    height: 1.5,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 12,
    fontWeight: medium,
    height: 1.5,
    letterSpacing: 0.5,
  );

  // Body styles
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: regular,
    height: 1.6,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: regular,
    height: 1.6,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: regular,
    height: 1.5,
  );

  // Label styles
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: medium,
    height: 1.4,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: medium,
    height: 1.4,
    letterSpacing: 0.5,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: medium,
    height: 1.4,
    letterSpacing: 0.5,
  );

  // Button styles
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: semiBold,
    height: 1.2,
    letterSpacing: 0.2,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontSize: 14,
    fontWeight: semiBold,
    height: 1.2,
    letterSpacing: 0.2,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: 12,
    fontWeight: semiBold,
    height: 1.2,
    letterSpacing: 0.2,
  );

  // Caption styles
  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: regular,
    height: 1.4,
    letterSpacing: 0.4,
  );

  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: medium,
    height: 1.4,
    letterSpacing: 1.5,
  );

  // Colored text styles
  static TextStyle get primaryText => bodyMedium.copyWith(
        color: AppColors.primaryBlue,
      );

  static TextStyle get successText => bodyMedium.copyWith(
        color: AppColors.statusSuccess,
      );

  static TextStyle get warningText => bodyMedium.copyWith(
        color: AppColors.statusWarning,
      );

  static TextStyle get errorText => bodyMedium.copyWith(
        color: AppColors.statusError,
      );

  static TextStyle get mutedText => bodySmall.copyWith(
        color: AppColors.neutralGray500,
      );
}
