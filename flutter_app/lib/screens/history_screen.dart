import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/expense_provider.dart';
import '../models/expense.dart';
import '../core/theme.dart';
import '../widgets/glass_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Color _iconBg(String category) {
    switch (category.toLowerCase()) {
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
    final provider = Provider.of<ExpenseProvider>(context);
    final grouped = provider.groupedExpenses;

    // Filter by search query
    final filteredGrouped = <String, List<Expense>>{};
    grouped.forEach((label, expenses) {
      final filtered = expenses
          .where((e) =>
              _query.isEmpty ||
              e.title.toLowerCase().contains(_query) ||
              e.category.toLowerCase().contains(_query))
          .toList();
      if (filtered.isNotEmpty) filteredGrouped[label] = filtered;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('History',
                  style: TextStyle(
                      color: AppTheme.foreground,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _query = v.toLowerCase()),
                      style: const TextStyle(color: AppTheme.foreground),
                      decoration: InputDecoration(
                        hintText: 'Search expenses...',
                        hintStyle: const TextStyle(color: AppTheme.mutedForeground),
                        prefixIcon: const Icon(Icons.search,
                            color: AppTheme.mutedForeground, size: 20),
                        filled: true,
                        fillColor: AppTheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppTheme.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppTheme.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppTheme.primary),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GlassCard(
                    padding: const EdgeInsets.all(0),
                    borderRadius: 14,
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: const Icon(Icons.tune_rounded,
                          color: AppTheme.foreground, size: 20),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: filteredGrouped.isEmpty
              ? const Center(
                  child: Text('No expenses found',
                      style: TextStyle(color: AppTheme.mutedForeground)))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
                  itemCount: filteredGrouped.length,
                  itemBuilder: (ctx, groupIdx) {
                    final label = filteredGrouped.keys.elementAt(groupIdx);
                    final expenses = filteredGrouped[label]!;
                    final total =
                        expenses.fold(0.0, (sum, e) => sum + e.amount);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(label,
                                  style: const TextStyle(
                                      color: AppTheme.mutedForeground,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500)),
                              Text('₹${total.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                      color: AppTheme.primary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        ...expenses.map((e) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _HistoryTile(
                                expense: e,
                                iconBg: _iconBg(e.category),
                                dateLabel: label,
                              ),
                            )),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final Expense expense;
  final Color iconBg;
  final String dateLabel;

  const _HistoryTile({
    required this.expense,
    required this.iconBg,
    required this.dateLabel,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      borderRadius: 16,
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: iconBg,
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
                const SizedBox(height: 3),
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
              const SizedBox(height: 3),
              Text(dateLabel,
                  style: const TextStyle(
                      color: AppTheme.mutedForeground, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
