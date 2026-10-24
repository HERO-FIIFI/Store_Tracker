import 'package:flutter/material.dart';
import 'package:store_tracker/models/product.dart';
import 'package:store_tracker/models/transaction.dart' as model;
import 'package:store_tracker/services/services.dart';
import 'package:store_tracker/services/app_settings.dart';
import 'package:store_tracker/widgets/photo_picker_button.dart';

class RecordSaleScreen extends StatefulWidget {
  const RecordSaleScreen({super.key});

  @override
  State<RecordSaleScreen> createState() => _RecordSaleScreenState();
}

class _RecordSaleScreenState extends State<RecordSaleScreen> {
  final _formKey = GlobalKey<FormState>();
  Product? _selectedProduct;
  int _quantity = 1;
  String _paymentMode = 'Cash';
  final TextEditingController _customerCtrl = TextEditingController();
  String? _receiptPhotoPath;

  @override
  void dispose() {
    _customerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Product> products = productService.list(branchId: appSettings.currentBranchId);
    return Scaffold(
      appBar: AppBar(title: const Text('Record Sale')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<Product>(
              value: _selectedProduct,
              decoration: const InputDecoration(labelText: 'Product'),
              items: products
                  .map((p) => DropdownMenuItem(value: p, child: Text(p.name)))
                  .toList(),
              validator: (v) => v == null ? 'Select a product' : null,
              onChanged: (v) => setState(() => _selectedProduct = v),
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Quantity'),
              initialValue: '1',
              keyboardType: TextInputType.number,
              validator: (v) {
                final parsed = int.tryParse(v ?? '');
                if (parsed == null || parsed <= 0) return 'Enter a valid quantity';
                if (_selectedProduct != null && parsed > _selectedProduct!.currentStock) {
                  return 'Insufficient stock';
                }
                return null;
              },
              onChanged: (v) => _quantity = int.tryParse(v) ?? 1,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _paymentMode,
              decoration: const InputDecoration(labelText: 'Payment Mode'),
              items: const [
                DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                DropdownMenuItem(value: 'Transfer', child: Text('Transfer')),
                DropdownMenuItem(value: 'POS', child: Text('POS')),
              ],
              onChanged: (v) => setState(() => _paymentMode = v ?? 'Cash'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _customerCtrl,
              decoration: const InputDecoration(labelText: 'Customer (optional)'),
            ),
            const SizedBox(height: 16),
            PhotoPickerButton(
              label: 'Add Receipt Photo (optional)',
              onPhotoSelected: (photoPath) {
                setState(() {
                  _receiptPhotoPath = photoPath;
                });
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _onSubmit,
              child: const Text('Save Sale'),
            ),
          ],
        ),
      ),
    );
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;
    final product = _selectedProduct!;
    final total = product.price * _quantity;

    // Adjust stock
    productService.adjustStock(product.id, -_quantity);

    // Create transaction
    final tx = model.Transaction(
      branchId: appSettings.currentBranchId,
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: total,
      type: 'income',
      category: 'Sale - ${product.name}',
      notes: _customerCtrl.text.isEmpty ? null : 'Customer: ${_customerCtrl.text}; Payment: $_paymentMode',
      receiptUrl: _receiptPhotoPath,
      date: DateTime.now(),
    );
    transactionService.upsert(tx);

    if (mounted) Navigator.pop(context);
  }
}


