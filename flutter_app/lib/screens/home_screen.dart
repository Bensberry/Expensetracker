import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/expense_provider.dart';
import '../models/expense.dart';
import '../core/theme.dart';
import '../widgets/glass_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        Provider.of<ExpenseProvider>(context, listen: false).fetchExpenses();
      }
    });
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    return provider.loading
        ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
        : SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_greeting(),
                            style: const TextStyle(
                                color: AppTheme.mutedForeground, fontSize: 14)),
                        const SizedBox(height: 2),
                        const Text('Expense Tracker',
                            style: TextStyle(
                                color: AppTheme.foreground,
                                fontSize: 26,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.primary, width: 1.5),
                        color: AppTheme.surface,
                      ),
                      child: const Icon(Icons.bolt,
                          color: AppTheme.primary, size: 22),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Stats Row
                Row(
                  children: [
                    _StatCard(
                      label: 'Total Spent',
                      value: '₹${provider.totalSpent.toStringAsFixed(0)}',
                      icon: Icons.wallet,
                      iconColor: AppTheme.primary,
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      label: 'This Month',
                      value: '₹${provider.thisMonthSpent.toStringAsFixed(0)}',
                      icon: Icons.calendar_month_rounded,
                      iconColor: const Color(0xFF7C4DFF),
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      label: 'Expenses',
                      value: '${provider.expenses.length}',
                      icon: Icons.receipt_long_rounded,
                      iconColor: AppTheme.green,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Weekly Spending Chart
                GlassCard(
                  padding: const EdgeInsets.all(18),
                  borderRadius: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 3,
                            height: 16,
                            decoration: const BoxDecoration(
                              color: AppTheme.primary,
                              borderRadius: BorderRadius.all(Radius.circular(2)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('Weekly Spending',
                              style: TextStyle(
                                  color: AppTheme.foreground,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 160,
                        child: _WeeklyChart(data: provider.weeklySpending),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Recent Expenses
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 3,
                          height: 16,
                          decoration: const BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.all(Radius.circular(2)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('Recent Expenses',
                            style: TextStyle(
                                color: AppTheme.foreground,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    if (provider.expenses.isNotEmpty)
                      Text(
                        '${provider.recentExpenses.length} of ${provider.expenses.length}',
                        style: const TextStyle(
                            color: AppTheme.mutedForeground, fontSize: 12),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                if (provider.expenses.isEmpty)
                  GlassCard(
                    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
                    borderRadius: 16,
                    child: const SizedBox(
                      width: double.infinity,
                      child: Column(
                        children: [
                          Icon(Icons.receipt_long_outlined,
                              color: AppTheme.mutedForeground, size: 48),
                          SizedBox(height: 12),
                          Text('No expenses yet',
                              style: TextStyle(
                                  color: AppTheme.foreground,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600)),
                          SizedBox(height: 4),
                          Text('Add your first expense or scan a receipt',
                              style: TextStyle(
                                  color: AppTheme.mutedForeground, fontSize: 13)),
                        ],
                      ),
                    ),
                  )
                else
                  ...provider.recentExpenses
                      .map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _ExpenseRow(expense: e),
                          )),
              ],
            ),
          );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        borderRadius: 16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 16),
            ),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(
                    color: AppTheme.mutedForeground, fontSize: 10)),
            const SizedBox(height: 2),
            Text(value,
                style: const TextStyle(
                    color: AppTheme.foreground,
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  final List<double> data;
  const _WeeklyChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final maxVal = data.isEmpty ? 0.0 : data.reduce((a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxVal == 0 ? 100 : maxVal * 1.3,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              interval: maxVal == 0 ? 25 : maxVal * 1.3 / 4,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: const TextStyle(
                    color: AppTheme.mutedForeground, fontSize: 10),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  days[value.toInt()],
                  style: const TextStyle(
                      color: AppTheme.mutedForeground, fontSize: 10),
                ),
              ),
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxVal == 0 ? 25 : maxVal * 1.3 / 4,
          getDrawingHorizontalLine: (_) => const FlLine(
              color: AppTheme.border, strokeWidth: 0.5),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(
          7,
          (i) => BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: data[i],
                color: AppTheme.primary,
                width: 22,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpenseRow extends StatelessWidget {
  final Expense expense;
  const _ExpenseRow({required this.expense});

  String _relativeDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expDate = DateTime(expense.date.year, expense.date.month, expense.date.day);
    final diff = today.difference(expDate).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '$diff days ago';
  }

  Color _iconBg() {
    switch (expense.category.toLowerCase()) {
      case 'coffee':
      case 'food':
      case 'groceries':
        return const Color(0xFF7C4B00);
      case 'ride':
      case 'transport':
      case 'fuel':
        return const Color(0xFF003C7C);
      case 'shopping':
        return const Color(0xFF5C0080);
      case 'subscription':
      case 'entertainment':
        return const Color(0xFF4A0060);
      default:
        return AppTheme.surfaceLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      borderRadius: 16,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _iconBg(),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(Expense.categoryEmoji(expense.category),
                  style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(expense.title,
                    style: const TextStyle(
                        color: AppTheme.foreground,
                        fontWeight: FontWeight.w600,
                        fontSize: 15)),
                const SizedBox(height: 2),
                Text(expense.category,
                    style: const TextStyle(
                        color: AppTheme.mutedForeground, fontSize: 13)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('₹${expense.amount.toStringAsFixed(0)}',
                  style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
              const SizedBox(height: 2),
              Text(_relativeDate(),
                  style: const TextStyle(
                      color: AppTheme.mutedForeground, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
