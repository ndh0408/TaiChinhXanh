// Enums
enum RiskTolerance { conservative, moderate, aggressive, veryAggressive }

enum InvestmentGoal {
  retirement,
  homeDownPayment,
  homeOwnership, // Thêm constant bị thiếu
  education,
  emergencyFund,
  wealthBuilding,
  shortTermSavings,
  shortTerm, // Thêm constant bị thiếu
}

enum InvestmentType {
  stocks,
  bonds,
  mutualFunds,
  etfs,
  realEstate,
  gold,
  crypto,
  bankDeposits,
  governmentBonds,
  // Thêm các constants bị thiếu
  cash,
  savings,
  indexFund,
  commodities,
  educationSavings,
  retirement,
}

enum RiskLevel {
  veryLow,
  low,
  mediumLow, // Thêm constant bị thiếu
  medium,
  mediumHigh, // Thêm constant bị thiếu
  high,
  veryHigh,
}

enum TimeHorizon { shortTerm, mediumTerm, longTerm }

enum InvestmentPriority {
  safety,
  growth,
  income,
  liquidity,
  taxEfficiency,
  // Thêm các constants bị thiếu
  low,
  medium,
  high,
}

// Models
class InvestmentProfile {
  final String id;
  final double monthlyIncome;
  final double monthlyExpenses;
  final double currentSavings;
  final double currentInvestments;
  final int age;
  final RiskTolerance riskTolerance;
  final List<InvestmentGoal> goals;
  final TimeHorizon timeHorizon;
  final List<InvestmentPriority> priorities;
  final DateTime createdAt;
  final DateTime updatedAt;
  // Thêm properties bị thiếu
  final int investmentTimelineYears;
  final Map<InvestmentType, double> assetAllocation;
  final InvestmentCapacity investmentCapacity;

  InvestmentProfile({
    required this.id,
    required this.monthlyIncome,
    required this.monthlyExpenses,
    required this.currentSavings,
    required this.currentInvestments,
    required this.age,
    required this.riskTolerance,
    required this.goals,
    required this.timeHorizon,
    required this.priorities,
    required this.createdAt,
    required this.updatedAt,
    // Thêm parameters mới
    this.investmentTimelineYears = 10,
    this.assetAllocation = const {},
    required this.investmentCapacity,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'monthlyIncome': monthlyIncome,
      'monthlyExpenses': monthlyExpenses,
      'currentSavings': currentSavings,
      'currentInvestments': currentInvestments,
      'age': age,
      'riskTolerance': riskTolerance.toString(),
      'goals': goals.map((g) => g.toString()).toList().join(','),
      'timeHorizon': timeHorizon.toString(),
      'priorities': priorities.map((p) => p.toString()).toList().join(','),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'investmentTimelineYears': investmentTimelineYears,
    };
  }

  factory InvestmentProfile.fromMap(Map<String, dynamic> map) {
    return InvestmentProfile(
      id: map['id'],
      monthlyIncome: map['monthlyIncome']?.toDouble() ?? 0.0,
      monthlyExpenses: map['monthlyExpenses']?.toDouble() ?? 0.0,
      currentSavings: map['currentSavings']?.toDouble() ?? 0.0,
      currentInvestments: map['currentInvestments']?.toDouble() ?? 0.0,
      age: map['age']?.toInt() ?? 0,
      riskTolerance: RiskTolerance.values.firstWhere(
        (e) => e.toString() == map['riskTolerance'],
        orElse: () => RiskTolerance.moderate,
      ),
      goals:
          (map['goals'] as String?)
              ?.split(',')
              .map(
                (g) => InvestmentGoal.values.firstWhere(
                  (e) => e.toString() == g,
                  orElse: () => InvestmentGoal.wealthBuilding,
                ),
              )
              .toList() ??
          [],
      timeHorizon: TimeHorizon.values.firstWhere(
        (e) => e.toString() == map['timeHorizon'],
        orElse: () => TimeHorizon.longTerm,
      ),
      priorities:
          (map['priorities'] as String?)
              ?.split(',')
              .map(
                (p) => InvestmentPriority.values.firstWhere(
                  (e) => e.toString() == p,
                  orElse: () => InvestmentPriority.growth,
                ),
              )
              .toList() ??
          [],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      investmentTimelineYears: map['investmentTimelineYears']?.toInt() ?? 10,
      investmentCapacity: InvestmentCapacity(
        disposableIncome: map['disposableIncome']?.toDouble() ?? 0.0,
        riskCapacity: map['riskCapacity']?.toDouble() ?? 0.0,
        liquidityNeeds: map['liquidityNeeds']?.toDouble() ?? 0.0,
        emergencyFundStatus: map['emergencyFundStatus']?.toDouble() ?? 0.0,
        debtToIncomeRatio: map['debtToIncomeRatio']?.toDouble() ?? 0.0,
      ),
    );
  }
}

class InvestmentCapacity {
  final double disposableIncome;
  final double riskCapacity;
  final double liquidityNeeds;
  final double emergencyFundStatus;
  final double debtToIncomeRatio;

  InvestmentCapacity({
    required this.disposableIncome,
    required this.riskCapacity,
    required this.liquidityNeeds,
    required this.emergencyFundStatus,
    required this.debtToIncomeRatio,
  });
}

class UserInvestmentGoals {
  final String id;
  final InvestmentGoal goalType;
  final double targetAmount;
  final DateTime targetDate;
  final double currentAmount;
  final int priority;

  UserInvestmentGoals({
    required this.id,
    required this.goalType,
    required this.targetAmount,
    required this.targetDate,
    required this.currentAmount,
    required this.priority,
  });

  // Thêm getter để tương thích
  InvestmentGoal get primaryGoal => goalType;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'goalType': goalType.toString(),
      'targetAmount': targetAmount,
      'targetDate': targetDate.toIso8601String(),
      'currentAmount': currentAmount,
      'priority': priority,
    };
  }

  factory UserInvestmentGoals.fromMap(Map<String, dynamic> map) {
    return UserInvestmentGoals(
      id: map['id'],
      goalType: InvestmentGoal.values.firstWhere(
        (e) => e.toString() == map['goalType'],
        orElse: () => InvestmentGoal.wealthBuilding,
      ),
      targetAmount: map['targetAmount']?.toDouble() ?? 0.0,
      targetDate: DateTime.parse(map['targetDate']),
      currentAmount: map['currentAmount']?.toDouble() ?? 0.0,
      priority: map['priority']?.toInt() ?? 0,
    );
  }
}

class InvestmentRecommendation {
  final String id;
  final String profileId;
  final InvestmentType type;
  final String name;
  final String description;
  final double recommendedAmount;
  final double recommendedPercentage;
  final RiskLevel riskLevel;
  final TimeHorizon timeHorizon;
  final InvestmentPriority priority;
  final double expectedReturn;
  final String reasoning;
  final double confidenceScore;
  final List<String> pros;
  final List<String> cons;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  InvestmentRecommendation({
    required this.id,
    required this.profileId,
    required this.type,
    required this.name,
    required this.description,
    required this.recommendedAmount,
    required this.recommendedPercentage,
    required this.riskLevel,
    required this.timeHorizon,
    required this.priority,
    required this.expectedReturn,
    required this.reasoning,
    required this.confidenceScore,
    required this.pros,
    required this.cons,
    required this.metadata,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profileId': profileId,
      'type': type.toString(),
      'name': name,
      'description': description,
      'recommendedAmount': recommendedAmount,
      'recommendedPercentage': recommendedPercentage,
      'riskLevel': riskLevel.toString(),
      'timeHorizon': timeHorizon.toString(),
      'priority': priority.toString(),
      'expectedReturn': expectedReturn,
      'reasoning': reasoning,
      'confidenceScore': confidenceScore,
      'pros': pros.join('|'),
      'cons': cons.join('|'),
      'metadata': metadata.toString(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory InvestmentRecommendation.fromMap(Map<String, dynamic> map) {
    return InvestmentRecommendation(
      id: map['id'],
      profileId: map['profileId'],
      type: InvestmentType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => InvestmentType.stocks,
      ),
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      recommendedAmount: map['recommendedAmount']?.toDouble() ?? 0.0,
      recommendedPercentage: map['recommendedPercentage']?.toDouble() ?? 0.0,
      riskLevel: RiskLevel.values.firstWhere(
        (e) => e.toString() == map['riskLevel'],
        orElse: () => RiskLevel.medium,
      ),
      timeHorizon: TimeHorizon.values.firstWhere(
        (e) => e.toString() == map['timeHorizon'],
        orElse: () => TimeHorizon.longTerm,
      ),
      priority: InvestmentPriority.values.firstWhere(
        (e) => e.toString() == map['priority'],
        orElse: () => InvestmentPriority.growth,
      ),
      expectedReturn: map['expectedReturn']?.toDouble() ?? 0.0,
      reasoning: map['reasoning'] ?? '',
      confidenceScore: map['confidenceScore']?.toDouble() ?? 0.0,
      pros: (map['pros'] as String?)?.split('|') ?? [],
      cons: (map['cons'] as String?)?.split('|') ?? [],
      metadata: map['metadata'] ?? {},
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}

class Investment {
  final String id;
  final String userId;
  final InvestmentType type;
  final String name;
  final double initialAmount;
  final double? currentValue;
  final double? annualDividendYield;
  final DateTime purchaseDate;
  final RiskLevel riskLevel;
  final Map<String, dynamic> metadata;
  final String? sector; // Thêm sector

  Investment({
    required this.id,
    required this.userId,
    required this.type,
    required this.name,
    required this.initialAmount,
    this.currentValue,
    this.annualDividendYield,
    required this.purchaseDate,
    required this.riskLevel,
    required this.metadata,
    this.sector, // Thêm sector
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type.toString(),
      'name': name,
      'initialAmount': initialAmount,
      'currentValue': currentValue,
      'annualDividendYield': annualDividendYield,
      'purchaseDate': purchaseDate.toIso8601String(),
      'riskLevel': riskLevel.toString(),
      'metadata': metadata.toString(),
      'sector': sector, // Thêm sector
    };
  }

  factory Investment.fromMap(Map<String, dynamic> map) {
    return Investment(
      id: map['id'],
      userId: map['userId'],
      type: InvestmentType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => InvestmentType.stocks,
      ),
      name: map['name'],
      initialAmount: map['initialAmount']?.toDouble() ?? 0.0,
      currentValue: map['currentValue']?.toDouble(),
      annualDividendYield: map['annualDividendYield']?.toDouble(),
      purchaseDate: DateTime.parse(map['purchaseDate']),
      riskLevel: RiskLevel.values.firstWhere(
        (e) => e.toString() == map['riskLevel'],
        orElse: () => RiskLevel.medium,
      ),
      metadata: map['metadata'] ?? {},
      sector: map['sector'], // Thêm sector
    );
  }
}

class PortfolioAnalysis {
  final String id;
  final String userId;
  final double totalValue;
  final Map<InvestmentType, double> allocation;
  final double overallRiskScore;
  final double expectedReturn;
  final double sharpeRatio;
  final double beta;
  final DateTime analysisDate;

  PortfolioAnalysis({
    required this.id,
    required this.userId,
    required this.totalValue,
    required this.allocation,
    required this.overallRiskScore,
    required this.expectedReturn,
    required this.sharpeRatio,
    required this.beta,
    required this.analysisDate,
  });
}

class RebalancingRecommendation {
  final String id;
  final String portfolioId;
  final Map<InvestmentType, double> currentAllocation;
  final Map<InvestmentType, double> targetAllocation;
  final List<String> actions;
  final double priorityScore;
  final String reasoning;
  final DateTime createdAt;

  RebalancingRecommendation({
    required this.id,
    required this.portfolioId,
    required this.currentAllocation,
    required this.targetAllocation,
    required this.actions,
    required this.priorityScore,
    required this.reasoning,
    required this.createdAt,
  });
}

class DiversificationAnalysis {
  final String id;
  final String portfolioId;
  final double diversificationScore;
  final Map<String, double> concentrationRisks;
  final List<String> recommendations;
  final DateTime analysisDate;

  DiversificationAnalysis({
    required this.id,
    required this.portfolioId,
    required this.diversificationScore,
    required this.concentrationRisks,
    required this.recommendations,
    required this.analysisDate,
  });
}

class TaxEfficiencyAnalysis {
  final String id;
  final String portfolioId;
  final double taxEfficiencyScore;
  final double estimatedTaxLiability;
  final List<String> taxOptimizationRecommendations;
  final DateTime analysisDate;

  TaxEfficiencyAnalysis({
    required this.id,
    required this.portfolioId,
    required this.taxEfficiencyScore,
    required this.estimatedTaxLiability,
    required this.taxOptimizationRecommendations,
    required this.analysisDate,
  });
}

