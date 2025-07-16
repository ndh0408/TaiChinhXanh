import 'package:flutter/foundation.dart';
import '../models/budget.dart';
import '../models/category.dart';
import '../services/budget_service.dart';
import '../ai/smart_budgeting_engine.dart';

class BudgetProvider with ChangeNotifier {
  List<Budget> _budgets = [];
  List<BudgetSuggestion> _suggestions = [];
  BudgetOptimization? _optimization;
  Map<String, double> _budgetSummary = {};
  List<Map<String, dynamic>> _budgetTrends = [];
  bool _isLoading = false;
  String? _error;

  // Search and filter
  String _searchQuery = '';
  BudgetStatus? _statusFilter;
  BudgetHealth? _healthFilter;
  BudgetType? _typeFilter;

  // Getters
  List<Budget> get budgets => _filteredBudgets;
  List<BudgetSuggestion> get suggestions => _suggestions;
  BudgetOptimization? get optimization => _optimization;
  Map<String, double> get budgetSummary => _budgetSummary;
  List<Map<String, dynamic>> get budgetTrends => _budgetTrends;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Search and filter getters
  String get searchQuery => _searchQuery;
  BudgetStatus? get statusFilter => _statusFilter;
  BudgetHealth? get healthFilter => _healthFilter;
  BudgetType? get typeFilter => _typeFilter;

  // Search and filter setters
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setStatusFilter(BudgetStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  void setHealthFilter(BudgetHealth? health) {
    _healthFilter = health;
    notifyListeners();
  }

  void setTypeFilter(BudgetType? type) {
    _typeFilter = type;
    notifyListeners();
  }

  // Filtered budgets
  List<Budget> get _filteredBudgets {
    List<Budget> filtered = List.from(_budgets);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (budget) =>
                budget.name.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    // Apply status filter
    if (_statusFilter != null) {
      filtered = filtered
          .where((budget) => budget.status == _statusFilter)
          .toList();
    }

    // Apply health filter
    if (_healthFilter != null) {
      filtered = filtered
          .where((budget) => budget.health == _healthFilter)
          .toList();
    }

    // Apply type filter
    if (_typeFilter != null) {
      filtered = filtered
          .where((budget) => budget.type == _typeFilter)
          .toList();
    }

    return filtered;
  }

  // Computed properties
  double get totalBudgeted =>
      _budgets.fold(0, (sum, budget) => sum + budget.amount);
  double get totalSpent =>
      _budgets.fold(0, (sum, budget) => sum + budget.spentAmount);
  double get totalRemaining => totalBudgeted - totalSpent;
  double get spentPercentage =>
      totalBudgeted > 0 ? (totalSpent / totalBudgeted) * 100 : 0;

  List<Budget> get overBudgets =>
      _budgets.where((b) => b.isOverBudget).toList();
  List<Budget> get nearLimitBudgets => _budgets
      .where((b) => b.spentPercentage >= 80 && !b.isOverBudget)
      .toList();
  List<Budget> get healthyBudgets =>
      _budgets.where((b) => b.health == BudgetHealth.good).toList();

  int get activeBudgetsCount =>
      _budgets.where((b) => b.status == BudgetStatus.active).length;

  // Initialize and load data
  Future<void> initialize() async {
    await loadBudgets();
    await loadBudgetSummary();
    await loadBudgetTrends();
  }

  Future<void> loadBudgets() async {
    _setLoading(true);
    try {
      _budgets = await BudgetService.getAllBudgets();
      _clearError();
    } catch (e) {
      _setError('Không thể tải danh sách ngân sách: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadActiveBudgets() async {
    _setLoading(true);
    try {
      _budgets = await BudgetService.getActiveBudgets();
      _clearError();
    } catch (e) {
      _setError('Không thể tải ngân sách đang hoạt động: $e');
    } finally {
      _setLoading(false);
    }
  }

  // CRUD Operations
  Future<bool> createBudget(Budget budget) async {
    try {
      int id = await BudgetService.createBudget(budget);
      Budget createdBudget = budget.copyWith(id: id);
      _budgets.insert(0, createdBudget);
      await loadBudgetSummary(); // Refresh summary
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Không thể tạo ngân sách: $e');
      return false;
    }
  }

  Future<bool> updateBudget(Budget budget) async {
    try {
      await BudgetService.updateBudget(budget);
      int index = _budgets.indexWhere((b) => b.id == budget.id);
      if (index != -1) {
        _budgets[index] = budget;
        await loadBudgetSummary(); // Refresh summary
        notifyListeners();
      }
      return true;
    } catch (e) {
      _setError('Không thể cập nhật ngân sách: $e');
      return false;
    }
  }

  Future<bool> deleteBudget(int id) async {
    try {
      await BudgetService.deleteBudget(id);
      _budgets.removeWhere((budget) => budget.id == id);
      await loadBudgetSummary(); // Refresh summary
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Không thể xóa ngân sách: $e');
      return false;
    }
  }

  // Budget Analytics
  Future<void> loadBudgetSummary() async {
    try {
      _budgetSummary = await BudgetService.getBudgetSummary();
      notifyListeners();
    } catch (e) {
      _setError('Không thể tải tổng quan ngân sách: $e');
    }
  }

  Future<void> loadBudgetTrends({int months = 6}) async {
    try {
      _budgetTrends = await BudgetService.getBudgetTrends(months: months);
      notifyListeners();
    } catch (e) {
      _setError('Không thể tải xu hướng ngân sách: $e');
    }
  }

  Future<void> analyzeBudgetPerformance() async {
    _setLoading(true);
    try {
      _optimization = await BudgetService.analyzeBudgetPerformance();
      _clearError();
    } catch (e) {
      _setError('Không thể phân tích hiệu suất ngân sách: $e');
    } finally {
      _setLoading(false);
    }
  }

  // AI Suggestions
  Future<void> generateBudgetSuggestions() async {
    _setLoading(true);
    try {
      _suggestions = await BudgetService.generateBudgetSuggestions();

      // Save suggestions to database
      for (BudgetSuggestion suggestion in _suggestions) {
        await BudgetService.saveBudgetSuggestion(suggestion);
      }

      _clearError();
    } catch (e) {
      _setError('Không thể tạo đề xuất ngân sách: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadSavedSuggestions() async {
    try {
      _suggestions = await BudgetService.getSavedBudgetSuggestions();
      notifyListeners();
    } catch (e) {
      _setError('Không thể tải đề xuất đã lưu: $e');
    }
  }

  Future<bool> applyBudgetSuggestion(BudgetSuggestion suggestion) async {
    try {
      // Find existing budget or create new one
      Budget? existingBudget =
          _budgets
              .where((b) => b.categoryId == suggestion.categoryId)
              .isNotEmpty
          ? _budgets.firstWhere((b) => b.categoryId == suggestion.categoryId)
          : null;

      if (existingBudget != null) {
        // Update existing budget
        Budget updatedBudget = existingBudget.copyWith(
          amount: suggestion.suggestedAmount,
          isAIGenerated: true,
          aiReason: suggestion.reason,
          updatedAt: DateTime.now(),
        );
        return await updateBudget(updatedBudget);
      } else {
        // Create new budget
        Budget newBudget = Budget(
          name: 'AI - ${suggestion.categoryName}',
          categoryId: suggestion.categoryId,
          amount: suggestion.suggestedAmount,
          budgetLimit: suggestion.suggestedAmount,
          type: BudgetType.aiSuggested,
          period: BudgetPeriod.monthly,
          startDate: DateTime.now(),
          endDate: DateTime(
            DateTime.now().year,
            DateTime.now().month + 1,
            DateTime.now().day,
          ),
          status: BudgetStatus.active,
          isAIGenerated: true,
          aiReason: suggestion.reason,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        return await createBudget(newBudget);
      }
    } catch (e) {
      _setError('Không thể áp dụng đề xuất: $e');
      return false;
    }
  }

  // Auto Budget Generation
  Future<bool> generateAutomaticBudgets({
    required double monthlyIncome,
    required DateTime startDate,
    BudgetPeriod period = BudgetPeriod.monthly,
  }) async {
    _setLoading(true);
    try {
      List<Budget> autoBudgets = await BudgetService.generateAutomaticBudgets(
        monthlyIncome: monthlyIncome,
        startDate: startDate,
        period: period,
      );

      // Create all budgets
      await BudgetService.createMultipleBudgets(autoBudgets);

      // Reload budgets
      await loadBudgets();
      _clearError();
      return true;
    } catch (e) {
      _setError('Không thể tạo ngân sách tự động: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createBudgetFromTemplate({
    required String templateName,
    required double monthlyIncome,
    required BudgetPeriod period,
  }) async {
    _setLoading(true);
    try {
      List<Budget> templateBudgets = await BudgetService.createBudgetTemplate(
        templateName: templateName,
        monthlyIncome: monthlyIncome,
        period: period,
      );

      // Create all budgets
      await BudgetService.createMultipleBudgets(templateBudgets);

      // Reload budgets
      await loadBudgets();
      _clearError();
      return true;
    } catch (e) {
      _setError('Không thể tạo ngân sách từ template: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Search and Filter
  void clearFilters() {
    _searchQuery = '';
    _statusFilter = null;
    _healthFilter = null;
    _typeFilter = null;
    notifyListeners();
  }

  // Budget Management
  Future<void> updateBudgetSpending(String categoryId, double amount) async {
    try {
      await BudgetService.updateBudgetSpending(categoryId, amount);

      // Update local budget data
      for (int i = 0; i < _budgets.length; i++) {
        if (_budgets[i].categoryId == categoryId && _budgets[i].isActive) {
          _budgets[i] = _budgets[i].copyWith(
            spentAmount: _budgets[i].spentAmount + amount.abs(),
            updatedAt: DateTime.now(),
          );
          break;
        }
      }

      await loadBudgetSummary(); // Refresh summary
      notifyListeners();
    } catch (e) {
      _setError('Không thể cập nhật chi tiêu ngân sách: $e');
    }
  }

  Future<void> deactivateExpiredBudgets() async {
    try {
      await BudgetService.deactivateExpiredBudgets();
      await loadBudgets(); // Reload to reflect changes
    } catch (e) {
      _setError('Không thể vô hiệu hóa ngân sách hết hạn: $e');
    }
  }

  // Bulk Operations
  Future<bool> pauseMultipleBudgets(List<int> budgetIds) async {
    try {
      for (int id in budgetIds) {
        Budget? budget = _budgets.where((b) => b.id == id).isNotEmpty
            ? _budgets.firstWhere((b) => b.id == id)
            : null;
        if (budget != null) {
          await updateBudget(budget.copyWith(status: BudgetStatus.paused));
        }
      }
      return true;
    } catch (e) {
      _setError('Không thể tạm dừng ngân sách: $e');
      return false;
    }
  }

  Future<bool> activateMultipleBudgets(List<int> budgetIds) async {
    try {
      for (int id in budgetIds) {
        Budget? budget = _budgets.where((b) => b.id == id).isNotEmpty
            ? _budgets.firstWhere((b) => b.id == id)
            : null;
        if (budget != null) {
          await updateBudget(budget.copyWith(status: BudgetStatus.active));
        }
      }
      return true;
    } catch (e) {
      _setError('Không thể kích hoạt ngân sách: $e');
      return false;
    }
  }

  Future<bool> deleteMultipleBudgets(List<int> budgetIds) async {
    try {
      for (int id in budgetIds) {
        await BudgetService.deleteBudget(id);
      }
      _budgets.removeWhere((budget) => budgetIds.contains(budget.id));
      await loadBudgetSummary(); // Refresh summary
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Không thể xóa ngân sách: $e');
      return false;
    }
  }

  // Utility methods
  Budget? getBudgetById(int id) {
    return _budgets.where((b) => b.id == id).isNotEmpty
        ? _budgets.firstWhere((b) => b.id == id)
        : null;
  }

  List<Budget> getBudgetsByCategory(String categoryId) {
    return _budgets.where((b) => b.categoryId == categoryId).toList();
  }

  double getCategoryBudgetTotal(String categoryId) {
    return _budgets
        .where((b) => b.categoryId == categoryId && b.isActive)
        .fold(0, (sum, budget) => sum + budget.amount);
  }

  double getCategorySpentTotal(String categoryId) {
    return _budgets
        .where((b) => b.categoryId == categoryId && b.isActive)
        .fold(0, (sum, budget) => sum + budget.spentAmount);
  }

  // Export and Import
  Future<String> exportBudgetsToJson() async {
    try {
      List<Map<String, dynamic>> budgetMaps = _budgets
          .map((b) => b.toMap())
          .toList();
      // Add export logic here - could return JSON string
      return 'Budget export not implemented yet';
    } catch (e) {
      _setError('Không thể xuất dữ liệu ngân sách: $e');
      return '';
    }
  }

  // Private helper methods
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
    notifyListeners();
  }

  // Clear all data
  void clear() {
    _budgets.clear();
    _suggestions.clear();
    _optimization = null;
    _budgetSummary.clear();
    _budgetTrends.clear();
    _searchQuery = '';
    _statusFilter = null;
    _healthFilter = null;
    _typeFilter = null;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
