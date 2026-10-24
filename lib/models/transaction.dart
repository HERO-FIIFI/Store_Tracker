import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 1)
class Transaction extends HiveObject {
  @HiveField(0)
  final String branchId;

  @HiveField(1)
  final String id;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final String type; // 'income' or 'expense'

  @HiveField(4)
  final String category;

  @HiveField(5)
  final String? notes;

  @HiveField(6)
  final String? receiptUrl;

  @HiveField(7)
  final DateTime date;

  Transaction({
    this.branchId = 'default',
    required this.id,
    required this.amount,
    required this.type,
    required this.category,
    this.notes,
    this.receiptUrl,
    required this.date,
  });

  // For Firestore
  Map<String, dynamic> toMap() {
    return {
      'branchId': branchId,
      'id': id,
      'amount': amount,
      'type': type,
      'category': category,
      'notes': notes,
      'receiptUrl': receiptUrl,
      'date': Timestamp.fromDate(date),
    };
  }

  // For JSON export/import
  Map<String, dynamic> toJson() {
    return {
      'branchId': branchId,
      'id': id,
      'amount': amount,
      'type': type,
      'category': category,
      'notes': notes,
      'receiptUrl': receiptUrl,
      'date': date.toIso8601String(),
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    // Handle both Timestamp (from Firestore) and String (from JSON)
    DateTime parsedDate;
    if (map['date'] is Timestamp) {
      parsedDate = (map['date'] as Timestamp).toDate();
    } else if (map['date'] is String) {
      parsedDate = DateTime.parse(map['date']);
    } else {
      parsedDate = map['date'] as DateTime;
    }

    return Transaction(
      branchId: map['branchId'] ?? 'default',
      id: map['id'],
      amount: map['amount'].toDouble(),
      type: map['type'],
      category: map['category'],
      notes: map['notes'],
      receiptUrl: map['receiptUrl'],
      date: parsedDate,
    );
  }
}