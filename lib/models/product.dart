import 'package:hive/hive.dart';

part 'product.g.dart';

@HiveType(typeId: 0)
class Product extends HiveObject {
  @HiveField(0)
  final String branchId;

  @HiveField(1)
  final String id;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final double price;

  @HiveField(4)
  final int currentStock;

  @HiveField(5)
  final int reorderLevel;

  @HiveField(6)
  final String? description;

  @HiveField(7)
  final DateTime lastRestockDate;

  @HiveField(8)
  final bool isActive;

  Product({
    this.branchId = 'default',
    required this.id,
    required this.name,
    required this.price,
    required this.currentStock,
    required this.reorderLevel,
    this.description,
    required this.lastRestockDate,
    this.isActive = true,
  });

  bool get needsRestock => currentStock <= reorderLevel;

  Map<String, dynamic> toMap() {
    return {
      'branchId': branchId,
      'id': id,
      'name': name,
      'price': price,
      'currentStock': currentStock,
      'reorderLevel': reorderLevel,
      'description': description,
      'lastRestockDate': lastRestockDate.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      branchId: map['branchId'] ?? 'default',
      id: map['id'],
      name: map['name'],
      price: map['price'].toDouble(),
      currentStock: map['currentStock'],
      reorderLevel: map['reorderLevel'],
      description: map['description'],
      lastRestockDate: DateTime.parse(map['lastRestockDate']),
      isActive: map['isActive'] ?? true,
    );
  }
}