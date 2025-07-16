class ExpenseForecast {
  final String categoryId;
  final String categoryName;
  final double forecastAmount;
  final int forecastPeriod; // days
  final double confidence; // 0.0 to 1.0
  final ForecastMethod method;
  final DateTime generatedAt;
  final DateTime validUntil;
  final Map<String, dynamic>? metadata;

  ExpenseForecast({
    required this.categoryId,
    required this.categoryName,
    required this.forecastAmount,
    required this.forecastPeriod,
    required this.confidence,
    required this.method,
    required this.generatedAt,
    required this.validUntil,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'forecastAmount': forecastAmount,
      'forecastPeriod': forecastPeriod,
      'confidence': confidence,
      'method': method.toString(),
      'generatedAt': generatedAt.toIso8601String(),
      'validUntil': validUntil.toIso8601String(),
      'metadata': metadata?.toString(),
    };
  }

  factory ExpenseForecast.fromMap(Map<String, dynamic> map) {
    return ExpenseForecast(
      categoryId: map['categoryId'] ?? '',
      categoryName: map['categoryName'] ?? '',
      forecastAmount: map['forecastAmount']?.toDouble() ?? 0.0,
      forecastPeriod: map['forecastPeriod']?.toInt() ?? 0,
      confidence: map['confidence']?.toDouble() ?? 0.0,
      method: ForecastMethod.values.firstWhere(
        (e) => e.toString() == map['method'],
        orElse: () => ForecastMethod.historical,
      ),
      generatedAt: DateTime.parse(map['generatedAt']),
      validUntil: DateTime.parse(map['validUntil']),
      metadata: map['metadata'],
    );
  }

  bool get isValid => DateTime.now().isBefore(validUntil);
  bool get isHighConfidence => confidence >= 0.8;
  bool get isMediumConfidence => confidence >= 0.6 && confidence < 0.8;
  bool get isLowConfidence => confidence < 0.6;

  String get confidenceLabel {
    if (isHighConfidence) return 'Cao';
    if (isMediumConfidence) return 'Trung bình';
    return 'Thấp';
  }

  double get dailyAverage => forecastAmount / forecastPeriod;
}

enum ForecastMethod {
  historical, // Based on historical averages
  linear, // Linear regression
  seasonal, // Seasonal analysis
  trend, // Trend-based
  ensemble, // Combined multiple methods
  aiPowered, // Advanced AI/ML methods
}

class ExpenseAnomaly {
  final String transactionId;
  final String categoryId;
  final String categoryName;
  final double amount;
  final double expectedAmount;
  final double deviation; // Z-score or other deviation metric
  final AnomalyType anomalyType;
  final AnomalySeverity severity;
  final String description;
  final DateTime detectedAt;
  final Map<String, dynamic>? additionalData;

  ExpenseAnomaly({
    required this.transactionId,
    required this.categoryId,
    required this.categoryName,
    required this.amount,
    required this.expectedAmount,
    required this.deviation,
    required this.anomalyType,
    required this.severity,
    required this.description,
    required this.detectedAt,
    this.additionalData,
  });

  Map<String, dynamic> toMap() {
    return {
      'transactionId': transactionId,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'amount': amount,
      'expectedAmount': expectedAmount,
      'deviation': deviation,
      'anomalyType': anomalyType.toString(),
      'severity': severity.toString(),
      'description': description,
      'detectedAt': detectedAt.toIso8601String(),
      'additionalData': additionalData?.toString(),
    };
  }

  factory ExpenseAnomaly.fromMap(Map<String, dynamic> map) {
    return ExpenseAnomaly(
      transactionId: map['transactionId'] ?? '',
      categoryId: map['categoryId'] ?? '',
      categoryName: map['categoryName'] ?? '',
      amount: map['amount']?.toDouble() ?? 0.0,
      expectedAmount: map['expectedAmount']?.toDouble() ?? 0.0,
      deviation: map['deviation']?.toDouble() ?? 0.0,
      anomalyType: AnomalyType.values.firstWhere(
        (e) => e.toString() == map['anomalyType'],
        orElse: () => AnomalyType.amountOutlier,
      ),
      severity: AnomalySeverity.values.firstWhere(
        (e) => e.toString() == map['severity'],
        orElse: () => AnomalySeverity.medium,
      ),
      description: map['description'] ?? '',
      detectedAt: DateTime.parse(map['detectedAt']),
      additionalData: map['additionalData'],
    );
  }

  double get deviationPercentage =>
      ((amount - expectedAmount) / expectedAmount) * 100;

  bool get isPositiveAnomaly => amount > expectedAmount;
  bool get isNegativeAnomaly => amount < expectedAmount;
}

enum AnomalyType {
  amountOutlier, // Unusual amount compared to historical data
  frequencyAnomaly, // Unusual frequency of transactions
  temporalPattern, // Unusual timing (time of day, day of week)
  categoryShift, // Spending pattern change across categories
  seasonalDeviation, // Deviation from seasonal patterns
  behaviorChange, // Significant behavior pattern change
}

enum AnomalySeverity {
  low, // Minor deviation, informational
  medium, // Moderate deviation, worth noting
  high, // Significant deviation, needs attention
  critical, // Extreme deviation, immediate attention required
}

class CategorySpendingPrediction {
  final String categoryId;
  final String categoryName;
  final double predictedAmount;
  final double confidence;
  final SpendingTrend trend;
  final double historicalAverage;
  final List<String> recommendations;
  final Map<String, double>? breakdown; // e.g., weekly breakdown

  CategorySpendingPrediction({
    required this.categoryId,
    required this.categoryName,
    required this.predictedAmount,
    required this.confidence,
    required this.trend,
    required this.historicalAverage,
    required this.recommendations,
    this.breakdown,
  });

  Map<String, dynamic> toMap() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'predictedAmount': predictedAmount,
      'confidence': confidence,
      'trend': trend.toString(),
      'historicalAverage': historicalAverage,
      'recommendations': recommendations.join('|'),
      'breakdown': breakdown?.toString(),
    };
  }

  factory CategorySpendingPrediction.fromMap(Map<String, dynamic> map) {
    return CategorySpendingPrediction(
      categoryId: map['categoryId'] ?? '',
      categoryName: map['categoryName'] ?? '',
      predictedAmount: map['predictedAmount']?.toDouble() ?? 0.0,
      confidence: map['confidence']?.toDouble() ?? 0.0,
      trend: SpendingTrend.values.firstWhere(
        (e) => e.toString() == map['trend'],
        orElse: () => SpendingTrend.stable,
      ),
      historicalAverage: map['historicalAverage']?.toDouble() ?? 0.0,
      recommendations: map['recommendations']?.split('|') ?? [],
      breakdown: map['breakdown'],
    );
  }

  double get changeFromHistorical => predictedAmount - historicalAverage;
  double get changePercentage => historicalAverage > 0
      ? (changeFromHistorical / historicalAverage) * 100
      : 0.0;

  bool get isIncreasing => trend == SpendingTrend.increasing;
  bool get isDecreasing => trend == SpendingTrend.decreasing;
  bool get isStable => trend == SpendingTrend.stable;
}

enum SpendingTrend {
  increasing, // Spending is trending upward
  decreasing, // Spending is trending downward
  stable, // Spending is relatively stable
  volatile, // Spending is highly variable
}

class SeasonalAnalysis {
  final Map<int, double> monthlyPatterns; // month -> average spending
  final Map<int, double> weeklyPatterns; // weekday -> average spending
  final int peakMonth;
  final int peakWeekday;
  final double seasonalityStrength;
  final List<String> insights;

  SeasonalAnalysis({
    required this.monthlyPatterns,
    required this.weeklyPatterns,
    required this.peakMonth,
    required this.peakWeekday,
    required this.seasonalityStrength,
    required this.insights,
  });

  Map<String, dynamic> toMap() {
    return {
      'monthlyPatterns': monthlyPatterns.map(
        (k, v) => MapEntry(k.toString(), v),
      ),
      'weeklyPatterns': weeklyPatterns.map((k, v) => MapEntry(k.toString(), v)),
      'peakMonth': peakMonth,
      'peakWeekday': peakWeekday,
      'seasonalityStrength': seasonalityStrength,
      'insights': insights.join('|'),
    };
  }

  factory SeasonalAnalysis.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic> monthlyMap = map['monthlyPatterns'] ?? {};
    Map<String, dynamic> weeklyMap = map['weeklyPatterns'] ?? {};

    return SeasonalAnalysis(
      monthlyPatterns: monthlyMap.map(
        (k, v) => MapEntry(int.parse(k), v.toDouble()),
      ),
      weeklyPatterns: weeklyMap.map(
        (k, v) => MapEntry(int.parse(k), v.toDouble()),
      ),
      peakMonth: map['peakMonth']?.toInt() ?? 1,
      peakWeekday: map['peakWeekday']?.toInt() ?? 1,
      seasonalityStrength: map['seasonalityStrength']?.toDouble() ?? 0.0,
      insights: map['insights']?.split('|') ?? [],
    );
  }

  String get peakMonthName {
    const months = [
      '',
      'Tháng 1',
      'Tháng 2',
      'Tháng 3',
      'Tháng 4',
      'Tháng 5',
      'Tháng 6',
      'Tháng 7',
      'Tháng 8',
      'Tháng 9',
      'Tháng 10',
      'Tháng 11',
      'Tháng 12',
    ];
    return months[peakMonth];
  }

  String get peakWeekdayName {
    const weekdays = [
      '',
      'Thứ 2',
      'Thứ 3',
      'Thứ 4',
      'Thứ 5',
      'Thứ 6',
      'Thứ 7',
      'Chủ nhật',
    ];
    return weekdays[peakWeekday];
  }

  bool get hasStrongSeasonality => seasonalityStrength > 0.7;
  bool get hasModerateSeasonality =>
      seasonalityStrength > 0.4 && seasonalityStrength <= 0.7;
  bool get hasWeakSeasonality => seasonalityStrength <= 0.4;
}

class BudgetVarianceAlert {
  final String categoryId;
  final double budgetAmount;
  final double actualAmount;
  final double variance; // percentage
  final BudgetVarianceSeverity severity;
  final String message;
  final DateTime detectedAt;

  BudgetVarianceAlert({
    required this.categoryId,
    required this.budgetAmount,
    required this.actualAmount,
    required this.variance,
    required this.severity,
    required this.message,
    required this.detectedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'categoryId': categoryId,
      'budgetAmount': budgetAmount,
      'actualAmount': actualAmount,
      'variance': variance,
      'severity': severity.toString(),
      'message': message,
      'detectedAt': detectedAt.toIso8601String(),
    };
  }

  factory BudgetVarianceAlert.fromMap(Map<String, dynamic> map) {
    return BudgetVarianceAlert(
      categoryId: map['categoryId'] ?? '',
      budgetAmount: map['budgetAmount']?.toDouble() ?? 0.0,
      actualAmount: map['actualAmount']?.toDouble() ?? 0.0,
      variance: map['variance']?.toDouble() ?? 0.0,
      severity: BudgetVarianceSeverity.values.firstWhere(
        (e) => e.toString() == map['severity'],
        orElse: () => BudgetVarianceSeverity.medium,
      ),
      message: map['message'] ?? '',
      detectedAt: DateTime.parse(map['detectedAt']),
    );
  }

  bool get isOverBudget => variance > 0;
  bool get isUnderBudget => variance < 0;
  double get amountOver => actualAmount - budgetAmount;
}

enum BudgetVarianceSeverity {
  low, // 10-25% variance
  medium, // 25-50% variance
  high, // 50-100% variance
  critical, // >100% variance
}

class ExpenseForecastSummary {
  final DateTime generatedAt;
  final int totalForecasts;
  final double totalPredictedExpense;
  final double averageConfidence;
  final List<ExpenseForecast> topCategoryForecasts;
  final List<ExpenseAnomaly> recentAnomalies;
  final SeasonalAnalysis seasonalAnalysis;
  final List<String> keyInsights;
  final List<String> recommendations;

  ExpenseForecastSummary({
    required this.generatedAt,
    required this.totalForecasts,
    required this.totalPredictedExpense,
    required this.averageConfidence,
    required this.topCategoryForecasts,
    required this.recentAnomalies,
    required this.seasonalAnalysis,
    required this.keyInsights,
    required this.recommendations,
  });

  Map<String, dynamic> toMap() {
    return {
      'generatedAt': generatedAt.toIso8601String(),
      'totalForecasts': totalForecasts,
      'totalPredictedExpense': totalPredictedExpense,
      'averageConfidence': averageConfidence,
      'topCategoryForecasts': topCategoryForecasts
          .map((f) => f.toMap())
          .toList(),
      'recentAnomalies': recentAnomalies.map((a) => a.toMap()).toList(),
      'seasonalAnalysis': seasonalAnalysis.toMap(),
      'keyInsights': keyInsights.join('|'),
      'recommendations': recommendations.join('|'),
    };
  }

  factory ExpenseForecastSummary.fromMap(Map<String, dynamic> map) {
    return ExpenseForecastSummary(
      generatedAt: DateTime.parse(map['generatedAt']),
      totalForecasts: map['totalForecasts']?.toInt() ?? 0,
      totalPredictedExpense: map['totalPredictedExpense']?.toDouble() ?? 0.0,
      averageConfidence: map['averageConfidence']?.toDouble() ?? 0.0,
      topCategoryForecasts:
          (map['topCategoryForecasts'] as List?)
              ?.map((f) => ExpenseForecast.fromMap(f))
              .toList() ??
          [],
      recentAnomalies:
          (map['recentAnomalies'] as List?)
              ?.map((a) => ExpenseAnomaly.fromMap(a))
              .toList() ??
          [],
      seasonalAnalysis: SeasonalAnalysis.fromMap(map['seasonalAnalysis'] ?? {}),
      keyInsights: map['keyInsights']?.split('|') ?? [],
      recommendations: map['recommendations']?.split('|') ?? [],
    );
  }

  bool get hasHighConfidence => averageConfidence >= 0.8;
  bool get hasAnomalies => recentAnomalies.isNotEmpty;
  int get criticalAnomaliesCount => recentAnomalies
      .where((a) => a.severity == AnomalySeverity.critical)
      .length;
}

