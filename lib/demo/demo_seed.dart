import 'dart:math';
import 'package:store_tracker/models/product.dart';
import 'package:store_tracker/models/transaction.dart' as model;
import 'package:store_tracker/services/services.dart';

/// Seed realistic demo data into in-memory services (idempotent per run).
Future<void> seedDemoData() async {
  if (productService.list(includeInactive: true).isNotEmpty || transactionService.list().isNotEmpty) {
    return; // Already seeded this run
  }

  final now = DateTime.now();
  final rand = Random(42);

  // Products
  final products = <Product>[
    Product(
      branchId: 'default',
      id: 'P-001',
      name: 'Bottled Water 50cl',
      price: 150,
      currentStock: 25,
      reorderLevel: 20,
      description: 'Packaged drinking water',
      lastRestockDate: now.subtract(const Duration(days: 3)),
    ),
    Product(
      branchId: 'default',
      id: 'P-002',
      name: 'Soft Drink 50cl',
      price: 350,
      currentStock: 12,
      reorderLevel: 15,
      description: 'Assorted flavors',
      lastRestockDate: now.subtract(const Duration(days: 2)),
    ),
    Product(
      branchId: 'default',
      id: 'P-003',
      name: 'Bread Loaf',
      price: 900,
      currentStock: 6,
      reorderLevel: 8,
      lastRestockDate: now.subtract(const Duration(days: 1)),
    ),
    Product(
      branchId: 'default',
      id: 'P-004',
      name: 'Eggs (crate)',
      price: 3800,
      currentStock: 15,
      reorderLevel: 10,
      lastRestockDate: now.subtract(const Duration(days: 5)),
    ),
  ];

  for (final p in products) {
    productService.upsert(p);
  }

  // Helper to add income/expense transactions over the last 21 days
  DateTime start = now.subtract(const Duration(days: 20));
  for (int i = 0; i <= 20; i++) {
    final day = DateTime(start.year, start.month, start.day).add(Duration(days: i, hours: rand.nextInt(10) + 8));

    // Random sales 1-4 items per day
    final int numSales = rand.nextInt(4) + 1;
    for (int s = 0; s < numSales; s++) {
      final product = products[rand.nextInt(products.length)];
      final qty = rand.nextInt(3) + 1;
      final amount = product.price * qty;
      final tx = model.Transaction(
        branchId: 'default',
        id: 'S-${day.millisecondsSinceEpoch}-$s',
        amount: amount,
        type: 'income',
        category: 'Sale - ${product.name}',
        notes: 'Qty $qty',
        date: day.add(Duration(minutes: s * 15)),
      );
      transactionService.upsert(tx);
    }

    // Random expense every ~2 days
    if (i % 2 == 0) {
      final categories = ['Utilities', 'Transport', 'Supplies', 'Misc'];
      final expense = model.Transaction(
        branchId: 'default',
        id: 'E-${day.millisecondsSinceEpoch}',
        amount: (rand.nextInt(25) + 5) * 100.0,
        type: 'expense',
        category: categories[rand.nextInt(categories.length)],
        notes: rand.nextBool() ? 'Cash' : 'Transfer',
        date: day.add(const Duration(hours: 12)),
      );
      transactionService.upsert(expense);
    }
  }
}


