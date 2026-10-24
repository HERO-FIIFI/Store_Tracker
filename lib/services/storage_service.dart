import 'package:hive_flutter/hive_flutter.dart';
import 'package:store_tracker/models/product.dart';
import 'package:store_tracker/models/transaction.dart';

class StorageService {
  static const String productsBox = 'products';
  static const String transactionsBox = 'transactions';
  static const String branchesBox = 'branches';

  static Future<void> initialize() async {
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ProductAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TransactionAdapter());
    }

    // Open boxes
    await Hive.openBox<Product>(productsBox);
    await Hive.openBox<Transaction>(transactionsBox);
    await Hive.openBox<String>(branchesBox);
  }

  // Product operations
  Future<void> saveProduct(Product product) async {
    final box = Hive.box<Product>(productsBox);
    await box.put(product.id, product);
  }

  Future<void> deleteProduct(String id) async {
    final box = Hive.box<Product>(productsBox);
    await box.delete(id);
  }

  List<Product> getAllProducts() {
    final box = Hive.box<Product>(productsBox);
    return box.values.toList();
  }

  Product? getProduct(String id) {
    final box = Hive.box<Product>(productsBox);
    return box.get(id);
  }

  // Transaction operations
  Future<void> saveTransaction(Transaction transaction) async {
    final box = Hive.box<Transaction>(transactionsBox);
    await box.put(transaction.id, transaction);
  }

  Future<void> deleteTransaction(String id) async {
    final box = Hive.box<Transaction>(transactionsBox);
    await box.delete(id);
  }

  List<Transaction> getAllTransactions() {
    final box = Hive.box<Transaction>(transactionsBox);
    return box.values.toList();
  }

  Transaction? getTransaction(String id) {
    final box = Hive.box<Transaction>(transactionsBox);
    return box.get(id);
  }

  // Branch operations
  Future<void> saveBranch(String branchId) async {
    final box = Hive.box<String>(branchesBox);
    await box.put(branchId, branchId);
  }

  Future<void> deleteBranch(String branchId) async {
    final box = Hive.box<String>(branchesBox);
    await box.delete(branchId);
  }

  List<String> getAllBranches() {
    final box = Hive.box<String>(branchesBox);
    return box.values.toList();
  }

  // Clear all data
  Future<void> clearAll() async {
    await Hive.box<Product>(productsBox).clear();
    await Hive.box<Transaction>(transactionsBox).clear();
    await Hive.box<String>(branchesBox).clear();
  }

  // Close boxes
  Future<void> close() async {
    await Hive.close();
  }
}
