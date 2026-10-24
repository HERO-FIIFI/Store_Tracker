import 'package:flutter/material.dart';

/// A utility class that holds colors used across the app
/// Colors are defined in light mode and dark mode variants
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // Light Theme Colors
  static const Color _primaryLight = Color(0xFF6200EE);
  static const Color _secondaryLight = Color(0xFF03DAC6);
  static const Color _accentLight = Color(0xFF018786);
  static const Color _errorLight = Color(0xFFB00020);
  static const Color _backgroundLight = Color(0xFFFFFFFF);
  static const Color _surfaceLight = Color(0xFFFFFFFF);
  static const Color _onPrimaryLight = Color(0xFFFFFFFF);
  static const Color _onSecondaryLight = Color(0xFF000000);
  static const Color _onBackgroundLight = Color(0xFF000000);
  static const Color _onSurfaceLight = Color(0xFF000000);
  static const Color _onErrorLight = Color(0xFFFFFFFF);

  // Dark Theme Colors
  static const Color _primaryDark = Color(0xFFBB86FC);
  static const Color _secondaryDark = Color(0xFF03DAC6);
  static const Color _accentDark = Color(0xFF03DAC6);
  static const Color _errorDark = Color(0xFFCF6679);
  static const Color _backgroundDark = Color(0xFF121212);
  static const Color _surfaceDark = Color(0xFF121212);
  static const Color _onPrimaryDark = Color(0xFF000000);
  static const Color _onSecondaryDark = Color(0xFF000000);
  static const Color _onBackgroundDark = Color(0xFFFFFFFF);
  static const Color _onSurfaceDark = Color(0xFFFFFFFF);
  static const Color _onErrorDark = Color(0xFF000000);

  // App Specific Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF2196F3);
  static const Color disabled = Color(0xFF9E9E9E);
  static const Color divider = Color(0xFFE0E0E0);
  
  // Inventory specific colors
  static const Color lowStock = Color(0xFFFF7043);
  static const Color outOfStock = Color(0xFFE53935);
  static const Color inStock = Color(0xFF43A047);
  
  // Dashboard specific colors
  static const Color profitColor = Color(0xFF4CAF50);
  static const Color lossColor = Color(0xFFF44336);
  static const Color revenueColor = Color(0xFF2196F3);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);

  /// Returns the color scheme based on the brightness
  static ColorScheme colorScheme(bool isDark) {
    return isDark ? _darkColorScheme : _lightColorScheme;
  }

  static const ColorScheme _lightColorScheme = ColorScheme(
    primary: _primaryLight,
    secondary: _secondaryLight,
    surface: _surfaceLight,
    background: _backgroundLight,
    error: _errorLight,
    onPrimary: _onPrimaryLight,
    onSecondary: _onSecondaryLight,
    onSurface: _onSurfaceLight,
    onBackground: _onBackgroundLight,
    onError: _onErrorLight,
    brightness: Brightness.light,
  );

  static const ColorScheme _darkColorScheme = ColorScheme(
    primary: _primaryDark,
    secondary: _secondaryDark,
    surface: _surfaceDark,
    background: _backgroundDark,
    error: _errorDark,
    onPrimary: _onPrimaryDark,
    onSecondary: _onSecondaryDark,
    onSurface: _onSurfaceDark,
    onBackground: _onBackgroundDark,
    onError: _onErrorDark,
    brightness: Brightness.dark,
  );

  /// Material color for primary color with swatches
  static const MaterialColor primarySwatch = MaterialColor(
    0xFF6200EE,
    <int, Color>{
      50: Color(0xFFF2E7FE),
      100: Color(0xFFD7B7FD),
      200: Color(0xFFBB86FC),
      300: Color(0xFF9E55FC),
      400: Color(0xFF8224FB),
      500: Color(0xFF6200EE),
      600: Color(0xFF5300E0),
      700: Color(0xFF4500D2),
      800: Color(0xFF3700C4),
      900: Color(0xFF2900B6),
    },
  );
}