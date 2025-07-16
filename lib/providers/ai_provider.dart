import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite' hide Transaction;
import '../models/ai_suggestion.dart';
import '../models/financial_prediction.dart';
import '../models/transaction.dart';
import '../models/salary_record.dart';
import '../models/income_source.dart';
import '../models/category.dart' as models;
import '../models/bill.dart';
import '../models/budget.dart';
import '../models/category.dart';
import '../db/db_init.dart';
import '../services/ai_suggestion_service.dart';
import '../services/transaction_service.dart';
import '../services/budget_service.dart';
import '../services/category_service.dart';
import '../ai/smart_suggestions_engine.dart';
import '../ai/smart_budgeting_engine.dart';
import '../ai/expense_analyzer.dart';
import '../ai/salary_analyzer.dart';

class AIProvider with ChangeNotifier {
  List<AISuggestion> _suggestions = [];
  List<FinancialPrediction> _predictions = [];
  bool _isLoading = false;
  String? _error;

  // Analytics results cache
  Map<String, dynamic>? _expenseAnalysis;
  Map<String, dynamic>? _salaryAnalysis;
  Map<String, dynamic>? _predictiveAnalysis;
  DateTime? _lastAnalysisUpdate;
  DateTime? _lastPredictionUpdate;

  // Getters
  List<AISuggestion> get suggestions => _suggestions;
  List<AISuggestion> get unreadSuggestions =>
      _suggestions.where((s) => !s.isRead).toList();
  List<AISuggestion> get highPrioritySuggestions =>
      _suggestions.where((s) => s.priority >= 4).toList();

  List<FinancialPrediction> get predictions => _predictions;
  List<FinancialPrediction> get recentPredictions =>
      _predictions.where((p) => !p.isTargetInPast()).toList();
  List<FinancialPrediction> get highConfidencePredictions =>
      _predictions.where((p) => p.isHighConfidence()).toList();

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get expenseAnalysis => _expenseAnalysis;
  Map<String, dynamic>? get salaryAnalysis => _salaryAnalysis;
  Map<String, dynamic>? get predictiveAnalysis => _predictiveAnalysis;

  // Initialize AI data
  Future<void> initialize() async {
    await loadSuggestions();
    await loadPredictions();
  }

  // Load AI suggestions
  Future<void> loadSuggestions() async {
    try {
      _setLoading(true);
      _suggestions = await AISuggestionService.getAll();
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load AI suggestions: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load financial predictions
  Future<void> loadPredictions() async {
    try {
      _predictions = await _loadPredictionsFromDatabase();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load predictions: $e');
    }
  }

  // Generate new suggestions
  Future<void> generateSmartSuggestions({
    required List<Transaction> transactions,
    required List<SalaryRecord> salaryRecords,
    required List<IncomeSource> incomeSources,
    required List<models.Category> categories,
    List<Bill>? bills,
  }) async {
    try {
      _setLoading(true);

      // Generate basic suggestions
      final suggestions = SmartSuggestionsEngine.generateSuggestions(
        transactions: transactions,
        salaryRecords: salaryRecords,
        incomeSources: incomeSources,
        categories: categories,
      );

      // Generate personalized tips
      final tips = SmartSuggestionsEngine.generatePersonalizedTips(
        transactions: transactions,
        salaryRecords: salaryRecords,
        incomeSources: incomeSources,
        categories: categories,
      );

      // Generate smart alerts
      final alerts = SmartSuggestionsEngine.generateSmartAlerts(
        transactions: transactions,
        salaryRecords: salaryRecords,
        incomeSources: incomeSources,
        categories: categories,
      );

      // Generate seasonal tips
      final seasonalTips = SmartSuggestionsEngine.generateSeasonalTips();

      // Combine all suggestions
      final allSuggestions = [
        ...suggestions,
        ...tips,
        ...alerts,
        ...seasonalTips,
      ];

      // Save to database
      for (final suggestion in allSuggestions) {
        await AISuggestionService.insert(suggestion);
      }

      // Reload suggestions
      await loadSuggestions();
      _clearError();
    } catch (e) {
      _setError('Failed to generate suggestions: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Generate comprehensive financial predictions
  Future<void> generatePredictions() async {
    try {
      _setLoading(true);

      // Comment out temporarily
      // final analysis = await PredictiveAnalyticsEngine.generatePredictions(
      //   transactions: [],
      //   bills: [],
      //   incomeSourceRecords: [],
      //   categories: [],
      // );

      // _predictions = analysis.predictions;
      // _predictiveAnalysis = analysis.toMap();
      _lastPredictionUpdate = DateTime.now();

      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to generate predictions: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Generate expense analysis
  Future<void> generateExpenseAnalysis({
    required List<Transaction> transactions,
    required List<models.Category> categories,
  }) async {
    try {
      _setLoading(true);

      // Detect anomalies
      final anomalies = ExpenseAnalyzer.detectAnomalies(transactions);

      // Analyze spending patterns
      final patterns = ExpenseAnalyzer.analyzeSpendingPatterns(transactions);

      // Generate expense reduction suggestions
      final totalExpenses = transactions
          .where((t) => t.type == 'expense')
          .fold<double>(0, (sum, t) => sum + t.amount);
      final targetReduction = totalExpenses * 0.1; // 10% reduction target

      final reductionSuggestions = ExpenseAnalyzer.suggestExpenseReduction(
        transactions,
        categories,
        targetReduction,
      );

      _expenseAnalysis = {
        'anomalies': anomalies,
        'patterns': patterns,
        'reduction_suggestions': reductionSuggestions,
        'total_expenses': totalExpenses,
        'target_reduction': targetReduction,
      };

      // Generate AI suggestions based on analysis
      if (anomalies.isNotEmpty) {
        final anomalyCount = anomalies
            .where((a) => a['severity'] == 'high')
            .length;
        if (anomalyCount > 0) {
          final anomalySuggestion = AISuggestion(
            type: 'expense_anomaly',
            title: 'PhÃ¡t hiá»‡n chi tiÃªu báº¥t thÆ°á»ng',
            content:
                'CÃ³ $anomalyCount giao dá»‹ch chi tiÃªu báº¥t thÆ°á»ng Ä‘Æ°á»£c phÃ¡t hiá»‡n. HÃ£y kiá»ƒm tra láº¡i.',
            priority: 4,
            isRead: false,
            createdAt: DateTime.now(),
          );

          await AISuggestionService.insert(anomalySuggestion);
        }
      }

      if (reductionSuggestions.isNotEmpty) {
        final topReduction = reductionSuggestions.first;
        final savingsAmount = topReduction['potential_savings'] as double;

        final reductionSuggestion = AISuggestion(
          type: 'expense_reduction',
          title: 'CÆ¡ há»™i tiáº¿t kiá»‡m',
          content:
              'CÃ³ thá»ƒ tiáº¿t kiá»‡m ${(savingsAmount / 1000000).toStringAsFixed(1)}M báº±ng cÃ¡ch tá»‘i Æ°u ${topReduction['category'].name}.',
          priority: 3,
          isRead: false,
          createdAt: DateTime.now(),
        );

        await AISuggestionService.insert(reductionSuggestion);
      }

      _lastAnalysisUpdate = DateTime.now();
      await loadSuggestions();
      _clearError();
    } catch (e) {
      _setError('Failed to generate expense analysis: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Generate salary analysis
  Future<void> generateSalaryAnalysis({
    required List<SalaryRecord> salaryRecords,
    required List<IncomeSource> incomeSources,
  }) async {
    try {
      _setLoading(true);

      if (salaryRecords.isEmpty || incomeSources.isEmpty) {
        _salaryAnalysis = {
          'growth_rate': 0.0,
          'predictions': <Map<String, dynamic>>[],
          'tax_optimization': <Map<String, dynamic>>[],
        };
        return;
      }

      // Analyze salary growth
      final growthAnalysis = SalaryAnalyzer.analyzeSalaryGrowth(salaryRecords);

      // Predict income
      final incomeSource = incomeSources.first;
      final incomePrediction = SalaryAnalyzer.predictIncome(
        salaryRecords,
        incomeSource,
      );

      // Optimize tax deductions
      final latestRecord = salaryRecords.last;
      final taxOptimization = SalaryAnalyzer.optimizeTaxDeductions(
        latestRecord,
        incomeSource,
      );

      _salaryAnalysis = {
        'growth_analysis': growthAnalysis,
        'income_prediction': incomePrediction,
        'tax_optimization': taxOptimization,
      };

      // Generate suggestions based on salary analysis
      if (growthAnalysis['growth_rate'] < 5.0) {
        final growthSuggestion = AISuggestion(
          type: 'salary_growth',
          title: 'LÆ°Æ¡ng tÄƒng cháº­m',
          content:
              'LÆ°Æ¡ng tÄƒng ${growthAnalysis['growth_rate'].toStringAsFixed(1)}%/nÄƒm, tháº¥p hÆ¡n láº¡m phÃ¡t. ${growthAnalysis['recommendation']}',
          priority: 3,
          isRead: false,
          createdAt: DateTime.now(),
        );

        await AISuggestionService.insert(growthSuggestion);
      }

      final taxSavings = taxOptimization['total_potential_savings'] as double;
      if (taxSavings > 1000000) {
        final taxSuggestion = AISuggestion(
          type: 'tax_optimization',
          title: 'CÆ¡ há»™i tá»‘i Æ°u thuáº¿',
          content:
              'CÃ³ thá»ƒ tiáº¿t kiá»‡m ${(taxSavings / 1000000).toStringAsFixed(1)}M thuáº¿/nÄƒm. ${taxOptimization['analysis']}',
          priority: 3,
          isRead: false,
          createdAt: DateTime.now(),
        );

        await AISuggestionService.insert(taxSuggestion);
      }

      _lastAnalysisUpdate = DateTime.now();
      await loadSuggestions();
      _clearError();
    } catch (e) {
      _setError('Failed to generate salary analysis: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Mark suggestion as read
  Future<void> markSuggestionAsRead(int suggestionId) async {
    try {
      await AISuggestionService.markAsRead(suggestionId);
      final index = _suggestions.indexWhere((s) => s.id == suggestionId);
      if (index >= 0) {
        _suggestions[index] = _suggestions[index].copyWith(isRead: true);
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to mark suggestion as read: $e');
    }
  }

  // Get predictions by type
  List<FinancialPrediction> getPredictionsByType(String type) {
    return _predictions.where((p) => p.predictionType == type).toList();
  }

  // Get predictions for specific month
  List<FinancialPrediction> getPredictionsForMonth(DateTime month) {
    return _predictions.where((p) {
      final targetMonth = p.targetDate;
      return targetMonth.year == month.year && targetMonth.month == month.month;
    }).toList();
  }

  // Check if analysis is recent (within last 24 hours)
  bool get isAnalysisRecent {
    if (_lastAnalysisUpdate == null) return false;
    return DateTime.now().difference(_lastAnalysisUpdate!).inHours < 24;
  }

  // Check if predictions are recent (within last 7 days)
  bool get isPredictionRecent {
    if (_lastPredictionUpdate == null) return false;
    return DateTime.now().difference(_lastPredictionUpdate!).inDays < 7;
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    debugPrint('AIProvider Error: $error');
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  // Database operations for predictions (simplified - would need actual service)
  Future<List<FinancialPrediction>> _loadPredictionsFromDatabase() async {
    // This would be implemented with an actual database service
    // For now, return empty list
    return <FinancialPrediction>[];
  }

  Future<void> _savePredictionToDatabase(FinancialPrediction prediction) async {
    // This would be implemented with an actual database service
    // For now, just add to local list
    _predictions.add(prediction);
  }

  // Clear old predictions
  Future<void> clearOldPredictions() async {
    final cutoffDate = DateTime.now().subtract(const Duration(days: 30));
    _predictions.removeWhere((p) => p.createdAt.isBefore(cutoffDate));
    notifyListeners();
  }

  // Export predictions data
  Map<String, dynamic> exportPredictionsData() {
    return {
      'predictions': _predictions.map((p) => p.toMap()).toList(),
      'analysis': {
        'expense_analysis': _expenseAnalysis,
        'salary_analysis': _salaryAnalysis,
        'predictive_analysis': _predictiveAnalysis,
      },
      'last_updated': {
        'analysis': _lastAnalysisUpdate?.toIso8601String(),
        'predictions': _lastPredictionUpdate?.toIso8601String(),
      },
    };
  }
}

// Extension for AISuggestion model
extension AISuggestionExtension on AISuggestion {
  AISuggestion copyWith({
    int? id,
    String? type,
    String? title,
    String? content,
    int? priority,
    bool? isRead,
    String? triggerConditions,
    DateTime? createdAt,
  }) {
    return AISuggestion(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      content: content ?? this.content,
      priority: priority ?? this.priority,
      isRead: isRead ?? this.isRead,
      triggerConditions: triggerConditions ?? this.triggerConditions,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
