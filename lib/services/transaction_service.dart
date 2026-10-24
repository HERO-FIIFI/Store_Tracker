import 'package:collection/collection.dart';
import 'package:store_tracker/models/transaction.dart' as model;
import 'package:store_tracker/services/services.dart';

/// Transaction service with Hive persistence
class TransactionService {
  final Map<String, model.Transaction> _transactionsById = {};
  bool _initialized = false;

  /// Load transactions from Hive storage into memory
  void _loadFromStorage() {
    if (_initialized) return;
    final transactions = storageService.getAllTransactions();
    for (final transaction in transactions) {
      _transactionsById[transaction.id] = transaction;
    }
    _initialized = true;
  }

  // CRUD
  model.Transaction? getById(String id) {
    _loadFromStorage();
    return _transactionsById[id];
  }

  List<model.Transaction> list({DateTime? from, DateTime? to, String? branchId}) {
    _loadFromStorage();
    Iterable<model.Transaction> items = _transactionsById.values;
    if (branchId != null) {
      items = items.where((t) => t.branchId == branchId);
    }
    if (from != null) {
      items = items.where((t) => !t.date.isBefore(from));
    }
    if (to != null) {
      items = items.where((t) => !t.date.isAfter(to));
    }
    return items.sorted((a, b) => b.date.compareTo(a.date)).toList(growable: false);
  }

  void upsert(model.Transaction tx) {
    _loadFromStorage();
    _transactionsById[tx.id] = tx;
    // Persist to Hive
    storageService.saveTransaction(tx);
  }

  bool delete(String id) {
    _loadFromStorage();
    final removed = _transactionsById.remove(id) != null;
    if (removed) {
      // Persist deletion to Hive
      storageService.deleteTransaction(id);
    }
    return removed;
  }

  // Summaries
  double totalIncome({DateTime? from, DateTime? to, String? branchId}) {
    return list(from: from, to: to, branchId: branchId)
        .where((t) => t.type == 'income')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double totalExpense({DateTime? from, DateTime? to, String? branchId}) {
    return list(from: from, to: to, branchId: branchId)
        .where((t) => t.type == 'expense')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double profit({DateTime? from, DateTime? to, String? branchId}) {
    return totalIncome(from: from, to: to, branchId: branchId) - totalExpense(from: from, to: to, branchId: branchId);
  }

  /// Convenience helpers for "today" window.
  DateTime _startOfDay(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
  DateTime _endOfDay(DateTime dt) => DateTime(dt.year, dt.month, dt.day, 23, 59, 59, 999);

  double todayIncome() {
    final now = DateTime.now();
    return totalIncome(from: _startOfDay(now), to: _endOfDay(now));
  }

  double todayExpense() {
    final now = DateTime.now();
    return totalExpense(from: _startOfDay(now), to: _endOfDay(now));
  }

  double todayProfit() {
    final now = DateTime.now();
    return profit(from: _startOfDay(now), to: _endOfDay(now));
  }

  // ---------------------------------------------------------------------------
  // Analytics helpers
  // ---------------------------------------------------------------------------

  /// Returns a map of DateOnly -> total sales (income) for last [days] days (inclusive of today).
  Map<DateTime, double> salesByDay(int days, {String? branchId}) {
    final now = DateTime.now();
    final start = _startOfDay(now.subtract(Duration(days: days - 1)));
    final end = _endOfDay(now);
    final results = <DateTime, double>{};
    for (int i = 0; i < days; i++) {
      final d = _startOfDay(start.add(Duration(days: i)));
      results[d] = 0.0;
    }
    for (final t in list(from: start, to: end, branchId: branchId)) {
      if (t.type != 'income') continue;
      final key = _startOfDay(t.date);
      results[key] = (results[key] ?? 0) + t.amount;
    }
    return results;
  }

  /// Returns top-selling product names with total sales amounts derived from category labels: "Sale - <Product>".
  /// If your data includes non-sale income, it will be ignored here.
  List<MapEntry<String, double>> topSellingProducts({int limit = 5, String? branchId}) {
    final Map<String, double> totals = {};
    for (final t in _transactionsById.values) {
      if (branchId != null && t.branchId != branchId) continue;
      if (t.type != 'income') continue;
      final name = _extractProductNameFromSaleCategory(t.category);
      if (name == null) continue;
      totals[name] = (totals[name] ?? 0) + t.amount;
    }
    final entries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (entries.length <= limit) return entries;
    return entries.sublist(0, limit);
  }

  String? _extractProductNameFromSaleCategory(String category) {
    const prefix = 'Sale - ';
    if (category.startsWith(prefix)) {
      return category.substring(prefix.length).trim();
    }
    return null;
  }

  /// Expense totals grouped by category (top N)
  List<MapEntry<String, double>> expensesByCategory({int limit = 5, DateTime? from, DateTime? to, String? branchId}) {
    final Map<String, double> totals = {};
    for (final t in list(from: from, to: to, branchId: branchId)) {
      if (t.type != 'expense') continue;
      final key = (t.category.isEmpty ? 'Other' : t.category).trim();
      totals[key] = (totals[key] ?? 0) + t.amount;
    }
    final entries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (entries.length <= limit) return entries;
    return entries.sublist(0, limit);
  }
}


