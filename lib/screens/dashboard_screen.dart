import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:store_tracker/core/constants/route_names.dart';
import 'package:store_tracker/models/product.dart';
import 'package:store_tracker/services/app_settings.dart';
import 'package:store_tracker/services/services.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _chartDays = 7; // 7 or 30
  int _summaryToggleIndex = 0; // 0 = Week, 1 = Month
  String _formatCurrency(double amount) {
    // Simple NGN formatting; replace with NumberFormat if intl is added.
    return 'â‚¦${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final String branch = branchService.currentBranchId;
    final double salesToday = transactionService.todayIncome();
    final double expensesToday = transactionService.todayExpense();
    final double profitToday = transactionService.todayProfit();
    final List<Product> lowStock = productService.lowStockItems(branchId: branch);

    // Weekly and monthly ranges (Mon-Sun week start)
    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: (now.weekday + 6) % 7));
    startOfWeek = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    DateTime endOfWeek = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day, 23, 59, 59, 999).add(const Duration(days: 6));

    DateTime startOfMonth = DateTime(now.year, now.month, 1);
    DateTime endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);

    final double weekSales = transactionService.totalIncome(from: startOfWeek, to: endOfWeek, branchId: branch);
    final double weekExpenses = transactionService.totalExpense(from: startOfWeek, to: endOfWeek, branchId: branch);
    final double weekProfit = weekSales - weekExpenses;

    final double monthSales = transactionService.totalIncome(from: startOfMonth, to: endOfMonth, branchId: branch);
    final double monthExpenses = transactionService.totalExpense(from: startOfMonth, to: endOfMonth, branchId: branch);
    final double monthProfit = monthSales - monthExpenses;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Store Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No new notifications')))
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, RouteNames.settings);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(
              sales: salesToday,
              expenses: expensesToday,
              profit: profitToday,
            ),
            const SizedBox(height: 16),
            _buildQuickActions(),
            const SizedBox(height: 16),
            _buildTopSellingProducts(),
            const SizedBox(height: 16),
            _buildSalesVsExpensesChart(),
            const SizedBox(height: 16),
            _buildTopExpenseCategories(),
            const SizedBox(height: 16),
            _buildRecentTransactions(),
            const SizedBox(height: 16),
            _buildLowStockAlert(lowStock),
            const SizedBox(height: 16),
            _buildPeriodSummaryCard(
              weekSales: weekSales,
              weekExpenses: weekExpenses,
              weekProfit: weekProfit,
              monthSales: monthSales,
              monthExpenses: monthExpenses,
              monthProfit: monthProfit,
            ),
            const SizedBox(height: 16),
            _buildProfitOverviewCard(
              today: profitToday,
              week: weekProfit,
              month: monthProfit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required double sales,
    required double expenses,
    required double profit,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Today\'s Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem('Sales', _formatCurrency(sales), Colors.green),
                _buildSummaryItem('Expenses', _formatCurrency(expenses), Colors.red),
                _buildSummaryItem('Profit', _formatCurrency(profit), Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, String amount, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 8),
        Text(
          amount,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  icon: Icons.add_circle,
                  label: 'Add Sale',
                  onTap: () {
                    Navigator.pushNamed(context, RouteNames.addDailySale);
                  },
                ),
                _buildActionButton(
                  icon: Icons.remove_circle,
                  label: 'Add Expense',
                  onTap: () {
                    Navigator.pushNamed(context, RouteNames.addExpense);
                  },
                ),
                _buildActionButton(
                  icon: Icons.inventory,
                  label: 'Stock',
                  onTap: () {
                    Navigator.pushNamed(context, RouteNames.inventory);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 32),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Transactions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, RouteNames.expenseList);
                  },
                  child: const Text('See All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildRecentTransactionItems(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactionItems() {
    final recent = transactionService.list(branchId: appSettings.currentBranchId).take(5).toList();
    if (recent.isEmpty) return const Center(child: Text(''No recent transactions''));
    return Column(children: recent.map((transaction) => ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(transaction.type == ''income'' ? Icons.arrow_downward : Icons.arrow_upward, color: transaction.type == ''income'' ? Colors.green : Colors.red),
      title: Text(transaction.category),
      subtitle: Text(''//''),
      trailing: Text(_formatCurrency(transaction.amount)),
    )).toList());
  }

  Widget _buildLowStockAlert(List<Product> lowStock) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Low Stock Alert',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, RouteNames.inventory);
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (lowStock.isEmpty)
              const Center(child: Text('No low stock items'))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: lowStock.length.clamp(0, 5),
                itemBuilder: (context, index) {
                  final item = lowStock[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.warning, color: Colors.orange),
                    title: Text(item.name),
                    subtitle: Text('Stock: ${item.currentStock}  â€¢  Reorder at: ${item.reorderLevel}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pushNamed(context, RouteNames.inventory);
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSellingProducts() {
    final top = transactionService.topSellingProducts(limit: 5, branchId: appSettings.currentBranchId);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Top Selling Products',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      RouteNames.expenseList,
                      arguments: {'type': 'Expenses'},
                    );
                  },
                  child: const Text('See All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (top.isEmpty)
              const Center(child: Text('No sales data'))
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: top.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final entry = top[index];
                  return ListTile(
                    dense: true,
                    title: Text(entry.key),
                    trailing: Text(_formatCurrency(entry.value), style: const TextStyle(fontWeight: FontWeight.bold)),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesVsExpensesChart() {
    final salesMap = transactionService.salesByDay(_chartDays, branchId: appSettings.currentBranchId);
    final now = DateTime.now();
    final days = List.generate(_chartDays, (i) {
      final d = DateTime(now.year, now.month, now.day).subtract(Duration(days: (_chartDays - 1) - i));
      return DateTime(d.year, d.month, d.day);
    });

    final expensesMap = <DateTime, double>{};
    for (final t in transactionService.list(from: days.first, to: days.last.add(const Duration(hours: 23, minutes: 59)), branchId: appSettings.currentBranchId)) {
      if (t.type != 'expense') continue;
      final key = DateTime(t.date.year, t.date.month, t.date.day);
      expensesMap[key] = (expensesMap[key] ?? 0) + t.amount;
    }

    final groups = List.generate(days.length, (i) {
      final day = days[i];
      final s = salesMap[day] ?? 0.0;
      final e = expensesMap[day] ?? 0.0;
      return BarChartGroupData(
        x: i,
        barsSpace: 4,
        barRods: [
          BarChartRodData(toY: s, color: Colors.green, width: 8, borderRadius: BorderRadius.circular(2)),
          BarChartRodData(toY: e, color: Colors.red, width: 8, borderRadius: BorderRadius.circular(2)),
        ],
      );
    });

    String labelFor(int i) {
      final d = days[i];
      const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return names[d.weekday - 1];
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Sales vs Expenses (${_chartDays == 7 ? '7 days' : '30 days'})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ToggleButtons(
                  isSelected: [_chartDays == 7, _chartDays == 30],
                  onPressed: (index) => setState(() => _chartDays = index == 0 ? 7 : 30),
                  constraints: const BoxConstraints(minHeight: 32, minWidth: 48),
                  children: const [Text('7D'), Text('30D')],
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  barGroups: groups,
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i < 0 || i >= days.length) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(labelFor(i), style: const TextStyle(fontSize: 11)),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(enabled: true),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: const [
                _LegendDot(color: Colors.green, label: 'Sales'),
                SizedBox(width: 16),
                _LegendDot(color: Colors.red, label: 'Expenses'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopExpenseCategories() {
    final top = transactionService.expensesByCategory(limit: 5, branchId: appSettings.currentBranchId);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Top Expense Categories',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, RouteNames.expenseList);;
                  },
                  child: const Text('See All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (top.isEmpty)
              const Center(child: Text('No expense data'))
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: top.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final entry = top[index];
                  return ListTile(
                    dense: true,
                    title: Text(entry.key),
                    trailing: Text(_formatCurrency(entry.value), style: const TextStyle(fontWeight: FontWeight.bold)),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSummaryCard({
    required double weekSales,
    required double weekExpenses,
    required double weekProfit,
    required double monthSales,
    required double monthExpenses,
    required double monthProfit,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Period Summary',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ToggleButtons(
                  isSelected: [_summaryToggleIndex == 0, _summaryToggleIndex == 1],
                  onPressed: (i) => setState(() => _summaryToggleIndex = i),
                  constraints: const BoxConstraints(minHeight: 32, minWidth: 56),
                  children: const [Text('Week'), Text('Month')],
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_summaryToggleIndex == 0)
              _buildSummaryBlock('This Week', weekSales, weekExpenses, weekProfit)
            else
              _buildSummaryBlock('This Month', monthSales, monthExpenses, monthProfit),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryBlock(String title, double sales, double expenses, double profit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text('Sales: ${_formatCurrency(sales)}', style: const TextStyle(color: Colors.green)),
        Text('Expenses: ${_formatCurrency(expenses)}', style: const TextStyle(color: Colors.red)),
        Text('Profit: ${_formatCurrency(profit)}', style: const TextStyle(color: Colors.blue)),
      ],
    );
  }

  Widget _buildProfitOverviewCard({required double today, required double week, required double month}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profit Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildProfitChip('Today', today),
                _buildProfitChip('Week', week),
                _buildProfitChip('Month', month),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfitChip(String label, double value) {
    final bool positive = value >= 0;
    final Color color = positive ? Colors.green : Colors.red;
    return Column(
      children: [
        Text(label),
        const SizedBox(height: 6),
        Text(
          _formatCurrency(value),
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}



