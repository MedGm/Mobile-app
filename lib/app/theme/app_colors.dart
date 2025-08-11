import 'package:flutter/material.dart';

/// TARL App Color Palette
/// Professional blue-based theme with excellent contrast and accessibility
class AppColors {
  AppColors._();

  // Primary Blue Palette
  static const Color primaryBlue = Color(0xFF1E3A8A); // Rich royal blue
  static const Color primaryBlueLight = Color(0xFF3B82F6); // Bright blue
  static const Color primaryBlueDark = Color(0xFF1E40AF); // Deep blue
  
  // Secondary Colors
  static const Color secondaryTeal = Color(0xFF0891B2); // Modern teal
  static const Color secondaryTealLight = Color(0xFF06B6D4); // Light teal
  static const Color accentGreen = Color(0xFF059669); // Success green
  static const Color accentOrange = Color(0xFFF59E0B); // Warning orange
  static const Color accentRed = Color(0xFFDC2626); // Error red

  // Neutral Colors
  static const Color neutralWhite = Color(0xFFFFFFFF);
  static const Color neutralGray50 = Color(0xFFF9FAFB);
  static const Color neutralGray100 = Color(0xFFF3F4F6);
  static const Color neutralGray200 = Color(0xFFE5E7EB);
  static const Color neutralGray300 = Color(0xFFD1D5DB);
  static const Color neutralGray400 = Color(0xFF9CA3AF);
  static const Color neutralGray500 = Color(0xFF6B7280);
  static const Color neutralGray600 = Color(0xFF4B5563);
  static const Color neutralGray700 = Color(0xFF374151);
  static const Color neutralGray800 = Color(0xFF1F2937);
  static const Color neutralGray900 = Color(0xFF111827);

  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF0F172A); // Very dark blue
  static const Color darkSurface = Color(0xFF1E293B); // Dark blue-gray
  static const Color darkSurfaceVariant = Color(0xFF334155); // Medium dark
  static const Color darkOnSurface = Color(0xFFE2E8F0); // Light gray text

  // Light Mode Colors
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = neutralWhite;
  static const Color lightSurfaceVariant = neutralGray50;
  static const Color lightOnSurface = neutralGray900;

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryBlue, primaryBlueDark],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF059669)],
  );

  static const LinearGradient warningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
  );

  // Status Colors
  static const Color statusSuccess = accentGreen;
  static const Color statusWarning = accentOrange;
  static const Color statusError = accentRed;
  static const Color statusInfo = primaryBlueLight;

  // Test Progress Colors
  static const Color progressExcellent = Color(0xFF10B981); // Green
  static const Color progressGood = Color(0xFF3B82F6); // Blue
  static const Color progressNeedsWork = Color(0xFFF59E0B); // Orange
  static const Color progressPoor = Color(0xFFEF4444); // Red
}
