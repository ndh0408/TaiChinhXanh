import '../db/db_init.dart';
import '../models/bill.dart';
import '../models/bill_payment.dart';

class BillService {
  // Bill CRUD operations
  static Future<int> insert(Bill bill) async {
    final db = await AppDatabase.database;
    return await db.insert('bills', bill.toMap());
  }

  static Future<List<Bill>> getAll() async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bills',
      orderBy: 'next_due_date ASC, due_date ASC',
    );
    return List.generate(maps.length, (i) => Bill.fromMap(maps[i]));
  }

  static Future<List<Bill>> getActive() async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bills',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'next_due_date ASC, due_date ASC',
    );
    return List.generate(maps.length, (i) => Bill.fromMap(maps[i]));
  }

  static Future<List<Bill>> getOverdue() async {
    final db = await AppDatabase.database;
    final now = DateTime.now().toIso8601String().split('T')[0];
    final List<Map<String, dynamic>> maps = await db.query(
      'bills',
      where:
          'is_active = 1 AND status != "paid" AND (next_due_date < ? OR (next_due_date IS NULL AND due_date < ?))',
      whereArgs: [now, now],
      orderBy: 'next_due_date ASC, due_date ASC',
    );
    return List.generate(maps.length, (i) => Bill.fromMap(maps[i]));
  }

  static Future<List<Bill>> getDueSoon({int days = 7}) async {
    final db = await AppDatabase.database;
    final now = DateTime.now();
    final futureDate = now.add(Duration(days: days));
    final nowStr = now.toIso8601String().split('T')[0];
    final futureStr = futureDate.toIso8601String().split('T')[0];

    final List<Map<String, dynamic>> maps = await db.query(
      'bills',
      where: '''
        is_active = 1 AND status != "paid" AND 
        ((next_due_date BETWEEN ? AND ?) OR 
         (next_due_date IS NULL AND due_date BETWEEN ? AND ?))
      ''',
      whereArgs: [nowStr, futureStr, nowStr, futureStr],
      orderBy: 'next_due_date ASC, due_date ASC',
    );
    return List.generate(maps.length, (i) => Bill.fromMap(maps[i]));
  }

  static Future<List<Bill>> getByCategory(String category) async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bills',
      where: 'category = ? AND is_active = 1',
      whereArgs: [category],
      orderBy: 'next_due_date ASC, due_date ASC',
    );
    return List.generate(maps.length, (i) => Bill.fromMap(maps[i]));
  }

  static Future<Bill?> getById(int id) async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bills',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Bill.fromMap(maps.first);
    }
    return null;
  }

  static Future<int> update(Bill bill) async {
    final db = await AppDatabase.database;
    return await db.update(
      'bills',
      bill.toMap(),
      where: 'id = ?',
      whereArgs: [bill.id],
    );
  }

  static Future<int> delete(int id) async {
    final db = await AppDatabase.database;
    return await db.delete('bills', where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> toggleActive(int id, bool isActive) async {
    final db = await AppDatabase.database;
    return await db.update(
      'bills',
      {'is_active': isActive ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Bill Payment operations
  static Future<int> insertPayment(BillPayment payment) async {
    final db = await AppDatabase.database;
    return await db.insert('bill_payments', payment.toMap());
  }

  static Future<List<BillPayment>> getPaymentsByBill(int billId) async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bill_payments',
      where: 'bill_id = ?',
      whereArgs: [billId],
      orderBy: 'paid_date DESC',
    );
    return List.generate(maps.length, (i) => BillPayment.fromMap(maps[i]));
  }

  static Future<List<BillPayment>> getAllPayments() async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bill_payments',
      orderBy: 'paid_date DESC',
    );
    return List.generate(maps.length, (i) => BillPayment.fromMap(maps[i]));
  }

  static Future<BillPayment?> getLatestPayment(int billId) async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bill_payments',
      where: 'bill_id = ?',
      whereArgs: [billId],
      orderBy: 'paid_date DESC',
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return BillPayment.fromMap(maps.first);
    }
    return null;
  }

  // Business logic methods
  static Future<Bill> markAsPaid(
    int billId,
    double amountPaid, {
    String paymentMethod = 'cash',
    String? transactionId,
    String? confirmationNumber,
    String? notes,
    double? lateFee,
  }) async {
    final db = await AppDatabase.database;
    final bill = await getById(billId);

    if (bill == null) {
      throw Exception('Bill not found');
    }

    final now = DateTime.now();
    final dueDate = bill.nextDueDate ?? bill.dueDate;
    final isLate = now.isAfter(dueDate);
    final isPartialPayment = amountPaid < bill.amount;

    // Create payment record
    final payment = BillPayment(
      billId: billId,
      amountPaid: amountPaid,
      lateFee: lateFee,
      paidDate: now,
      dueDateWhenPaid: dueDate,
      paymentMethod: paymentMethod,
      transactionId: transactionId,
      confirmationNumber: confirmationNumber,
      notes: notes,
      isLate: isLate,
      isPartialPayment: isPartialPayment,
      createdAt: now,
    );

    await insertPayment(payment);

    // Update bill
    final nextDueDate = bill.calculateNextDueDate();
    final updatedBill = bill.copyWith(
      nextDueDate: nextDueDate,
      lastPaidDate: now,
      status: isPartialPayment ? 'upcoming' : 'paid',
    );

    await update(updatedBill);
    return updatedBill;
  }

  static Future<void> updateBillStatuses() async {
    final bills = await getActive();
    final now = DateTime.now();

    for (final bill in bills) {
      final dueDate = bill.nextDueDate ?? bill.dueDate;
      String newStatus = bill.status;

      if (now.isAfter(dueDate) && bill.status != 'paid') {
        newStatus = 'overdue';
      } else if (bill.status == 'paid' && now.isAfter(dueDate)) {
        // Reset status for next cycle
        newStatus = 'upcoming';
      }

      if (newStatus != bill.status) {
        await update(bill.copyWith(status: newStatus));
      }
    }
  }

  // Analytics and reporting
  static Future<Map<String, dynamic>> getBillStatistics() async {
    final db = await AppDatabase.database;

    // Total bills
    final totalResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM bills WHERE is_active = 1',
    );
    final totalBills = totalResult.first['count'] as int;

    // Overdue bills
    final now = DateTime.now().toIso8601String().split('T')[0];
    final overdueResult = await db.rawQuery(
      '''SELECT COUNT(*) as count FROM bills 
         WHERE is_active = 1 AND status = "overdue" AND 
         (next_due_date < ? OR (next_due_date IS NULL AND due_date < ?))''',
      [now, now],
    );
    final overdueBills = overdueResult.first['count'] as int;

    // Due soon (next 7 days)
    final futureDate = DateTime.now()
        .add(Duration(days: 7))
        .toIso8601String()
        .split('T')[0];
    final dueSoonResult = await db.rawQuery(
      '''SELECT COUNT(*) as count FROM bills 
         WHERE is_active = 1 AND status != "paid" AND 
         ((next_due_date BETWEEN ? AND ?) OR 
          (next_due_date IS NULL AND due_date BETWEEN ? AND ?))''',
      [now, futureDate, now, futureDate],
    );
    final dueSoonBills = dueSoonResult.first['count'] as int;

    // Total monthly amount
    final monthlyResult = await db.rawQuery('''SELECT SUM(
           CASE 
           WHEN frequency = 'weekly' THEN amount * 4.33
           WHEN frequency = 'monthly' THEN amount
           WHEN frequency = 'quarterly' THEN amount / 3
           WHEN frequency = 'yearly' THEN amount / 12
           ELSE amount
           END
         ) as total FROM bills WHERE is_active = 1''');
    final monthlyAmount = (monthlyResult.first['total'] as double?) ?? 0.0;

    return {
      'totalBills': totalBills,
      'overdueBills': overdueBills,
      'dueSoonBills': dueSoonBills,
      'monthlyAmount': monthlyAmount,
    };
  }

  static Future<Map<String, double>> getCategoryTotals() async {
    final db = await AppDatabase.database;
    final result = await db.rawQuery('''SELECT category, SUM(
           CASE 
           WHEN frequency = 'weekly' THEN amount * 4.33
           WHEN frequency = 'monthly' THEN amount
           WHEN frequency = 'quarterly' THEN amount / 3
           WHEN frequency = 'yearly' THEN amount / 12
           ELSE amount
           END
         ) as total 
         FROM bills 
         WHERE is_active = 1 
         GROUP BY category
         ORDER BY total DESC''');

    final Map<String, double> categoryTotals = {};
    for (final row in result) {
      categoryTotals[row['category'] as String] =
          (row['total'] as double?) ?? 0.0;
    }
    return categoryTotals;
  }

  static Future<double> getTotalPaidThisMonth() async {
    final db = await AppDatabase.database;
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    final result = await db.rawQuery(
      '''SELECT SUM(amount_paid + COALESCE(late_fee, 0)) as total 
         FROM bill_payments 
         WHERE paid_date BETWEEN ? AND ?''',
      [
        startOfMonth.toIso8601String().split('T')[0],
        endOfMonth.toIso8601String().split('T')[0],
      ],
    );

    return (result.first['total'] as double?) ?? 0.0;
  }

  static Future<double> getTotalPaidThisYear() async {
    final db = await AppDatabase.database;
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final endOfYear = DateTime(now.year, 12, 31);

    final result = await db.rawQuery(
      '''SELECT SUM(amount_paid + COALESCE(late_fee, 0)) as total 
         FROM bill_payments 
         WHERE paid_date BETWEEN ? AND ?''',
      [
        startOfYear.toIso8601String().split('T')[0],
        endOfYear.toIso8601String().split('T')[0],
      ],
    );

    return (result.first['total'] as double?) ?? 0.0;
  }

  static Future<List<Map<String, dynamic>>> getMonthlyPaymentTrends(
    int months,
  ) async {
    final db = await AppDatabase.database;
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month - months, 1);

    final result = await db.rawQuery(
      '''SELECT 
           strftime('%Y-%m', paid_date) as month,
           SUM(amount_paid + COALESCE(late_fee, 0)) as total,
           COUNT(*) as bill_count,
           SUM(CASE WHEN is_late = 1 THEN 1 ELSE 0 END) as late_count
         FROM bill_payments 
         WHERE paid_date >= ? 
         GROUP BY strftime('%Y-%m', paid_date)
         ORDER BY month DESC''',
      [startDate.toIso8601String().split('T')[0]],
    );

    return result
        .map(
          (row) => {
            'month': row['month'],
            'total': row['total'],
            'billCount': row['bill_count'],
            'lateCount': row['late_count'],
          },
        )
        .toList();
  }

  // Notification and reminder helpers
  static Future<List<Bill>> getBillsNeedingReminders() async {
    final bills = await getActive();
    final reminders = <Bill>[];

    for (final bill in bills) {
      if (bill.isDueSoon() || bill.isOverdue()) {
        reminders.add(bill);
      }
    }

    return reminders;
  }

  static Future<void> scheduleNextReminders() async {
    final bills = await getBillsNeedingReminders();
    // This would integrate with a notification scheduling service
    // For now, we'll just return the bills that need reminders
  }
}

