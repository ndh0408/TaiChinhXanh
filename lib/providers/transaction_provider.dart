import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../models/category.dart' as models;
import '../services/transaction_service.dart';
import '../services/category_service.dart';

class TransactionProvider with ChangeNotifier {
  List<Transaction> _transactions = [];
  List<models.Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Transaction> get transactions => _transactions;
  List<models.Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Transaction> get incomes =>
      _transactions.where((t) => t.type == 'income').toList();

  List<Transaction> get expenses =>
      _transactions.where((t) => t.type == 'expense').toList();

  double get totalIncome => incomes.fold(0, (sum, t) => sum + t.amount);
  double get totalExpenses => expenses.fold(0, (sum, t) => sum + t.amount);
  double get balance => totalIncome - totalExpenses;

  // Initialize data
  Future<void> initialize() async {
    await loadTransactions();
    await loadCategories();
  }

  // Load all transactions
  Future<void> loadTransactions() async {
    try {
      _setLoading(true);
      _transactions = await TransactionService.getAll();
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load transactions: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load categories
  Future<void> loadCategories() async {
    try {
      _categories = await CategoryService.getAll();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load categories: $e');
    }
  }

  // Add transaction
  Future<bool> addTransaction(Transaction transaction) async {
    try {
      _setLoading(true);
      final id = await TransactionService.insert(transaction);
      final newTransaction = transaction.copyWith(id: id);
      _transactions.insert(0, newTransaction);
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to add transaction: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update transaction
  Future<bool> updateTransaction(Transaction transaction) async {
    try {
      _setLoading(true);
      await TransactionService.update(transaction);
      final index = _transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        _transactions[index] = transaction;
      }
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update transaction: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete transaction
  Future<bool> deleteTransaction(int id) async {
    try {
      _setLoading(true);
      await TransactionService.delete(id);
      _transactions.removeWhere((t) => t.id == id);
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete transaction: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get transactions by date range
  List<Transaction> getTransactionsByDateRange(DateTime start, DateTime end) {
    return _transactions
        .where(
          (t) =>
              t.transactionDate.isAfter(
                start.subtract(const Duration(days: 1)),
              ) &&
              t.transactionDate.isBefore(end.add(const Duration(days: 1))),
        )
        .toList();
  }

  // Get transactions by category
  List<Transaction> getTransactionsByCategory(int categoryId) {
    return _transactions.where((t) => t.categoryId == categoryId).toList();
  }

  // Get monthly statistics
  Map<String, dynamic> getMonthlyStats(DateTime month) {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0);

    final monthlyTransactions = getTransactionsByDateRange(
      startOfMonth,
      endOfMonth,
    );
    final monthlyIncomes = monthlyTransactions
        .where((t) => t.type == 'income')
        .toList();
    final monthlyExpenses = monthlyTransactions
        .where((t) => t.type == 'expense')
        .toList();

    final totalIncome = monthlyIncomes.fold<double>(
      0,
      (sum, t) => sum + t.amount,
    );
    final totalExpenses = monthlyExpenses.fold<double>(
      0,
      (sum, t) => sum + t.amount,
    );

    return {
      'totalIncome': totalIncome,
      'totalExpenses': totalExpenses,
      'balance': totalIncome - totalExpenses,
      'savingsRate': totalIncome > 0
          ? (totalIncome - totalExpenses) / totalIncome
          : 0.0,
      'transactionCount': monthlyTransactions.length,
      'incomeCount': monthlyIncomes.length,
      'expenseCount': monthlyExpenses.length,
    };
  }

  // Get category spending breakdown
  Map<String, double> getCategoryBreakdown(String type) {
    final relevantTransactions = _transactions
        .where((t) => t.type == type)
        .toList();
    final breakdown = <String, double>{};

    for (final transaction in relevantTransactions) {
      final category = _categories.firstWhere(
        (c) => c.id == transaction.categoryId,
        orElse: () => models.Category(
          name: 'Unknown',
          type: type,
          color: '#808080',
          icon: 'help',
          budgetLimit: 0,
          isEssential: false,
          priority: 1,
        ),
      );

      breakdown[category.name] =
          (breakdown[category.name] ?? 0) + transaction.amount;
    }

    return breakdown;
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}

// Extension for Transaction model
extension TransactionExtension on Transaction {
  Transaction copyWith({
    int? id,
    double? amount,
    String? type,
    int? categoryId,
    int? incomeSourceId,
    String? description,
    String? paymentMethod,
    String? location,
    String? receiptPhoto,
    String? tags,
    DateTime? transactionDate,
    DateTime? createdAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      incomeSourceId: incomeSourceId ?? this.incomeSourceId,
      description: description ?? this.description,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      location: location ?? this.location,
      receiptPhoto: receiptPhoto ?? this.receiptPhoto,
      tags: tags ?? this.tags,
      transactionDate: transactionDate ?? this.transactionDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

