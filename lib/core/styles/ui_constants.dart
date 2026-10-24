
import 'package:flutter/material.dart';

/// Contains all the UI constants used throughout the app
/// to maintain consistent spacing, dimensions, and other visual properties.

class UIConstants {
  // Padding and margin constants
  static const double extraSmallPadding = 4.0;
  static const double smallPadding = 8.0;
  static const double mediumPadding = 16.0;
  static const double largePadding = 24.0;
  static const double extraLargePadding = 32.0;

  // Border radius constants
  static const double smallBorderRadius = 4.0;
  static const double mediumBorderRadius = 8.0;
  static const double largeBorderRadius = 12.0;
  static const double extraLargeBorderRadius = 16.0;
  static const double circularBorderRadius = 50.0;

  // Elevation constants
  static const double lowElevation = 2.0;
  static const double mediumElevation = 4.0;
  static const double highElevation = 8.0;

  // Button dimensions
  static const double buttonHeight = 48.0;
  static const double smallButtonHeight = 36.0;
  static const double buttonMinWidth = 88.0;
  static const double iconButtonSize = 40.0;

  // Text field dimensions
  static const double textFieldHeight = 56.0;
  static const double denseTextFieldHeight = 48.0;

  // Icon sizes
  static const double smallIconSize = 16.0;
  static const double mediumIconSize = 24.0;
  static const double largeIconSize = 32.0;
  static const double extraLargeIconSize = 48.0;

  // App bar dimensions
  static const double appBarHeight = 56.0;
  static const double appBarElevation = 0.0;

  // Divider thickness
  static const double dividerThickness = 1.0;
  static const double thickDividerThickness = 2.0;

  // Animation durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Card dimensions
  static const double cardBorderRadius = 12.0;
  static const double cardElevation = 2.0;

  // Dialog dimensions
  static const double dialogBorderRadius = 16.0;
  static const double dialogElevation = 24.0;
  static const EdgeInsets dialogPadding = EdgeInsets.all(24.0);

  // Bottom sheet dimensions
  static const double bottomSheetBorderRadius = 16.0;
  static const EdgeInsets bottomSheetPadding = EdgeInsets.all(16.0);

  // Grid layout spacing
  static const double gridSpacing = 16.0;
  static const double smallGridSpacing = 8.0;

  // Custom edge insets
  static EdgeInsets get defaultPadding => const EdgeInsets.all(mediumPadding);
  static EdgeInsets get horizontalPadding => const EdgeInsets.symmetric(horizontal: mediumPadding);
  static EdgeInsets get verticalPadding => const EdgeInsets.symmetric(vertical: mediumPadding);
  static EdgeInsets get screenPadding => const EdgeInsets.all(largePadding);
  static EdgeInsets get cardPadding => const EdgeInsets.all(mediumPadding);
  static EdgeInsets get listItemPadding => const EdgeInsets.symmetric(
        horizontal: mediumPadding,
        vertical: smallPadding,
      );

  // Border side constants
  static BorderSide get defaultBorderSide => BorderSide(
        color: Colors.grey.shade300,
        width: 1.0,
      );

  // Shadow constants
  static List<BoxShadow> get defaultShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 4.0,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get strongShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 8.0,
          offset: const Offset(0, 4),
        ),
      ];

  // Aspect ratios
  static const double squareAspectRatio = 1.0;
  static const double wideAspectRatio = 16 / 9;
  static const double tallAspectRatio = 9 / 16;
}