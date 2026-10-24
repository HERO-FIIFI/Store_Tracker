import 'package:flutter/material.dart';
import 'package:store_tracker/models/transaction.dart' as model;
import 'package:store_tracker/services/services.dart';
import 'package:store_tracker/widgets/voice_input_button.dart';
import 'package:store_tracker/widgets/photo_picker_button.dart';

class RecordExpenseScreen extends StatefulWidget {
  const RecordExpenseScreen({super.key});

  @override
  State<RecordExpenseScreen> createState() => _RecordExpenseScreenState();
}

class _RecordExpenseScreenState extends State<RecordExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _categoryCtrl = TextEditingController();
  final TextEditingController _amountCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();
  String? _receiptPhotoPath;

  @override
  void dispose() {
    _categoryCtrl.dispose();
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Record Expense')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _categoryCtrl,
              decoration: InputDecoration(
                labelText: 'Category',
                suffixIcon: VoiceInputButton(
                  type: VoiceInputType.text,
                  onResult: (value) {
                    setState(() {
                      _categoryCtrl.text = value;
                    });
                  },
                ),
              ),
              validator: (v) => (v == null || v.isEmpty) ? 'Enter a category' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountCtrl,
              decoration: InputDecoration(
                labelText: 'Amount',
                suffixIcon: VoiceInputButton(
                  type: VoiceInputType.numeric,
                  onResult: (value) {
                    setState(() {
                      _amountCtrl.text = value;
                    });
                  },
                  onPartialResult: (value) {
                    setState(() {
                      _amountCtrl.text = value;
                    });
                  },
                ),
              ),
              keyboardType: TextInputType.number,
              validator: (v) {
                final parsed = double.tryParse(v ?? '');
                if (parsed == null || parsed <= 0) return 'Enter a valid amount';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesCtrl,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
              maxLines: 3,
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
              child: const Text('Save Expense'),
            ),
          ],
        ),
      ),
    );
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.parse(_amountCtrl.text);
    final tx = model.Transaction(
      branchId: appSettings.currentBranchId,
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      type: 'expense',
      category: _categoryCtrl.text,
      notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
      receiptUrl: _receiptPhotoPath,
      date: DateTime.now(),
    );
    transactionService.upsert(tx);
    if (mounted) Navigator.pop(context);
  }
}


