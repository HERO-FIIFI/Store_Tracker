import 'package:flutter/material.dart';
import 'package:store_tracker/models/product.dart';
import 'package:store_tracker/services/services.dart';
import 'package:store_tracker/services/app_settings.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  @override
  Widget build(BuildContext context) {
    final branchId = appSettings.currentBranchId;
    final List<Product> products = productService.list(includeInactive: true, branchId: branchId);
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory')),
      body: products.isEmpty
          ? const Center(child: Text('No products yet'))
          : ListView.separated(
              itemCount: products.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final p = products[index];
                return ListTile(
                  title: Text(p.name),
                  subtitle: Text('Stock: ${p.currentStock}  •  ₦${p.price.toStringAsFixed(0)}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      await _showAddEditDialog(context, existing: p);
                      setState(() {});
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _showAddEditDialog(context);
          setState(() {});
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddEditDialog(BuildContext context, {Product? existing}) async {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final priceCtrl = TextEditingController(text: existing?.price.toString() ?? '');
    final stockCtrl = TextEditingController(text: existing?.currentStock.toString() ?? '');
    final reorderCtrl = TextEditingController(text: existing?.reorderLevel.toString() ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(existing == null ? 'Add Product' : 'Edit Product'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (v) => (v == null || v.isEmpty) ? 'Enter name' : null,
                  ),
                  TextFormField(
                    controller: priceCtrl,
                    decoration: const InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                    validator: (v) => (double.tryParse(v ?? '') ?? 0) <= 0 ? 'Enter valid price' : null,
                  ),
                  TextFormField(
                    controller: stockCtrl,
                    decoration: const InputDecoration(labelText: 'Current Stock'),
                    keyboardType: TextInputType.number,
                    validator: (v) => (int.tryParse(v ?? '') ?? -1) < 0 ? 'Enter valid stock' : null,
                  ),
                  TextFormField(
                    controller: reorderCtrl,
                    decoration: const InputDecoration(labelText: 'Reorder Level'),
                    keyboardType: TextInputType.number,
                    validator: (v) => (int.tryParse(v ?? '') ?? -1) < 0 ? 'Enter valid level' : null,
                  ),
                  TextFormField(
                    controller: descCtrl,
                    decoration: const InputDecoration(labelText: 'Description (optional)'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                final product = Product(
                  branchId: appSettings.currentBranchId,
                  id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameCtrl.text,
                  price: double.parse(priceCtrl.text),
                  currentStock: int.parse(stockCtrl.text),
                  reorderLevel: int.parse(reorderCtrl.text),
                  description: descCtrl.text.isEmpty ? null : descCtrl.text,
                  lastRestockDate: DateTime.now(),
                  isActive: true,
                );
                productService.upsert(product);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}


