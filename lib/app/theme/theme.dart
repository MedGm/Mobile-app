import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// Light Theme Configuration
final lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  
  // Color Scheme
  colorScheme: const ColorScheme.light(
    primary: AppColors.primaryBlue,
    onPrimary: AppColors.neutralWhite,
    primaryContainer: AppColors.primaryBlueLight,
    onPrimaryContainer: AppColors.neutralWhite,
    secondary: AppColors.secondaryTeal,
    onSecondary: AppColors.neutralWhite,
    secondaryContainer: AppColors.secondaryTealLight,
    onSecondaryContainer: AppColors.neutralWhite,
    surface: AppColors.lightSurface,
    onSurface: AppColors.lightOnSurface,
    surfaceVariant: AppColors.lightSurfaceVariant,
    onSurfaceVariant: AppColors.neutralGray700,
    background: AppColors.lightBackground,
    onBackground: AppColors.lightOnSurface,
    error: AppColors.statusError,
    onError: AppColors.neutralWhite,
    outline: AppColors.neutralGray300,
    shadow: AppColors.neutralGray200,
  ),

  // Typography
  textTheme: const TextTheme(
    displayLarge: AppTypography.displayLarge,
    displayMedium: AppTypography.displayMedium,
    displaySmall: AppTypography.displaySmall,
    headlineLarge: AppTypography.headlineLarge,
    headlineMedium: AppTypography.headlineMedium,
    headlineSmall: AppTypography.headlineSmall,
    titleLarge: AppTypography.titleLarge,
    titleMedium: AppTypography.titleMedium,
    titleSmall: AppTypography.titleSmall,
    bodyLarge: AppTypography.bodyLarge,
    bodyMedium: AppTypography.bodyMedium,
    bodySmall: AppTypography.bodySmall,
    labelLarge: AppTypography.labelLarge,
    labelMedium: AppTypography.labelMedium,
    labelSmall: AppTypography.labelSmall,
  ),

  // App Bar Theme
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.lightSurface,
    foregroundColor: AppColors.lightOnSurface,
    elevation: 0,
    centerTitle: false,
    systemOverlayStyle: SystemUiOverlayStyle.dark,
    titleTextStyle: AppTypography.headlineSmall,
  ),

  // Card Theme
  cardTheme: CardThemeData(
    color: AppColors.lightSurface,
    elevation: 2,
    shadowColor: AppColors.neutralGray200.withOpacity(0.5),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    margin: const EdgeInsets.symmetric(vertical: 4),
  ),

  // Elevated Button Theme
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryBlue,
      foregroundColor: AppColors.neutralWhite,
      elevation: 2,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: AppTypography.buttonMedium,
    ),
  ),

  // Outlined Button Theme
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primaryBlue,
      side: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: AppTypography.buttonMedium,
    ),
  ),

  // Text Button Theme
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primaryBlue,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: AppTypography.buttonMedium,
    ),
  ),

  // Input Decoration Theme
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.neutralGray50,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.neutralGray300),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.neutralGray300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.statusError),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    labelStyle: AppTypography.bodyMedium.copyWith(color: AppColors.neutralGray600),
    hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.neutralGray400),
  ),

  // Bottom Navigation Bar Theme
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.lightSurface,
    selectedItemColor: AppColors.primaryBlue,
    unselectedItemColor: AppColors.neutralGray400,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  ),

  // Divider Theme
  dividerTheme: const DividerThemeData(
    color: AppColors.neutralGray200,
    thickness: 1,
  ),

  // Icon Theme
  iconTheme: const IconThemeData(
    color: AppColors.neutralGray600,
    size: 24,
  ),
);

/// Dark Theme Configuration
final darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  
  // Color Scheme
  colorScheme: const ColorScheme.dark(
    primary: AppColors.primaryBlueLight,
    onPrimary: AppColors.darkBackground,
    primaryContainer: AppColors.primaryBlueDark,
    onPrimaryContainer: AppColors.darkOnSurface,
    secondary: AppColors.secondaryTealLight,
    onSecondary: AppColors.darkBackground,
    secondaryContainer: AppColors.secondaryTeal,
    onSecondaryContainer: AppColors.darkOnSurface,
    surface: AppColors.darkSurface,
    onSurface: AppColors.darkOnSurface,
    surfaceVariant: AppColors.darkSurfaceVariant,
    onSurfaceVariant: AppColors.neutralGray300,
    background: AppColors.darkBackground,
    onBackground: AppColors.darkOnSurface,
    error: AppColors.statusError,
    onError: AppColors.neutralWhite,
    outline: AppColors.neutralGray600,
    shadow: AppColors.neutralGray900,
  ),

  // Typography (same as light)
  textTheme: const TextTheme(
    displayLarge: AppTypography.displayLarge,
    displayMedium: AppTypography.displayMedium,
    displaySmall: AppTypography.displaySmall,
    headlineLarge: AppTypography.headlineLarge,
    headlineMedium: AppTypography.headlineMedium,
    headlineSmall: AppTypography.headlineSmall,
    titleLarge: AppTypography.titleLarge,
    titleMedium: AppTypography.titleMedium,
    titleSmall: AppTypography.titleSmall,
    bodyLarge: AppTypography.bodyLarge,
    bodyMedium: AppTypography.bodyMedium,
    bodySmall: AppTypography.bodySmall,
    labelLarge: AppTypography.labelLarge,
    labelMedium: AppTypography.labelMedium,
    labelSmall: AppTypography.labelSmall,
  ),

  // App Bar Theme
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.darkSurface,
    foregroundColor: AppColors.darkOnSurface,
    elevation: 0,
    centerTitle: false,
    systemOverlayStyle: SystemUiOverlayStyle.light,
    titleTextStyle: AppTypography.headlineSmall,
  ),

  // Card Theme
  cardTheme: CardThemeData(
    color: AppColors.darkSurface,
    elevation: 4,
    shadowColor: AppColors.neutralGray900.withOpacity(0.8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    margin: const EdgeInsets.symmetric(vertical: 4),
  ),

  // Elevated Button Theme
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryBlueLight,
      foregroundColor: AppColors.darkBackground,
      elevation: 3,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: AppTypography.buttonMedium,
    ),
  ),

  // Outlined Button Theme
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primaryBlueLight,
      side: const BorderSide(color: AppColors.primaryBlueLight, width: 1.5),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: AppTypography.buttonMedium,
    ),
  ),

  // Text Button Theme
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primaryBlueLight,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: AppTypography.buttonMedium,
    ),
  ),

  // Input Decoration Theme
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.darkSurfaceVariant,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.neutralGray600),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.neutralGray600),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primaryBlueLight, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.statusError),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    labelStyle: AppTypography.bodyMedium.copyWith(color: AppColors.neutralGray400),
    hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.neutralGray500),
  ),

  // Bottom Navigation Bar Theme
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.darkSurface,
    selectedItemColor: AppColors.primaryBlueLight,
    unselectedItemColor: AppColors.neutralGray500,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  ),

  // Divider Theme
  dividerTheme: const DividerThemeData(
    color: AppColors.neutralGray600,
    thickness: 1,
  ),

  // Icon Theme
  iconTheme: const IconThemeData(
    color: AppColors.neutralGray400,
    size: 24,
  ),
);
