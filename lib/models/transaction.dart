class Transaction {
  final int? id;
  final double amount;
  final String type;
  final int categoryId;
  final int? incomeSourceId;
  final String? description;
  final String paymentMethod;
  final String? location;
  final String? receiptPhoto;
  final String? tags;
  final DateTime transactionDate;
  final DateTime createdAt;

  Transaction({
    this.id,
    required this.amount,
    required this.type,
    required this.categoryId,
    this.incomeSourceId,
    this.description,
    required this.paymentMethod,
    this.location,
    this.receiptPhoto,
    this.tags,
    required this.transactionDate,
    required this.createdAt,
  });

  // Thêm getter để tương thích với code khác
  DateTime get date => transactionDate;

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      amount: map['amount'],
      type: map['type'],
      categoryId: map['category_id'],
      incomeSourceId: map['income_source_id'],
      description: map['description'],
      paymentMethod: map['payment_method'],
      location: map['location'],
      receiptPhoto: map['receipt_photo'],
      tags: map['tags'],
      transactionDate: DateTime.parse(map['transaction_date']),
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'type': type,
      'category_id': categoryId,
      'income_source_id': incomeSourceId,
      'description': description,
      'payment_method': paymentMethod,
      'location': location,
      'receipt_photo': receiptPhoto,
      'tags': tags,
      'transaction_date': transactionDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

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

