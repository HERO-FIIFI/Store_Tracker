import 'package:flutter/material.dart';
import 'package:store_tracker/core/constants/route_names.dart';
import 'package:store_tracker/screens/expenses/record_expense_screen.dart';
import 'package:store_tracker/screens/home_screen.dart';
import 'package:store_tracker/screens/inventory/inventory_screen.dart';
import 'package:store_tracker/screens/sales/record_sale_screen.dart';
import 'package:store_tracker/screens/transactions/transactions_screen.dart';
import 'package:store_tracker/screens/settings/settings_screen.dart';

class AppRouter {
  Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case RouteNames.addDailySale:
        return MaterialPageRoute(builder: (_) => const RecordSaleScreen());
      case RouteNames.addExpense:
        return MaterialPageRoute(builder: (_) => const RecordExpenseScreen());
      case RouteNames.inventory:
        return MaterialPageRoute(builder: (_) => const InventoryScreen());
      case RouteNames.expenseList:
        return MaterialPageRoute(builder: (_) => const TransactionsScreen());
      case RouteNames.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      default:
        // Fallback to home
        return MaterialPageRoute(builder: (_) => const HomeScreen());
    }
  }
}


