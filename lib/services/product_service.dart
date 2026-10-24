import 'package:collection/collection.dart';
import 'package:store_tracker/models/product.dart';
import 'package:store_tracker/services/services.dart';

/// Product service with Hive persistence
class ProductService {
  final Map<String, Product> _productsById = {};
  bool _initialized = false;

  /// Load products from Hive storage into memory
  void _loadFromStorage() {
    if (_initialized) return;
    final products = storageService.getAllProducts();
    for (final product in products) {
      _productsById[product.id] = product;
    }
    _initialized = true;
  }

  // CRUD
  Product? getById(String id) {
    _loadFromStorage();
    return _productsById[id];
  }

  List<Product> list({bool includeInactive = false, String? branchId}) {
    _loadFromStorage();
    Iterable<Product> items = _productsById.values;
    if (branchId != null) {
      items = items.where((p) => p.branchId == branchId);
    }
    if (includeInactive) return items.toList(growable: false);
    return items.where((p) => p.isActive).toList(growable: false);
  }

  void upsert(Product product) {
    _loadFromStorage();
    _productsById[product.id] = product;
    // Persist to Hive
    storageService.saveProduct(product);
  }

  bool delete(String id) {
    _loadFromStorage();
    final removed = _productsById.remove(id) != null;
    if (removed) {
      // Persist deletion to Hive
      storageService.deleteProduct(id);
    }
    return removed;
  }

  // Inventory helpers
  List<Product> lowStockItems({String? branchId}) {
    _loadFromStorage();
    return _productsById.values
        .where((p) => branchId == null || p.branchId == branchId)
        .where((p) => p.isActive && p.needsRestock)
        .sorted((a, b) => a.currentStock.compareTo(b.currentStock))
        .toList(growable: false);
  }

  /// Adjust stock by [delta]. Positive to restock, negative for sales.
  /// Returns updated product or null if not found.
  Product? adjustStock(String id, int delta, {DateTime? restockDateIfIncrease}) {
    _loadFromStorage();
    final current = _productsById[id];
    if (current == null) return null;

    final newStock = current.currentStock + delta;
    if (newStock < 0) {
      throw StateError('Stock cannot go below zero for product: ${current.name}');
    }

    final updated = Product(
      branchId: current.branchId,
      id: current.id,
      name: current.name,
      price: current.price,
      currentStock: newStock,
      reorderLevel: current.reorderLevel,
      description: current.description,
      lastRestockDate: delta > 0
          ? (restockDateIfIncrease ?? DateTime.now())
          : current.lastRestockDate,
      isActive: current.isActive,
    );
    _productsById[id] = updated;
    // Persist to Hive
    storageService.saveProduct(updated);
    return updated;
  }
}


