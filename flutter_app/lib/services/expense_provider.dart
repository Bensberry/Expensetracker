import '../models/expense.dart';
import 'package:flutter/foundation.dart';
import 'local_db_service.dart';
import 'api_client.dart';
import 'expense_service.dart';

class ExpenseProvider extends ChangeNotifier {

  List<Expense> _expenses = [];
  bool _loading = false;
  String? _error;

  List<Expense> get expenses => List.unmodifiable(_expenses);
  bool get loading => _loading;
  String? get error => _error;

  double get totalSpent => _expenses.fold(0, (sum, e) => sum + e.amount);

  double get thisMonthSpent {
    final now = DateTime.now();
    return _expenses
        .where((e) => e.date.month == now.month && e.date.year == now.year)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  // Weekly spending: last 7 days indexed Mon-Sun
  List<double> get weeklySpending {
    final now = DateTime.now();
    final List<double> data = List.filled(7, 0.0);
    for (final e in _expenses) {
      final diff = now.difference(e.date).inDays;
      if (diff < 7) {
        final weekday = e.date.weekday - 1; // Mon=0
        data[weekday] += e.amount;
      }
    }
    return data;
  }

  List<Expense> get recentExpenses {
    final sorted = [..._expenses]..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(4).toList();
  }

  // Group expenses by date label
  Map<String, List<Expense>> get groupedExpenses {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final Map<String, List<Expense>> grouped = {};
    final sorted = [..._expenses]..sort((a, b) => b.date.compareTo(a.date));

    for (final e in sorted) {
      final expDate = DateTime(e.date.year, e.date.month, e.date.day);
      final diff = today.difference(expDate).inDays;
      String label;
      if (diff == 0) {
        label = 'Today';
      } else if (diff == 1) {
        label = 'Yesterday';
      } else {
        label = '$diff days ago';
      }
      grouped.putIfAbsent(label, () => []).add(e);
    }
    return grouped;
  }

  Future<void> fetchExpenses() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final remoteExpenses = await ExpenseService().getExpenses();
      if (remoteExpenses.isNotEmpty) {
        await LocalDbService().clearAllExpenses();
        for (final exp in remoteExpenses) {
          await LocalDbService().insertExpense(exp);
        }
        _expenses = remoteExpenses;
      } else {
        final local = await LocalDbService().getAllExpenses();
        _expenses = local;
      }
    } catch (e) {
      debugPrint('Exception fetching expenses from API, falling back to local: $e');
      final local = await LocalDbService().getAllExpenses();
      _expenses = local;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> addExpense(Expense expense) async {
    final tempId = DateTime.now().millisecondsSinceEpoch;
    final localExpense = expense.copyWith(id: tempId);
    _expenses.add(localExpense);
    notifyListeners();
    try {
      final remoteExpense = await ExpenseService().addExpense(expense);
      if (remoteExpense != null) {
        final insertedId = await LocalDbService().insertExpense(remoteExpense);
        final idx = _expenses.indexWhere((e) => e.id == tempId);
        if (idx >= 0) {
          _expenses[idx] = remoteExpense.copyWith(id: insertedId);
          notifyListeners();
        }
      } else {
        final insertedId = await LocalDbService().insertExpense(expense);
        final idx = _expenses.indexWhere((e) => e.id == tempId);
        if (idx >= 0) {
          _expenses[idx] = expense.copyWith(id: insertedId);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Exception adding expense, falling back to local: $e');
      final insertedId = await LocalDbService().insertExpense(expense);
      final idx = _expenses.indexWhere((e) => e.id == tempId);
      if (idx >= 0) {
        _expenses[idx] = expense.copyWith(id: insertedId);
        notifyListeners();
      }
    }
    return true;
  }

  Future<bool> deleteExpense(int id) async {
    _expenses.removeWhere((e) => e.id == id);
    notifyListeners();
    try {
      await ApiClient().delete('/expense/$id');
    } catch (e) {
      debugPrint('Exception deleting expense on server: $e');
    }
    try {
      await LocalDbService().deleteExpense(id);
    } catch (_) {}
    return true;
  }

  Future<void> clearAllExpenses() async {
    try {
      await ApiClient().post('/admin/clear-my-data', {});
    } catch (e) {
      debugPrint('Exception clearing data on server: $e');
    }
    try {
      await LocalDbService().clearAllExpenses();
    } catch (_) {}
    _expenses.clear();
    notifyListeners();
  }
}
