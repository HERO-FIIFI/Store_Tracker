import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._(); // Private constructor to prevent instantiation

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: AppColors._lightColorScheme,
        primarySwatch: AppColors.primarySwatch,
        scaffoldBackgroundColor: AppColors._backgroundLight,
        appBarTheme: _appBarTheme(false),
        cardTheme: _cardTheme(false),
        buttonTheme: _buttonTheme(),
        elevatedButtonTheme: _elevatedButtonTheme(false),
        textButtonTheme: _textButtonTheme(false),
        outlinedButtonTheme: _outlinedButtonTheme(false),
        inputDecorationTheme: _inputDecorationTheme(false),
        dividerTheme: _dividerTheme(false),
        floatingActionButtonTheme: _floatingActionButtonTheme(false),
        checkboxTheme: _checkboxTheme(false),
        radioTheme: _radioTheme(false),
        snackBarTheme: _snackBarTheme(false),
        bottomSheetTheme: _bottomSheetTheme(false),
        tabBarTheme: _tabBarTheme(false),
        tooltipTheme: _tooltipTheme(false),
        chipTheme: _chipTheme(false),
        progressIndicatorTheme: _progressIndicatorTheme(false),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        colorScheme: AppColors._darkColorScheme,
        primarySwatch: AppColors.primarySwatch,
        scaffoldBackgroundColor: AppColors._backgroundDark,
        appBarTheme: _appBarTheme(true),
        cardTheme: _cardTheme(true),
        buttonTheme: _buttonTheme(),
        elevatedButtonTheme: _elevatedButtonTheme(true),
        textButtonTheme: _textButtonTheme(true),
        outlinedButtonTheme: _outlinedButtonTheme(true),
        inputDecorationTheme: _inputDecorationTheme(true),
        dividerTheme: _dividerTheme(true),
        floatingActionButtonTheme: _floatingActionButtonTheme(true),
        checkboxTheme: _checkboxTheme(true),
        radioTheme: _radioTheme(true),
        snackBarTheme: _snackBarTheme(true),
        bottomSheetTheme: _bottomSheetTheme(true),
        tabBarTheme: _tabBarTheme(true),
        tooltipTheme: _tooltipTheme(true),
        chipTheme: _chipTheme(true),
        progressIndicatorTheme: _progressIndicatorTheme(true),
      );

  // Component themes
  static AppBarTheme _appBarTheme(bool isDark) => AppBarTheme(
        elevation: UIConstants.appBarElevation,
        centerTitle: true,
        backgroundColor: isDark
            ? AppColors._surfaceDark
            : AppColors._surfaceLight,
        foregroundColor: isDark
            ? AppColors._onSurfaceDark
            : AppColors._onSurfaceLight,
      );

  static CardTheme _cardTheme(bool isDark) => CardTheme(
        elevation: UIConstants.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.cardBorderRadius),
        ),
        color: isDark ? AppColors._surfaceDark : AppColors._surfaceLight,
        margin: EdgeInsets.zero,
      );

  static ButtonThemeData _buttonTheme() => ButtonThemeData(
        height: UIConstants.buttonHeight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.mediumBorderRadius),
        ),
      );

  static ElevatedButtonThemeData _elevatedButtonTheme(bool isDark) =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors._primaryLight,
          foregroundColor: AppColors._onPrimaryLight,
          elevation: UIConstants.mediumElevation,
          padding: UIConstants.defaultPadding,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(UIConstants.mediumBorderRadius),
          ),
          minimumSize: const Size.fromHeight(UIConstants.buttonHeight),
        ),
      );

  static TextButtonThemeData _textButtonTheme(bool isDark) =>
      TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: isDark
              ? AppColors._primaryDark
              : AppColors._primaryLight,
          padding: UIConstants.defaultPadding,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(UIConstants.mediumBorderRadius),
          ),
        ),
      );

  static OutlinedButtonThemeData _outlinedButtonTheme(bool isDark) =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark
              ? AppColors._primaryDark
              : AppColors._primaryLight,
          side: BorderSide(
            color: isDark
                ? AppColors._primaryDark
                : AppColors._primaryLight,
          ),
          padding: UIConstants.defaultPadding,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(UIConstants.mediumBorderRadius),
          ),
        ),
      );

  static InputDecorationTheme _inputDecorationTheme(bool isDark) =>
      InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? AppColors._surfaceDark
            : AppColors._surfaceLight,
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(UIConstants.mediumBorderRadius),
          borderSide: BorderSide.none,
        ),
        contentPadding: UIConstants.horizontalPadding,
        errorBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(UIConstants.mediumBorderRadius),
          borderSide: const BorderSide(color: AppColors.errorLight),
        ),
      );

  static DividerThemeData _dividerTheme(bool isDark) => DividerThemeData(
        thickness: UIConstants.dividerThickness,
        color: isDark ? Colors.grey[800] : Colors.grey[300],
        space: UIConstants.mediumPadding,
      );

  static FloatingActionButtonThemeData _floatingActionButtonTheme(
          bool isDark) =>
      FloatingActionButtonThemeData(
        backgroundColor: isDark
            ? AppColors._primaryDark
            : AppColors._primaryLight,
        foregroundColor: isDark
            ? AppColors._onPrimaryDark
            : AppColors._onPrimaryLight,
        elevation: UIConstants.highElevation,
      );

  static CheckboxThemeData _checkboxTheme(bool isDark) => CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) {
            return AppColors.disabled;
          }
          return isDark
              ? AppColors._primaryDark
              : AppColors._primaryLight;
        }),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(UIConstants.smallBorderRadius),
        ),
      );

  static RadioThemeData _radioTheme(bool isDark) => RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) {
            return AppColors.disabled;
          }
          return isDark
              ? AppColors._primaryDark
              : AppColors._primaryLight;
        }),
      );

  static SnackBarThemeData _snackBarTheme(bool isDark) =>
      SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(UIConstants.mediumBorderRadius),
        ),
        backgroundColor: isDark
            ? AppColors._surfaceDark
            : AppColors._surfaceLight,
        contentTextStyle: TextStyle(
          color: isDark
              ? AppColors._onSurfaceDark
              : AppColors._onSurfaceLight,
        ),
      );

  static BottomSheetThemeData _bottomSheetTheme(bool isDark) =>
      BottomSheetThemeData(
        backgroundColor: isDark
            ? AppColors._surfaceDark
            : AppColors._surfaceLight,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(UIConstants.bottomSheetBorderRadius),
          ),
        ),
      );

  static TabBarTheme _tabBarTheme(bool isDark) => TabBarTheme(
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            width: 2.0,
            color: isDark
                ? AppColors._primaryDark
                : AppColors._primaryLight,
          ),
        ),
        labelColor: isDark
            ? AppColors._primaryDark
            : AppColors._primaryLight,
        unselectedLabelColor: AppColors.textSecondary,
      );

  static TooltipThemeData _tooltipTheme(bool isDark) => TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark
              ? AppColors._surfaceDark
              : AppColors._surfaceLight,
          borderRadius:
              BorderRadius.circular(UIConstants.smallBorderRadius),
          boxShadow: UIConstants.defaultShadow,
        ),
        textStyle: TextStyle(
          color: isDark
              ? AppColors._onSurfaceDark
              : AppColors._onSurfaceLight,
        ),
      );

  static ChipThemeData _chipTheme(bool isDark) => ChipThemeData(
        backgroundColor: isDark
            ? Colors.grey[800]
            : Colors.grey[200],
        selectedColor: isDark
            ? AppColors._primaryDark
            : AppColors._primaryLight,
        secondarySelectedColor: isDark
            ? AppColors._secondaryDark
            : AppColors._secondaryLight,
        labelStyle: TextStyle(
          color: isDark
              ? AppColors._onSurfaceDark
              : AppColors._onSurfaceLight,
        ),
        secondaryLabelStyle: TextStyle(
          color: isDark
              ? AppColors._onPrimaryDark
              : AppColors._onPrimaryLight,
        ),
        brightness: isDark ? Brightness.dark : Brightness.light,
        padding: UIConstants.defaultPadding,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(UIConstants.circularBorderRadius),
        ),
      );

  static ProgressIndicatorThemeData _progressIndicatorTheme(
          bool isDark) =>
      ProgressIndicatorThemeData(
        color: isDark
            ? AppColors._primaryDark
            : AppColors._primaryLight,
        linearTrackColor: isDark
            ? Colors.grey[800]
            : Colors.grey[200],
        circularTrackColor: isDark
            ? Colors.grey[800]
            : Colors.grey[200],
      );
}