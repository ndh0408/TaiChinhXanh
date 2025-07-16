import 'dart:math' as math;
import '../models/investment_recommendation.dart';
import '../models/transaction.dart';
import '../models/salary_record.dart';

class InvestmentRecommendationEngine {
  // static const double _minEmergencyFundMonths = 6.0; // unused
  // static const double _maxInvestmentPercentage = 0.8; // 80% of income - unused

  /// Generate basic investment recommendations based on user profile
  static Future<InvestmentProfile> analyzeInvestmentProfile({
    required List<SalaryRecord> salaryRecords,
    required List<Transaction> transactions,
    required UserInvestmentGoals goals,
    required int age,
    required double currentSavings,
    required double monthlyExpenses,
    required RiskTolerance? userRiskTolerance,
  }) async {
    // Calculate financial metrics
    double monthlyIncome = _calculateAverageMonthlyIncome(salaryRecords);
    double monthlySpending = _calculateAverageMonthlySpending(transactions);

    // Assess risk tolerance if not provided
    RiskTolerance riskTolerance = userRiskTolerance ?? RiskTolerance.moderate;

    // Calculate investment capacity
    InvestmentCapacity capacity = InvestmentCapacity(
      disposableIncome: monthlyIncome - monthlySpending,
      riskCapacity: 0.7, // Default medium risk capacity
      liquidityNeeds: monthlyExpenses * 3, // 3 months expenses
      emergencyFundStatus: currentSavings / (monthlyExpenses * 6),
      debtToIncomeRatio: 0.3, // Default debt ratio
    );

    // Determine investment timeline
    int investmentTimelineYears = _calculateInvestmentTimeline(age, goals);

    return InvestmentProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      monthlyIncome: monthlyIncome,
      monthlyExpenses: monthlySpending,
      currentSavings: currentSavings,
      currentInvestments: 0.0,
      age: age,
      riskTolerance: riskTolerance,
      goals: [goals.goalType],
      timeHorizon: _mapInvestmentTimelineToTimeHorizon(investmentTimelineYears),
      priorities: [InvestmentPriority.safety],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      investmentTimelineYears: investmentTimelineYears,
      assetAllocation: _getDefaultAssetAllocation(riskTolerance),
      investmentCapacity: capacity,
    );
  }

  /// Generate specific investment recommendations
  static Future<List<InvestmentRecommendation>>
  generateInvestmentRecommendations({
    required InvestmentProfile profile,
    required double availableAmount,
    InvestmentType? preferredType,
  }) async {
    List<InvestmentRecommendation> recommendations = [];

    // Basic recommendations based on risk tolerance
    if (profile.riskTolerance == RiskTolerance.conservative) {
      recommendations.add(
        _createRecommendation(
          type: InvestmentType.bonds,
          name: "Government Bonds",
          description: "Safe government bonds for conservative investors",
          amount: availableAmount * 0.6,
        ),
      );
      recommendations.add(
        _createRecommendation(
          type: InvestmentType.bankDeposits,
          name: "Term Deposits",
          description: "Fixed term deposits with guaranteed returns",
          amount: availableAmount * 0.4,
        ),
      );
    } else if (profile.riskTolerance == RiskTolerance.aggressive) {
      recommendations.add(
        _createRecommendation(
          type: InvestmentType.stocks,
          name: "Growth Stocks",
          description: "High growth potential stocks",
          amount: availableAmount * 0.7,
        ),
      );
      recommendations.add(
        _createRecommendation(
          type: InvestmentType.etfs,
          name: "ETFs",
          description: "Diversified Exchange Traded Funds",
          amount: availableAmount * 0.3,
        ),
      );
    } else {
      // Moderate risk tolerance
      recommendations.add(
        _createRecommendation(
          type: InvestmentType.mutualFunds,
          name: "Balanced Mutual Funds",
          description: "Mix of stocks and bonds for balanced growth",
          amount: availableAmount * 0.5,
        ),
      );
      recommendations.add(
        _createRecommendation(
          type: InvestmentType.stocks,
          name: "Blue Chip Stocks",
          description: "Stable large-cap stocks",
          amount: availableAmount * 0.3,
        ),
      );
      recommendations.add(
        _createRecommendation(
          type: InvestmentType.bonds,
          name: "Corporate Bonds",
          description: "Corporate bonds for steady income",
          amount: availableAmount * 0.2,
        ),
      );
    }

    return recommendations;
  }

  // Helper methods
  static InvestmentRecommendation _createRecommendation({
    required InvestmentType type,
    required String name,
    required String description,
    required double amount,
  }) {
    return InvestmentRecommendation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      profileId: 'default',
      type: type,
      name: name,
      description: description,
      recommendedAmount: amount,
      recommendedPercentage: 0.1,
      riskLevel: RiskLevel.medium,
      timeHorizon: TimeHorizon.mediumTerm,
      priority: InvestmentPriority.safety,
      expectedReturn: 0.08,
      reasoning: description,
      confidenceScore: 0.8,
      pros: [description],
      cons: ["Market volatility risk"],
      metadata: {},
      createdAt: DateTime.now(),
    );
  }

  static TimeHorizon _mapInvestmentTimelineToTimeHorizon(int years) {
    if (years <= 3) return TimeHorizon.shortTerm;
    if (years <= 10) return TimeHorizon.mediumTerm;
    return TimeHorizon.longTerm;
  }

  static Map<InvestmentType, double> _getDefaultAssetAllocation(
    RiskTolerance tolerance,
  ) {
    switch (tolerance) {
      case RiskTolerance.conservative:
        return {
          InvestmentType.bonds: 0.6,
          InvestmentType.bankDeposits: 0.3,
          InvestmentType.cash: 0.1,
        };
      case RiskTolerance.aggressive:
        return {
          InvestmentType.stocks: 0.7,
          InvestmentType.etfs: 0.2,
          InvestmentType.cash: 0.1,
        };
      default: // moderate
        return {
          InvestmentType.mutualFunds: 0.4,
          InvestmentType.stocks: 0.3,
          InvestmentType.bonds: 0.2,
          InvestmentType.cash: 0.1,
        };
    }
  }

  static double _calculateAverageMonthlyIncome(
    List<SalaryRecord> salaryRecords,
  ) {
    if (salaryRecords.isEmpty) return 0.0;
    double total = salaryRecords.fold(0, (sum, record) => sum + record.amount);
    return total / salaryRecords.length;
  }

  static double _calculateAverageMonthlySpending(
    List<Transaction> transactions,
  ) {
    List<Transaction> expenses = transactions
        .where((t) => t.amount < 0)
        .toList();
    if (expenses.isEmpty) return 0.0;

    Map<String, double> monthlyTotals = {};
    for (Transaction expense in expenses) {
      String monthKey = '${expense.date.year}-${expense.date.month}';
      monthlyTotals[monthKey] =
          (monthlyTotals[monthKey] ?? 0) + expense.amount.abs();
    }

    if (monthlyTotals.isEmpty) return 0.0;
    double totalSpending = monthlyTotals.values.fold(
      0,
      (sum, amount) => sum + amount,
    );
    return totalSpending / monthlyTotals.length;
  }

  static int _calculateInvestmentTimeline(int age, UserInvestmentGoals goals) {
    // Simple calculation based on age and goals
    if (goals.goalType == InvestmentGoal.retirement) {
      return math.max(65 - age, 5); // Minimum 5 years
    } else if (goals.goalType == InvestmentGoal.shortTerm) {
      return 2;
    } else {
      return 10; // Default medium term
    }
  }
}

