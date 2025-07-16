class Bill {
  final int? id;
  final String name;
  final String description;
  final double amount;
  final String category;
  final String frequency; // monthly, weekly, quarterly, yearly, custom
  final DateTime dueDate;
  final DateTime? nextDueDate;
  final String reminderType; // notification, email, sms
  final int reminderDaysBefore;
  final bool isActive;
  final bool isFixed; // fixed amount or variable
  final String? paymentMethod;
  final String? merchantInfo;
  final String? accountNumber;
  final String? website;
  final String? notes;
  final DateTime createdAt;
  final DateTime? lastPaidDate;
  final String status; // upcoming, overdue, paid, paused

  Bill({
    this.id,
    required this.name,
    required this.description,
    required this.amount,
    required this.category,
    required this.frequency,
    required this.dueDate,
    this.nextDueDate,
    this.reminderType = 'notification',
    this.reminderDaysBefore = 3,
    this.isActive = true,
    this.isFixed = true,
    this.paymentMethod,
    this.merchantInfo,
    this.accountNumber,
    this.website,
    this.notes,
    required this.createdAt,
    this.lastPaidDate,
    this.status = 'upcoming',
  });

  factory Bill.fromMap(Map<String, dynamic> map) {
    return Bill(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      amount: map['amount'],
      category: map['category'],
      frequency: map['frequency'],
      dueDate: DateTime.parse(map['due_date']),
      nextDueDate: map['next_due_date'] != null
          ? DateTime.parse(map['next_due_date'])
          : null,
      reminderType: map['reminder_type'],
      reminderDaysBefore: map['reminder_days_before'],
      isActive: map['is_active'] == 1,
      isFixed: map['is_fixed'] == 1,
      paymentMethod: map['payment_method'],
      merchantInfo: map['merchant_info'],
      accountNumber: map['account_number'],
      website: map['website'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
      lastPaidDate: map['last_paid_date'] != null
          ? DateTime.parse(map['last_paid_date'])
          : null,
      status: map['status'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'amount': amount,
      'category': category,
      'frequency': frequency,
      'due_date': dueDate.toIso8601String(),
      'next_due_date': nextDueDate?.toIso8601String(),
      'reminder_type': reminderType,
      'reminder_days_before': reminderDaysBefore,
      'is_active': isActive ? 1 : 0,
      'is_fixed': isFixed ? 1 : 0,
      'payment_method': paymentMethod,
      'merchant_info': merchantInfo,
      'account_number': accountNumber,
      'website': website,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'last_paid_date': lastPaidDate?.toIso8601String(),
      'status': status,
    };
  }

  Bill copyWith({
    int? id,
    String? name,
    String? description,
    double? amount,
    String? category,
    String? frequency,
    DateTime? dueDate,
    DateTime? nextDueDate,
    String? reminderType,
    int? reminderDaysBefore,
    bool? isActive,
    bool? isFixed,
    String? paymentMethod,
    String? merchantInfo,
    String? accountNumber,
    String? website,
    String? notes,
    DateTime? createdAt,
    DateTime? lastPaidDate,
    String? status,
  }) {
    return Bill(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      dueDate: dueDate ?? this.dueDate,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      reminderType: reminderType ?? this.reminderType,
      reminderDaysBefore: reminderDaysBefore ?? this.reminderDaysBefore,
      isActive: isActive ?? this.isActive,
      isFixed: isFixed ?? this.isFixed,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      merchantInfo: merchantInfo ?? this.merchantInfo,
      accountNumber: accountNumber ?? this.accountNumber,
      website: website ?? this.website,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      lastPaidDate: lastPaidDate ?? this.lastPaidDate,
      status: status ?? this.status,
    );
  }

  // Helper methods
  DateTime calculateNextDueDate() {
    final currentNext = nextDueDate ?? dueDate;

    switch (frequency) {
      case 'weekly':
        return currentNext.add(const Duration(days: 7));
      case 'monthly':
        return DateTime(
          currentNext.year,
          currentNext.month + 1,
          currentNext.day,
        );
      case 'quarterly':
        return DateTime(
          currentNext.year,
          currentNext.month + 3,
          currentNext.day,
        );
      case 'yearly':
        return DateTime(
          currentNext.year + 1,
          currentNext.month,
          currentNext.day,
        );
      default:
        return currentNext.add(const Duration(days: 30)); // Default to monthly
    }
  }

  // Missing properties used in screens
  bool get isPaid => status == 'paid';
  String get title => name; // Alias for name

  bool isOverdue() {
    final now = DateTime.now();
    final due = nextDueDate ?? dueDate;
    return now.isAfter(due) && status != 'paid';
  }

  bool isDueSoon() {
    final now = DateTime.now();
    final due = nextDueDate ?? dueDate;
    final reminderDate = due.subtract(Duration(days: reminderDaysBefore));
    return now.isAfter(reminderDate) && now.isBefore(due) && status != 'paid';
  }

  int daysUntilDue() {
    final now = DateTime.now();
    final due = nextDueDate ?? dueDate;
    return due.difference(now).inDays;
  }

  double getTotalPaidThisYear() {
    // This would typically be calculated based on payment history
    // For now, we'll return a placeholder
    return 0.0;
  }

  String getFrequencyDisplayText() {
    switch (frequency) {
      case 'weekly':
        return 'Hàng tuần';
      case 'monthly':
        return 'Hàng tháng';
      case 'quarterly':
        return 'Hàng quý';
      case 'yearly':
        return 'Hàng năm';
      case 'custom':
        return 'Tùy chỉnh';
      default:
        return 'Hàng tháng';
    }
  }

  String getCategoryDisplayText() {
    switch (category) {
      case 'utilities':
        return 'Tiện ích';
      case 'internet':
        return 'Internet/TV';
      case 'phone':
        return 'Điện thoại';
      case 'insurance':
        return 'Bảo hiểm';
      case 'loan':
        return 'Vay/Nợ';
      case 'subscription':
        return 'Đăng ký';
      case 'rent':
        return 'Thuê nhà';
      case 'credit_card':
        return 'Thẻ tín dụng';
      case 'other':
        return 'Khác';
      default:
        return 'Khác';
    }
  }
}

