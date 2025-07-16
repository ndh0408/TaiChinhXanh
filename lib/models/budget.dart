class Budget {
  final int? id;
  final String name;
  final String categoryId;
  final double amount;
  final double spentAmount;
  final BudgetType type;
  final BudgetPeriod period;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final bool isAIGenerated;
  final double? suggestedAmount;
  final String? aiReason;
  final BudgetStatus status;
  final List<String> alertThresholds; // [50, 75, 90] percentages
  final DateTime createdAt;
  final DateTime updatedAt;

  // Thêm các properties bị thiếu
  final double budgetLimit;
  final bool isEssential;
  final int priority;

  Budget({
    this.id,
    required this.name,
    required this.categoryId,
    required this.amount,
    this.spentAmount = 0.0,
    required this.type,
    required this.period,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    this.isAIGenerated = false,
    this.suggestedAmount,
    this.aiReason,
    required this.status,
    this.alertThresholds = const ['50', '75', '90'],
    required this.createdAt,
    required this.updatedAt,
    // Thêm các properties mới
    required this.budgetLimit,
    this.isEssential = false,
    this.priority = 1,
  });

  // Getters for calculated properties
  double get remainingAmount => amount - spentAmount;
  double get spentPercentage => amount > 0 ? (spentAmount / amount) * 100 : 0;
  bool get isOverBudget => spentAmount > amount;
  int get daysRemaining => endDate.difference(DateTime.now()).inDays;
  double get dailyAverage =>
      daysRemaining > 0 ? remainingAmount / daysRemaining : 0;

  // Alias properties for backward compatibility with screens
  double get spent => spentAmount;
  String get category => categoryId;

  BudgetHealth get health {
    if (spentPercentage <= 50) return BudgetHealth.good;
    if (spentPercentage <= 75) return BudgetHealth.warning;
    if (spentPercentage <= 90) return BudgetHealth.critical;
    return BudgetHealth.overBudget;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'categoryId': categoryId,
      'amount': amount,
      'spentAmount': spentAmount,
      'type': type.toString(),
      'period': period.toString(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive ? 1 : 0,
      'isAIGenerated': isAIGenerated ? 1 : 0,
      'suggestedAmount': suggestedAmount,
      'aiReason': aiReason,
      'status': status.toString(),
      'alertThresholds': alertThresholds.join(','),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      // Thêm các properties mới
      'budgetLimit': budgetLimit,
      'isEssential': isEssential ? 1 : 0,
      'priority': priority,
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'],
      name: map['name'],
      categoryId: map['categoryId'],
      amount: map['amount']?.toDouble() ?? 0.0,
      spentAmount: map['spentAmount']?.toDouble() ?? 0.0,
      type: BudgetType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => BudgetType.fixed,
      ),
      period: BudgetPeriod.values.firstWhere(
        (e) => e.toString() == map['period'],
        orElse: () => BudgetPeriod.monthly,
      ),
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      isActive: map['isActive'] == 1,
      isAIGenerated: map['isAIGenerated'] == 1,
      suggestedAmount: map['suggestedAmount']?.toDouble(),
      aiReason: map['aiReason'],
      status: BudgetStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => BudgetStatus.active,
      ),
      alertThresholds: map['alertThresholds']?.split(',') ?? ['50', '75', '90'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      // Thêm các properties mới
      budgetLimit:
          map['budgetLimit']?.toDouble() ?? map['amount']?.toDouble() ?? 0.0,
      isEssential: map['isEssential'] == 1,
      priority: map['priority']?.toInt() ?? 1,
    );
  }

  Budget copyWith({
    int? id,
    String? name,
    String? categoryId,
    double? amount,
    double? spentAmount,
    BudgetType? type,
    BudgetPeriod? period,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    bool? isAIGenerated,
    double? suggestedAmount,
    String? aiReason,
    BudgetStatus? status,
    List<String>? alertThresholds,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? budgetLimit,
    bool? isEssential,
    int? priority,
  }) {
    return Budget(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      spentAmount: spentAmount ?? this.spentAmount,
      type: type ?? this.type,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      isAIGenerated: isAIGenerated ?? this.isAIGenerated,
      suggestedAmount: suggestedAmount ?? this.suggestedAmount,
      aiReason: aiReason ?? this.aiReason,
      status: status ?? this.status,
      alertThresholds: alertThresholds ?? this.alertThresholds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      budgetLimit: budgetLimit ?? this.budgetLimit,
      isEssential: isEssential ?? this.isEssential,
      priority: priority ?? this.priority,
    );
  }
}

enum BudgetType {
  fixed, // Fixed amount each period
  flexible, // Can be adjusted based on income/expenses
  aiSuggested, // Generated by AI
  percentage, // Percentage of income
}

enum BudgetPeriod { weekly, biweekly, monthly, quarterly, yearly }

enum BudgetStatus { active, paused, completed, cancelled }

enum BudgetHealth {
  good, // Under 50% spent
  warning, // 50-75% spent
  critical, // 75-90% spent
  overBudget, // Over 90% spent
}

class BudgetSuggestion {
  final String categoryId;
  final String categoryName;
  final double suggestedAmount;
  final double currentSpending;
  final double historicalAverage;
  final String reason;
  final double confidence;
  final BudgetSuggestionType type;
  final List<String> tips;

  BudgetSuggestion({
    required this.categoryId,
    required this.categoryName,
    required this.suggestedAmount,
    required this.currentSpending,
    required this.historicalAverage,
    required this.reason,
    required this.confidence,
    required this.type,
    required this.tips,
  });

  Map<String, dynamic> toMap() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'suggestedAmount': suggestedAmount,
      'currentSpending': currentSpending,
      'historicalAverage': historicalAverage,
      'reason': reason,
      'confidence': confidence,
      'type': type.toString(),
      'tips': tips.join('|'),
    };
  }

  factory BudgetSuggestion.fromMap(Map<String, dynamic> map) {
    return BudgetSuggestion(
      categoryId: map['categoryId'],
      categoryName: map['categoryName'],
      suggestedAmount: map['suggestedAmount']?.toDouble() ?? 0.0,
      currentSpending: map['currentSpending']?.toDouble() ?? 0.0,
      historicalAverage: map['historicalAverage']?.toDouble() ?? 0.0,
      reason: map['reason'],
      confidence: map['confidence']?.toDouble() ?? 0.0,
      type: BudgetSuggestionType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => BudgetSuggestionType.increase,
      ),
      tips: map['tips']?.split('|') ?? [],
    );
  }
}

enum BudgetSuggestionType {
  increase, // Suggest increasing budget
  decrease, // Suggest decreasing budget
  maintain, // Keep current budget
  create, // Create new budget category
}

