import 'package:flutter/material.dart';
import '../models/bill.dart';
import '../theme.dart';

class BillRemindersCard extends StatelessWidget {
  final List<Bill> bills;
  final Function(Bill)? onBillTap;
  final Function(Bill)? onMarkAsPaid;

  const BillRemindersCard({
    Key? key,
    required this.bills,
    this.onBillTap,
    this.onMarkAsPaid,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (bills.isEmpty) {
      return const SizedBox.shrink();
    }

    final overdueBills = bills.where((bill) => bill.isOverdue()).toList();
    final dueSoonBills = bills
        .where((bill) => bill.isDueSoon() && !bill.isOverdue())
        .toList();

    return Container(
      margin: EdgeInsets.all(AppTheme.spacing4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.notifications_active,
                color: overdueBills.isNotEmpty
                    ? AppTheme.errorColor
                    : AppTheme.warningColor,
                size: 24,
              ),
              SizedBox(width: AppTheme.spacing2),
              Text(
                'Nhắc nhở thanh toán',
                style: AppTheme.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (bills.length > 3)
                TextButton(
                  onPressed: () {
                    // TODO: Show all bills
                  },
                  child: Text(
                    'Xem tất cả (${bills.length})',
                    style: AppTheme.labelMedium.copyWith(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(height: AppTheme.spacing3),

          // Overdue bills section
          if (overdueBills.isNotEmpty) ...[
            _buildSectionHeader(
              'Quá hạn',
              overdueBills.length,
              AppTheme.errorColor,
              Icons.warning,
            ),
            SizedBox(height: AppTheme.spacing2),
            ...overdueBills
                .take(3)
                .map((bill) => _buildBillItem(bill, true, context)),
            if (overdueBills.length > 3)
              _buildMoreItemsIndicator(
                overdueBills.length - 3,
                AppTheme.errorColor,
              ),
            SizedBox(height: AppTheme.spacing4),
          ],

          // Due soon bills section
          if (dueSoonBills.isNotEmpty) ...[
            _buildSectionHeader(
              'Sắp đến hạn',
              dueSoonBills.length,
              AppTheme.warningColor,
              Icons.schedule,
            ),
            SizedBox(height: AppTheme.spacing2),
            ...dueSoonBills
                .take(3)
                .map((bill) => _buildBillItem(bill, false, context)),
            if (dueSoonBills.length > 3)
              _buildMoreItemsIndicator(
                dueSoonBills.length - 3,
                AppTheme.warningColor,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    int count,
    Color color,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(AppTheme.spacing1),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        SizedBox(width: AppTheme.spacing2),
        Text(
          title,
          style: AppTheme.labelLarge.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(width: AppTheme.spacing1),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppTheme.spacing2,
            vertical: AppTheme.spacing1,
          ),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
          ),
          child: Text(
            count.toString(),
            style: AppTheme.labelSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBillItem(Bill bill, bool isOverdue, BuildContext context) {
    final daysUntilDue = bill.daysUntilDue();
    final statusColor = isOverdue ? AppTheme.errorColor : AppTheme.warningColor;

    return Container(
      margin: EdgeInsets.only(bottom: AppTheme.spacing2),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          side: BorderSide(color: statusColor.withValues(alpha: 0.2), width: 1),
        ),
        child: InkWell(
          onTap: () => onBillTap?.call(bill),
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          child: Padding(
            padding: EdgeInsets.all(AppTheme.spacing4),
            child: Row(
              children: [
                // Category icon
                Container(
                  padding: EdgeInsets.all(AppTheme.spacing2),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(bill.category).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: Icon(
                    _getCategoryIcon(bill.category),
                    color: _getCategoryColor(bill.category),
                    size: 20,
                  ),
                ),

                SizedBox(width: AppTheme.spacing3),

                // Bill info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bill.name,
                        style: AppTheme.titleMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: AppTheme.spacing1),
                      Row(
                        children: [
                          Text(
                            '${_formatAmount(bill.amount)}đ',
                            style: AppTheme.bodyMedium.copyWith(
                              fontWeight: FontWeight.w500,
                              color: statusColor,
                            ),
                          ),
                          SizedBox(width: AppTheme.spacing2),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppTheme.spacing2,
                              vertical: AppTheme.spacing1,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusSmall,
                              ),
                            ),
                            child: Text(
                              isOverdue
                                  ? '${daysUntilDue.abs()} ngày quá hạn'
                                  : 'Còn ${daysUntilDue} ngày',
                              style: AppTheme.labelSmall.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Action button
                if (onMarkAsPaid != null)
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => onMarkAsPaid!.call(bill),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.successColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          minimumSize: Size(80, 32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusMedium,
                            ),
                          ),
                        ),
                        child: Text(
                          'Thanh toán',
                          style: AppTheme.labelSmall.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoreItemsIndicator(int count, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: AppTheme.spacing2),
      child: Card(
        elevation: 1,
        color: color.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          side: BorderSide(color: color.withValues(alpha: 0.2), width: 1),
        ),
        child: Padding(
          padding: EdgeInsets.all(AppTheme.spacing4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.more_horiz, color: color, size: 20),
              SizedBox(width: AppTheme.spacing2),
              Text(
                'Và $count hóa đơn khác',
                style: AppTheme.bodyMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'utilities':
        return const Color(0xFF4CAF50); // Green
      case 'internet':
        return const Color(0xFF2196F3); // Blue
      case 'phone':
        return const Color(0xFF9C27B0); // Purple
      case 'insurance':
        return const Color(0xFFFF9800); // Orange
      case 'loan':
        return const Color(0xFFF44336); // Red
      case 'subscription':
        return const Color(0xFF607D8B); // Blue Grey
      case 'rent':
        return const Color(0xFF795548); // Brown
      case 'credit_card':
        return const Color(0xFFE91E63); // Pink
      default:
        return AppTheme.primaryColor;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'utilities':
        return Icons.electrical_services;
      case 'internet':
        return Icons.wifi;
      case 'phone':
        return Icons.phone_android;
      case 'insurance':
        return Icons.security;
      case 'loan':
        return Icons.account_balance;
      case 'subscription':
        return Icons.subscriptions;
      case 'rent':
        return Icons.home;
      case 'credit_card':
        return Icons.credit_card;
      default:
        return Icons.receipt;
    }
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    } else {
      return amount.toStringAsFixed(0);
    }
  }
}


