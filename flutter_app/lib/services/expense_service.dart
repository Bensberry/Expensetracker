import 'dart:convert';
import '../models/expense.dart';
import 'api_client.dart';

class ExpenseService {
  final ApiClient _api = ApiClient();

  Future<List<Expense>> getExpenses() async {
    try {
      final response = await _api.get('/expense');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Expense.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Expense?> addExpense(Expense expense) async {
    try {
      final response = await _api.post('/expense', expense.toJson());
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Expense.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
