// SQLite Database Schema
const String incomeSourcesTable = '''
CREATE TABLE income_sources (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    type TEXT CHECK(type IN ('salary', 'freelance', 'business', 'investment', 'other')),
    base_amount REAL DEFAULT 0,
    frequency TEXT CHECK(frequency IN ('daily', 'weekly', 'monthly', 'quarterly', 'yearly', 'irregular')),
    tax_rate REAL DEFAULT 0,
    is_active INTEGER DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
''';

const String salaryRecordsTable = '''
CREATE TABLE salary_records (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    income_source_id INTEGER NOT NULL,
    gross_amount REAL NOT NULL,
    net_amount REAL NOT NULL,
    bonus_amount REAL DEFAULT 0,
    deductions_amount REAL DEFAULT 0,
    received_date DATE NOT NULL,
    working_days INTEGER DEFAULT 0,
    notes TEXT,
    FOREIGN KEY (income_source_id) REFERENCES income_sources(id)
);
''';

const String transactionsTable = '''
CREATE TABLE transactions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    amount REAL NOT NULL,
    type TEXT CHECK(type IN ('income', 'expense')),
    category_id INTEGER NOT NULL,
    income_source_id INTEGER,
    description TEXT,
    payment_method TEXT DEFAULT 'cash',
    location TEXT,
    receipt_photo TEXT,
    tags TEXT,
    transaction_date DATE NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
''';

const String categoriesTable = '''
CREATE TABLE categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    type TEXT CHECK(type IN ('income', 'expense')),
    color TEXT DEFAULT '#2196F3',
    icon TEXT DEFAULT 'money',
    budget_limit REAL DEFAULT 0,
    is_essential INTEGER DEFAULT 0,
    priority INTEGER DEFAULT 1
);
''';

const String aiAnalyticsTable = '''
CREATE TABLE ai_analytics (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    analysis_type TEXT NOT NULL,
    input_data TEXT,
    result_data TEXT,
    confidence_score REAL DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
''';

const String aiSuggestionsTable = '''
CREATE TABLE ai_suggestions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    type TEXT NOT NULL,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    priority INTEGER DEFAULT 1,
    is_read INTEGER DEFAULT 0,
    trigger_conditions TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
''';

const String billsTable = '''
CREATE TABLE bills (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT,
    amount REAL NOT NULL,
    category TEXT NOT NULL,
    frequency TEXT CHECK(frequency IN ('weekly', 'monthly', 'quarterly', 'yearly', 'custom')) DEFAULT 'monthly',
    due_date DATE NOT NULL,
    next_due_date DATE,
    reminder_type TEXT DEFAULT 'notification',
    reminder_days_before INTEGER DEFAULT 3,
    is_active INTEGER DEFAULT 1,
    is_fixed INTEGER DEFAULT 1,
    payment_method TEXT,
    merchant_info TEXT,
    account_number TEXT,
    website TEXT,
    notes TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_paid_date DATE,
    status TEXT CHECK(status IN ('upcoming', 'overdue', 'paid', 'paused')) DEFAULT 'upcoming'
);
''';

const String billPaymentsTable = '''
CREATE TABLE bill_payments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    bill_id INTEGER NOT NULL,
    amount_paid REAL NOT NULL,
    late_fee REAL DEFAULT 0,
    paid_date DATE NOT NULL,
    due_date_when_paid DATE NOT NULL,
    payment_method TEXT NOT NULL,
    transaction_id TEXT,
    confirmation_number TEXT,
    notes TEXT,
    is_late INTEGER DEFAULT 0,
    is_partial_payment INTEGER DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (bill_id) REFERENCES bills(id) ON DELETE CASCADE
);
''';

const String financialPredictionsTable = '''
CREATE TABLE financial_predictions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    prediction_type TEXT CHECK(prediction_type IN ('spending', 'income', 'cash_flow')) NOT NULL,
    prediction_date DATE NOT NULL,
    target_date DATE NOT NULL,
    predicted_amount REAL NOT NULL,
    confidence_score REAL CHECK(confidence_score >= 0 AND confidence_score <= 1) NOT NULL,
    method TEXT NOT NULL,
    metadata TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
''';

const String budgetsTable = '''
CREATE TABLE budgets (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    categoryId TEXT NOT NULL,
    amount REAL NOT NULL,
    spentAmount REAL DEFAULT 0.0,
    type TEXT CHECK(type IN ('BudgetType.fixed', 'BudgetType.flexible', 'BudgetType.aiSuggested', 'BudgetType.percentage')) NOT NULL,
    period TEXT CHECK(period IN ('BudgetPeriod.weekly', 'BudgetPeriod.biweekly', 'BudgetPeriod.monthly', 'BudgetPeriod.quarterly', 'BudgetPeriod.yearly')) NOT NULL,
    startDate DATE NOT NULL,
    endDate DATE NOT NULL,
    isActive INTEGER DEFAULT 1,
    isAIGenerated INTEGER DEFAULT 0,
    suggestedAmount REAL,
    aiReason TEXT,
    status TEXT CHECK(status IN ('BudgetStatus.active', 'BudgetStatus.paused', 'BudgetStatus.completed', 'BudgetStatus.cancelled')) NOT NULL,
    alertThresholds TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (categoryId) REFERENCES categories (id)
);
''';

const String budgetSuggestionsTable = '''
CREATE TABLE budget_suggestions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    categoryId TEXT NOT NULL,
    categoryName TEXT NOT NULL,
    suggestedAmount REAL NOT NULL,
    currentSpending REAL NOT NULL,
    historicalAverage REAL NOT NULL,
    reason TEXT NOT NULL,
    confidence REAL CHECK(confidence >= 0 AND confidence <= 1) NOT NULL,
    type TEXT CHECK(type IN ('BudgetSuggestionType.increase', 'BudgetSuggestionType.decrease', 'BudgetSuggestionType.maintain', 'BudgetSuggestionType.create')) NOT NULL,
    tips TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (categoryId) REFERENCES categories (id)
);
''';

const String expenseForecastsTable = '''
CREATE TABLE expense_forecasts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    categoryId TEXT NOT NULL,
    categoryName TEXT NOT NULL,
    forecastAmount REAL NOT NULL,
    forecastPeriod INTEGER NOT NULL,
    confidence REAL CHECK(confidence >= 0 AND confidence <= 1) NOT NULL,
    method TEXT NOT NULL,
    generatedAt DATETIME NOT NULL,
    validUntil DATETIME NOT NULL,
    metadata TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (categoryId) REFERENCES categories (id)
);
''';

const String expenseAnomaliesTable = '''
CREATE TABLE expense_anomalies (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    transactionId TEXT NOT NULL,
    categoryId TEXT NOT NULL,
    categoryName TEXT NOT NULL,
    amount REAL NOT NULL,
    expectedAmount REAL NOT NULL,
    deviation REAL NOT NULL,
    anomalyType TEXT NOT NULL,
    severity TEXT NOT NULL,
    description TEXT NOT NULL,
    detectedAt DATETIME NOT NULL,
    additionalData TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (transactionId) REFERENCES transactions (id),
    FOREIGN KEY (categoryId) REFERENCES categories (id)
);
''';

const String categoryPredictionsTable = '''
CREATE TABLE category_predictions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    categoryId TEXT NOT NULL,
    categoryName TEXT NOT NULL,
    predictedAmount REAL NOT NULL,
    confidence REAL CHECK(confidence >= 0 AND confidence <= 1) NOT NULL,
    trend TEXT NOT NULL,
    historicalAverage REAL NOT NULL,
    recommendations TEXT NOT NULL,
    forecastPeriod INTEGER NOT NULL,
    generatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (categoryId) REFERENCES categories (id)
);
''';

const String seasonalAnalysisTable = '''
CREATE TABLE seasonal_analysis (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    monthlyPatterns TEXT NOT NULL,
    weeklyPatterns TEXT NOT NULL,
    peakMonth INTEGER NOT NULL,
    peakWeekday INTEGER NOT NULL,
    seasonalityStrength REAL NOT NULL,
    insights TEXT NOT NULL,
    analysisMonths INTEGER NOT NULL,
    generatedAt DATETIME DEFAULT CURRENT_TIMESTAMP
);
''';

const String budgetVarianceAlertsTable = '''
CREATE TABLE budget_variance_alerts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    categoryId TEXT NOT NULL,
    budgetAmount REAL NOT NULL,
    actualAmount REAL NOT NULL,
    variance REAL NOT NULL,
    severity TEXT NOT NULL,
    message TEXT NOT NULL,
    detectedAt DATETIME NOT NULL,
    acknowledged INTEGER DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (categoryId) REFERENCES categories (id)
);
''';

