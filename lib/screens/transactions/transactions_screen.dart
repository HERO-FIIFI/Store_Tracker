import 'package:flutter/material.dart';
import 'package:store_tracker/models/transaction.dart' as model;
import 'package:store_tracker/core/constants/route_names.dart';
import 'package:store_tracker/models/product.dart';
import 'package:store_tracker/services/services.dart';
import 'package:store_tracker/services/app_settings.dart';
import 'package:store_tracker/services/export_service.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  DateTime? _from;
  DateTime? _to;
  Product? _productFilter;
  String _typeFilter = 'All'; // All | Income | Expenses
  String? _expenseCategoryFilter;

  @override
  void initState() {
    super.initState();
    // Read optional initial filters from route arguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map) {
        final typeArg = args['type'];
        if (typeArg is String && (typeArg == 'All' || typeArg == 'Income' || typeArg == 'Expenses')) {
          setState(() {
            _typeFilter = typeArg;
          });
        }
        final catArg = args['category'];
        if (catArg is String && catArg.isNotEmpty) {
          setState(() {
            _expenseCategoryFilter = catArg;
            _typeFilter = 'Expenses';
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final branchId = appSettings.currentBranchId;
    List<model.Transaction> items = transactionService.list(from: _from, to: _to, branchId: branchId);
    if (_typeFilter != 'All') {
      final wanted = _typeFilter.toLowerCase();
      items = items.where((t) => t.type.toLowerCase() == (wanted == 'expenses' ? 'expense' : 'income')).toList(growable: false);
    }
    if (_productFilter != null) {
      final name = _productFilter!.name.toLowerCase();
      items = items
          .where((tx) => tx.category.toLowerCase().contains(name))
          .toList(growable: false);
    }
    if (_expenseCategoryFilter != null && _typeFilter == 'Expenses') {
      items = items.where((t) => t.type == 'expense' && t.category == _expenseCategoryFilter).toList(growable: false);
    }
    final List<Product> products = productService.list(branchId: branchId);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            tooltip: 'Export CSV',
            icon: const Icon(Icons.download),
            onPressed: () => _exportCsv(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(products),
          if (_typeFilter == 'Expenses') _buildExpenseCategoryChips(),
          const Divider(height: 1),
          Expanded(
            child: items.isEmpty
                ? const Center(child: Text('No transactions found'))
                : ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final tx = items[index];
                      final isIncome = tx.type == 'income';
                      final color = isIncome ? Colors.green : Colors.red;
                      return ListTile(
                        leading: Icon(isIncome ? Icons.arrow_downward : Icons.arrow_upward, color: color),
                        title: Text(tx.category),
                        subtitle: Text(_formatDate(tx.date)),
                        trailing: Text('₦${tx.amount.toStringAsFixed(0)}', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMenu(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _exportCsv(BuildContext context) {
    final branchId = appSettings.currentBranchId;
    final items = transactionService.list(from: _from, to: _to, branchId: branchId);
    final csv = ExportService().transactionsToCsv(items);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Transactions CSV'),
          content: SingleChildScrollView(child: Text(csv)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ],
        );
      },
    );
  }

  Widget _buildFilters(List<Product> products) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: _pickDateRange,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date Range',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                child: Text(_dateRangeLabel()),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 140,
            child: DropdownButtonFormField<String>(
              value: _typeFilter,
              isDense: true,
              decoration: const InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: const [
                DropdownMenuItem(value: 'All', child: Text('All')),
                DropdownMenuItem(value: 'Income', child: Text('Income')),
                DropdownMenuItem(value: 'Expenses', child: Text('Expenses')),
              ],
              onChanged: (val) => setState(() => _typeFilter = val ?? 'All'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<Product?>(
              value: _productFilter,
              isDense: true,
              decoration: const InputDecoration(
                labelText: 'Product',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                const DropdownMenuItem<Product?>(value: null, child: Text('All products')),
                ...products.map((p) => DropdownMenuItem<Product?>(value: p, child: Text(p.name))),
              ],
              onChanged: (val) => setState(() => _productFilter = val),
            ),
          ),
          IconButton(
            tooltip: 'Clear filters',
            onPressed: () => setState(() {
              _from = null;
              _to = null;
              _productFilter = null;
              _typeFilter = 'All';
              _expenseCategoryFilter = null;
            }),
            icon: const Icon(Icons.clear),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseCategoryChips() {
    final top = transactionService.expensesByCategory(limit: 6, from: _from, to: _to);
    if (top.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ChoiceChip(
              label: const Text('All categories'),
              selected: _expenseCategoryFilter == null,
              onSelected: (_) => setState(() => _expenseCategoryFilter = null),
            ),
            const SizedBox(width: 8),
            ...top.map((e) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(e.key),
                    selected: _expenseCategoryFilter == e.key,
                    onSelected: (_) => setState(() => _expenseCategoryFilter = e.key),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 2);
    final lastDate = DateTime(now.year + 2);
    final initialDateRange = (_from != null && _to != null)
        ? DateTimeRange(start: _from!, end: _to!)
        : DateTimeRange(start: DateTime(now.year, now.month, 1), end: now);

    final picked = await showDateRangePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDateRange: initialDateRange,
    );
    if (picked != null) {
      setState(() {
        _from = DateTime(picked.start.year, picked.start.month, picked.start.day);
        _to = DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59, 59, 999);
      });
    }
  }

  String _dateRangeLabel() {
    if (_from == null || _to == null) return 'All time';
    String f(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    return '${f(_from!)} → ${f(_to!)}';
  }

  String _formatDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}  ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  void _showAddMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.point_of_sale),
                title: const Text('Record Sale'),
                onTap: () async {
                  Navigator.pop(context);
                  await Navigator.pushNamed(context, RouteNames.addDailySale);
                  setState(() {});
                },
              ),
              ListTile(
                leading: const Icon(Icons.money_off),
                title: const Text('Record Expense'),
                onTap: () async {
                  Navigator.pop(context);
                  await Navigator.pushNamed(context, RouteNames.addExpense);
                  setState(() {});
                },
              ),
            ],
          ),
        );
      },
    );
  }
}


