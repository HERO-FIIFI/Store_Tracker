import 'package:flutter/material.dart';

import 'app_colors.dart';

/// A utility class that holds text styles used across the app
/// Text styles are defined for both light and dark themes
class AppTextStyles {
  AppTextStyles._(); // Private constructor to prevent instantiation

  // Text style constants
  static const String _fontFamily = 'Roboto'; // Default font family
  static const double _displayLargeSize = 57.0;
  static const double _displayMediumSize = 45.0;
  static const double _displaySmallSize = 36.0;
  static const double _headlineLargeSize = 32.0;
  static const double _headlineMediumSize = 28.0;
  static const double _headlineSmallSize = 24.0;
  static const double _titleLargeSize = 22.0;
  static const double _titleMediumSize = 16.0;
  static const double _titleSmallSize = 14.0;
  static const double _bodyLargeSize = 16.0;
  static const double _bodyMediumSize = 14.0;
  static const double _bodySmallSize = 12.0;
  static const double _labelLargeSize = 14.0;
  static const double _labelMediumSize = 12.0;
  static const double _labelSmallSize = 11.0;

  // Font weights
  static const FontWeight _lightWeight = FontWeight.w300;
  static const FontWeight _regularWeight = FontWeight.w400;
  static const FontWeight _mediumWeight = FontWeight.w500;
  static const FontWeight _semiBoldWeight = FontWeight.w600;
  static const FontWeight _boldWeight = FontWeight.w700;

  // Display text styles
  static TextStyle get displayLarge => TextStyle(
        fontSize: _displayLargeSize,
        fontWeight: _regularWeight,
        fontFamily: _fontFamily,
        color: AppColors.textPrimary,
        letterSpacing: -0.25,
      );

  static TextStyle get displayMedium => TextStyle(
        fontSize: _displayMediumSize,
        fontWeight: _regularWeight,
        fontFamily: _fontFamily,
        color: AppColors.textPrimary,
      );

  static TextStyle get displaySmall => TextStyle(
        fontSize: _displaySmallSize,
        fontWeight: _regularWeight,
        fontFamily: _fontFamily,
        color: AppColors.textPrimary,
      );

  // Headline text styles
  static TextStyle get headlineLarge => TextStyle(
        fontSize: _headlineLargeSize,
        fontWeight: _regularWeight,
        fontFamily: _fontFamily,
        color: AppColors.textPrimary,
      );

  static TextStyle get headlineMedium => TextStyle(
        fontSize: _headlineMediumSize,
        fontWeight: _regularWeight,
        fontFamily: _fontFamily,
        color: AppColors.textPrimary,
      );

  static TextStyle get headlineSmall => TextStyle(
        fontSize: _headlineSmallSize,
        fontWeight: _mediumWeight,
        fontFamily: _fontFamily,
        color: AppColors.textPrimary,
      );

  // Title text styles
  static TextStyle get titleLarge => TextStyle(
        fontSize: _titleLargeSize,
        fontWeight: _mediumWeight,
        fontFamily: _fontFamily,
        color: AppColors.textPrimary,
      );

  static TextStyle get titleMedium => TextStyle(
        fontSize: _titleMediumSize,
        fontWeight: _mediumWeight,
        fontFamily: _fontFamily,
        color: AppColors.textPrimary,
        letterSpacing: 0.15,
      );

  static TextStyle get titleSmall => TextStyle(
        fontSize: _titleSmallSize,
        fontWeight: _mediumWeight,
        fontFamily: _fontFamily,
        color: AppColors.textPrimary,
        letterSpacing: 0.1,
      );

  // Body text styles
  static TextStyle get bodyLarge => TextStyle(
        fontSize: _bodyLargeSize,
        fontWeight: _regularWeight,
        fontFamily: _fontFamily,
        color: AppColors.textPrimary,
        letterSpacing: 0.5,
      );

  static TextStyle get bodyMedium => TextStyle(
        fontSize: _bodyMediumSize,
        fontWeight: _regularWeight,
        fontFamily: _fontFamily,
        color: AppColors.textPrimary,
        letterSpacing: 0.25,
      );

  static TextStyle get bodySmall => TextStyle(
        fontSize: _bodySmallSize,
        fontWeight: _regularWeight,
        fontFamily: _fontFamily,
        color: AppColors.textSecondary,
        letterSpacing: 0.4,
      );

  // Label text styles
  static TextStyle get labelLarge => TextStyle(
        fontSize: _labelLargeSize,
        fontWeight: _mediumWeight,
        fontFamily: _fontFamily,
        color: AppColors.textPrimary,
        letterSpacing: 0.1,
      );

  static TextStyle get labelMedium => TextStyle(
        fontSize: _labelMediumSize,
        fontWeight: _mediumWeight,
        fontFamily: _fontFamily,
        color: AppColors.textSecondary,
        letterSpacing: 0.5,
      );

  static TextStyle get labelSmall => TextStyle(
        fontSize: _labelSmallSize,
        fontWeight: _mediumWeight,
        fontFamily: _fontFamily,
        color: AppColors.textHint,
        letterSpacing: 0.5,
      );

  // App-specific text styles
  static TextStyle get buttonText => labelLarge.copyWith(
        fontWeight: _semiBoldWeight,
        letterSpacing: 0.1,
      );

  static TextStyle get appBarTitle => titleLarge.copyWith(
        fontWeight: _boldWeight,
        color: AppColors.onPrimaryLight,
      );

  static TextStyle get cardTitle => titleMedium.copyWith(
        fontWeight: _boldWeight,
      );

  static TextStyle get inputLabel => bodyMedium.copyWith(
        color: AppColors.textSecondary,
      );

  static TextStyle get inputText => bodyLarge.copyWith(
        color: AppColors.textPrimary,
      );

  static TextStyle get errorText => bodySmall.copyWith(
        color: AppColors._errorLight,
      );

  static TextStyle get successText => bodyMedium.copyWith(
        color: AppColors.success,
        fontWeight: _mediumWeight,
      );

  static TextStyle get warningText => bodyMedium.copyWith(
        color: AppColors.warning,
        fontWeight: _mediumWeight,
      );

  // Inventory-specific text styles
  static TextStyle get stockStatusInStock => bodySmall.copyWith(
        color: AppColors.inStock,
        fontWeight: _mediumWeight,
      );

  static TextStyle get stockStatusLowStock => bodySmall.copyWith(
        color: AppColors.lowStock,
        fontWeight: _mediumWeight,
      );

  static TextStyle get stockStatusOutOfStock => bodySmall.copyWith(
        color: AppColors.outOfStock,
        fontWeight: _mediumWeight,
      );

  // Dashboard-specific text styles
  static TextStyle get profitText => bodyMedium.copyWith(
        color: AppColors.profitColor,
        fontWeight: _boldWeight,
      );

  static TextStyle get lossText => bodyMedium.copyWith(
        color: AppColors.lossColor,
        fontWeight: _boldWeight,
      );

  static TextStyle get revenueText => titleMedium.copyWith(
        color: AppColors.revenueColor,
        fontWeight: _boldWeight,
      );

  /// Returns text theme for both light and dark modes
  static TextTheme get textTheme => TextTheme(
        displayLarge: displayLarge,
        displayMedium: displayMedium,
        displaySmall: displaySmall,
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        headlineSmall: headlineSmall,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        titleSmall: titleSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
      );

  /// Returns dark text theme (override colors for dark mode)
  static TextTheme get darkTextTheme => TextTheme(
        displayLarge: displayLarge.copyWith(color: AppColors.onBackgroundDark),
        displayMedium: displayMedium.copyWith(color: AppColors.onBackgroundDark),
        displaySmall: displaySmall.copyWith(color: AppColors.onBackgroundDark),
        headlineLarge: headlineLarge.copyWith(color: AppColors.onBackgroundDark),
        headlineMedium:
            headlineMedium.copyWith(color: AppColors.onBackgroundDark),
        headlineSmall: headlineSmall.copyWith(color: AppColors.onBackgroundDark),
        titleLarge: titleLarge.copyWith(color: AppColors.onBackgroundDark),
        titleMedium: titleMedium.copyWith(color: AppColors.onBackgroundDark),
        titleSmall: titleSmall.copyWith(color: AppColors.onBackgroundDark),
        bodyLarge: bodyLarge.copyWith(color: AppColors.onBackgroundDark),
        bodyMedium: bodyMedium.copyWith(color: AppColors.onBackgroundDark),
        bodySmall: bodySmall.copyWith(color: AppColors.textHint),
        labelLarge: labelLarge.copyWith(color: AppColors._onBackgroundDark),
        labelMedium: labelMedium.copyWith(color: AppColors.textHint),
        labelSmall: labelSmall.copyWith(color: AppColors.textHint),
      );
}