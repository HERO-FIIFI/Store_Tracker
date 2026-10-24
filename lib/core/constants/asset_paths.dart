/// Centralized management of all application assets.
/// 
/// Benefits:
/// 1. Prevents hard-coded strings across the app
/// 2. Enables easy asset refactoring/renaming
/// 3. Provides autocomplete for all assets
/// 4. Catches missing assets at compile-time
class AssetPaths {
  // Private constructor to prevent instantiation
  AssetPaths._();

  // ---------------------------------------------------------------------------
  // Image Assets
  // ---------------------------------------------------------------------------
  static const String _baseImagePath = 'assets/images';
  
  static const String appLogo = '$_baseImagePath/logo.png';
  static const String emptyState = '$_baseImagePath/empty_state.svg';
  static const String authBackground = '$_baseImagePath/auth_bg.jpg';
  
  // Dashboard Icons
  static const String iconSales = '$_baseImagePath/icons/sales.png';
  static const String iconExpenses = '$_baseImagePath/icons/expenses.png';
  static const String iconProfit = '$_baseImagePath/icons/profit.png';
  static const String iconInventory = '$_baseImagePath/icons/inventory.png';
  
  // Category Placeholders
  static const String placeholderFood = '$_baseImagePath/placeholders/food.jpg';
  static const String placeholderElectronics = '$_baseImagePath/placeholders/electronics.jpg';
  static const String placeholderClothing = '$_baseImagePath/placeholders/clothing.jpg';

  // ---------------------------------------------------------------------------
  // Icon Assets (SVG)
  // ---------------------------------------------------------------------------
  static const String _baseIconPath = 'assets/icons';
  
  static const String icHome = '$_baseIconPath/home.svg';
  static const String icSales = '$_baseIconPath/sales.svg';
  static const String icInventory = '$_baseIconPath/inventory.svg';
  static const String icReports = '$_baseIconPath/reports.svg';
  static const String icSettings = '$_baseIconPath/settings.svg';
  
  // Action Icons
  static const String icAdd = '$_baseIconPath/add.svg';
  static const String icPrint = '$_baseIconPath/print.svg';
  static const String icExport = '$_baseIconPath/export.svg';

  // ---------------------------------------------------------------------------
  // Animation Files (Lottie/Rive)
  // ---------------------------------------------------------------------------
  static const String _baseAnimPath = 'assets/animations';
  
  static const String animSuccess = '$_baseAnimPath/success.json';
  static const String animLoading = '$_baseAnimPath/loading.riv';
  static const String animEmptyBox = '$_baseAnimPath/empty_box.json';

  // ---------------------------------------------------------------------------
  // Font Assets
  // ---------------------------------------------------------------------------
  static const String _baseFontPath = 'assets/fonts';
  
  static const String fontRegular = '$_baseFontPath/Inter-Regular.ttf';
  static const String fontBold = '$_baseFontPath/Inter-Bold.ttf';
  static const String fontMedium = '$_baseFontPath/Inter-Medium.ttf';

  // ---------------------------------------------------------------------------
  // Data Files (For Initial Setup)
  // ---------------------------------------------------------------------------
  static const String _baseDataPath = 'assets/data';
  
  static const String defaultCategories = '$_baseDataPath/categories.json';
  static const String demoBackup = '$_baseDataPath/demo_backup.csv';

  // ---------------------------------------------------------------------------
  // Helper Methods
  // ---------------------------------------------------------------------------

  /// Preloads all critical assets for smooth UX
  static Future<void> preloadAssets(BuildContext context) async {
    final assets = [
      appLogo,
      emptyState,
      animLoading,
      // Add other critical assets here
    ];
    
    await Future.wait([
      for (final asset in assets) precacheImage(AssetImage(asset), context),
      // For SVG: precachePicture() if using flutter_svg
    ]);
  }

  /// Gets the appropriate placeholder based on category
  static String getCategoryPlaceholder(String category) {
    return switch (category.toLowerCase()) {
      'food' => placeholderFood,
      'electronics' => placeholderElectronics,
      'clothing' => placeholderClothing,
      _ => emptyState,
    };
  }
}