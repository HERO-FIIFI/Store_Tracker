/// Application-wide constants
/// 
/// Guidelines:
/// 1. Use groups with clear section comments
/// 2. Add descriptions for non-obvious constants
/// 3. Keep alphabetized within sections
/// 4. Use `static const` for all declarations
class AppConstants {
  // ---------------------------------------------------------------------------
  // App Configuration
  // ---------------------------------------------------------------------------
  static const String appName = 'Store Tracker';
  static const String appVersion = '1.0.0';
  static const int appBuildNumber = 1;
  static const String appContactEmail = 'support@storetracker.com';
  
  // ---------------------------------------------------------------------------
  // Storage & Database
  // ---------------------------------------------------------------------------
  /// Hive type IDs (must be unique across all models)
  static const int hiveTypeDailyLog = 0;
  static const int hiveTypeExpense = 1;
  static const int hiveTypeStockItem = 2;
  
  /// Hive box names
  static const String hiveBoxSettings = 'settings';
  static const String hiveBoxDailyLogs = 'daily_logs';
  
  /// Firestore collection names
  static const String firestoreUsersCollection = 'users';
  static const String firestoreLogsCollection = 'logs';
  static const String firestoreStockCollection = 'inventory';
  
  // ---------------------------------------------------------------------------
  // Financial Defaults
  // ---------------------------------------------------------------------------
  static const List<String> defaultIncomeCategories = [
    'Cash Sales',
    'Mobile Money',
    'Bank Transfer',
    'Credit Sales'
  ];
  
  static const List<String> defaultExpenseCategories = [
    'Restock',
    'Rent',
    'Utilities',
    'Transport',
    'Salaries',
    'Maintenance',
    'Personal'
  ];
  
  static const double defaultTaxRate = 0.15; // 15%
  
  // ---------------------------------------------------------------------------
  // Inventory Defaults
  // ---------------------------------------------------------------------------
  static const int defaultLowStockThreshold = 5;
  static const int maxProductNameLength = 50;
  static const int maxBarcodeLength = 20;
  
  // ---------------------------------------------------------------------------
  // UI/UX Constants
  // ---------------------------------------------------------------------------
  /// Animation durations
  static const Duration animationDurationFast = Duration(milliseconds: 150);
  static const Duration animationDurationMedium = Duration(milliseconds: 300);
  static const Duration animationDurationSlow = Duration(milliseconds: 500);
  
  /// Debounce timers (for search/buttons)
  static const Duration debounceTime = Duration(milliseconds: 500);
  
  /// Default page limits
  static const int defaultPageSize = 20;
  static const int maxDailyLogsDisplay = 7;
  
  // ---------------------------------------------------------------------------
  // Validation Rules
  // ---------------------------------------------------------------------------
  static const int minPasswordLength = 6;
  static const int maxReceiptNoteLength = 200;
  static const int maxTransactionAmount = 1000000; // 1,000,000
  
  // ---------------------------------------------------------------------------
  // Local Notifications
  // ---------------------------------------------------------------------------
  static const String dailyReminderId = 'daily_reminder';
  static const String lowStockAlertId = 'low_stock_alert';
  static const TimeOfDay dailyReminderTime = TimeOfDay(hour: 20, minute: 0); // 8 PM
  
  // ---------------------------------------------------------------------------
  // API/Service Keys (Non-sensitive only)
  // ---------------------------------------------------------------------------
  static const String currencyApiKey = 'pub_1234567890'; // Example public key
  static const String sentryDsn = 'https://example@sentry.io/123456';
  
  // ---------------------------------------------------------------------------
  // Feature Flags
  // ---------------------------------------------------------------------------
  static const bool enableCloudSync = true;
  static const bool enableBiometricAuth = true;
  static const bool enableExperimentalFeatures = false;
}