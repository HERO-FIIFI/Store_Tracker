/// Centralized route names for the application.
/// 
/// Benefits:
/// - Prevents hard-coded strings across the app
/// - Enables easy route renaming/refactoring
/// - Provides single source of truth for navigation
class RouteNames {
  // Static class - prevent instantiation
  RouteNames._();

  // ---------------------------------------------------------------------------
  // Auth Routes
  // ---------------------------------------------------------------------------
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String verifyEmail = '/verify-email';

  // ---------------------------------------------------------------------------
  // Main App Flow
  // ---------------------------------------------------------------------------
  static const String home = '/home';
  static const String dashboard = '/dashboard';
  static const String main = '/main'; // BottomNav wrapper

  // ---------------------------------------------------------------------------
  // Sales & Income
  // ---------------------------------------------------------------------------
  static const String addDailySale = '/sales/add';
  static const String saleHistory = '/sales/history';
  static const String saleDetails = '/sales/:id'; // Param example
  static const String editSale = '/sales/:id/edit';

  // ---------------------------------------------------------------------------
  // Expense Tracking
  // ---------------------------------------------------------------------------
  static const String addExpense = '/expenses/add';
  static const String expenseList = '/expenses';
  static const String expenseDetails = '/expenses/:id';
  static const String expenseCategory = '/expenses/category/:category';

  // ---------------------------------------------------------------------------
  // Inventory Management
  // ---------------------------------------------------------------------------
  static const String inventory = '/inventory';
  static const String addStockItem = '/inventory/add';
  static const String editStockItem = '/inventory/:id/edit';
  static const String stockHistory = '/inventory/:id/history';
  static const String lowStockAlert = '/inventory/low-stock';

  // ---------------------------------------------------------------------------
  // Reports & Analytics
  // ---------------------------------------------------------------------------
  static const String reports = '/reports';
  static const String profitLossReport = '/reports/profit-loss';
  static const String salesTrends = '/reports/sales-trends';
  static const String expenseReport = '/reports/expenses';
  static const String inventoryReport = '/reports/inventory';

  // ---------------------------------------------------------------------------
  // Settings & Profile
  // ---------------------------------------------------------------------------
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String backupSettings = '/settings/backup';
  static const String notificationSettings = '/settings/notifications';
  static const String branches = '/settings/branches';

  // ---------------------------------------------------------------------------
  // Utility Methods
  // ---------------------------------------------------------------------------

  /// Helper to replace params in route paths
  /// Example: RouteNames.withParams(RouteNames.saleDetails, {'id': '123'})
  static String withParams(String route, Map<String, String> params) {
    String result = route;
    params.forEach((key, value) {
      result = result.replaceAll(':$key', value);
    });
    return result;
  }

  /// Gets the base route without parameters
  /// Example: '/sales/123' → '/sales'
  static String getBaseRoute(String route) {
    final uri = Uri.parse(route);
    return uri.pathSegments.isNotEmpty ? '/${uri.pathSegments.first}' : '/';
  }
}