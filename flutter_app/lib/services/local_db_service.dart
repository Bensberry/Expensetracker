import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';

class LocalDbService {
  static final LocalDbService _instance = LocalDbService._internal();
  factory LocalDbService() => _instance;
  LocalDbService._internal();

  Database? _db;
  String? _currentUser;

  Future<void> closeDb() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
      _currentUser = null;
    }
  }

  Future<Database> get _database async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('user_profile_name') ?? 'default_user';

    // If the database is already open for the current user, return it
    if (_db != null && _currentUser == username) {
      return _db!;
    }

    // If the database is open for a different user, close it first
    if (_db != null) {
      await _db!.close();
      _db = null;
    }

    _currentUser = username;
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'expenses_$username.db');
    
    _db = await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE expenses(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          amount REAL NOT NULL,
          category TEXT NOT NULL,
          date TEXT NOT NULL,
          description TEXT
        )
      ''');
    });
    
    return _db!;
  }

  Future<List<Expense>> getAllExpenses() async {
    final db = await _database;
    final maps = await db.query('expenses', orderBy: 'date DESC');
    return maps.map((m) => Expense(
          id: m['id'] as int,
          title: m['title'] as String,
          amount: (m['amount'] as num).toDouble(),
          category: m['category'] as String,
          date: DateTime.parse(m['date'] as String),
          description: m['description'] as String?,
        )).toList();
  }

  Future<int> insertExpense(Expense expense) async {
    final db = await _database;
    return await db.insert('expenses', {
      'title': expense.title,
      'amount': expense.amount,
      'category': expense.category,
      'date': expense.date.toIso8601String(),
      'description': expense.description,
    });
  }

  Future<int> deleteExpense(int id) async {
    final db = await _database;
    return await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> clearAllExpenses() async {
    final db = await _database;
    return await db.delete('expenses');
  }
}
