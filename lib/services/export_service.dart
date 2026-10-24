import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:store_tracker/models/product.dart';
import 'package:store_tracker/models/transaction.dart' as model;

class ExportService {
  // CSV Export
  String transactionsToCsv(List<model.Transaction> items) {
    final buffer = StringBuffer();
    buffer.writeln('branchId,id,type,category,amount,notes,date');
    for (final t in items) {
      final dateIso = t.date.toIso8601String();
      final notes = (t.notes ?? '').replaceAll(',', ' ');
      buffer.writeln('${t.branchId},${t.id},${t.type},${t.category},${t.amount},${notes},${dateIso}');
    }
    return buffer.toString();
  }

  String productsToCsv(List<Product> items) {
    final buffer = StringBuffer();
    buffer.writeln('branchId,id,name,price,currentStock,reorderLevel,isActive,lastRestockDate,description');
    for (final p in items) {
      final desc = (p.description ?? '').replaceAll(',', ' ');
      buffer.writeln('${p.branchId},${p.id},${p.name},${p.price},${p.currentStock},${p.reorderLevel},${p.isActive},${p.lastRestockDate.toIso8601String()},${desc}');
    }
    return buffer.toString();
  }

  // JSON Export
  String transactionsToJson(List<model.Transaction> items) {
    final jsonList = items.map((t) => t.toMap()).toList();
    return const JsonEncoder.withIndent('  ').convert(jsonList);
  }

  String productsToJson(List<Product> items) {
    final jsonList = items.map((p) => p.toMap()).toList();
    return const JsonEncoder.withIndent('  ').convert(jsonList);
  }

  // JSON Import
  List<model.Transaction> transactionsFromJson(String jsonString) {
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => model.Transaction.fromMap(json)).toList();
    } catch (e) {
      throw Exception('Failed to parse transactions JSON: $e');
    }
  }

  List<Product> productsFromJson(String jsonString) {
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Product.fromMap(json)).toList();
    } catch (e) {
      throw Exception('Failed to parse products JSON: $e');
    }
  }

  // File Export with Share
  Future<void> exportTransactionsToFile(
    List<model.Transaction> items, {
    required String format, // 'csv' or 'json'
  }) async {
    try {
      final content = format == 'json'
          ? transactionsToJson(items)
          : transactionsToCsv(items);

      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'transactions_$timestamp.$format';
      final file = File('${directory.path}/$fileName');

      await file.writeAsString(content);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Store Tracker - Transactions Export',
      );
    } catch (e) {
      throw Exception('Failed to export transactions: $e');
    }
  }

  Future<void> exportProductsToFile(
    List<Product> items, {
    required String format, // 'csv' or 'json'
  }) async {
    try {
      final content = format == 'json'
          ? productsToJson(items)
          : productsToCsv(items);

      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'products_$timestamp.$format';
      final file = File('${directory.path}/$fileName');

      await file.writeAsString(content);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Store Tracker - Products Export',
      );
    } catch (e) {
      throw Exception('Failed to export products: $e');
    }
  }
}


