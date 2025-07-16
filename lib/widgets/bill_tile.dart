import 'package:flutter/material.dart';
import '../models/bill.dart';
import '../theme.dart';

class BillTile extends StatelessWidget {
  final Bill bill;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsPaid;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showUrgency;
  final bool isOverdue;

  const BillTile({
    Key? key,
    required this.bill,
    this.onTap,
    this.onMarkAsPaid,
    this.onEdit,
    this.onDelete,
    this.showUrgency = false,
    this.isOverdue = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dueDate = bill.nextDueDate ?? bill.dueDate;
    final daysUntilDue = bill.daysUntilDue();

    Color statusColor = AppTheme.primaryColor;
    IconData statusIcon = Icons.schedule;

    if (bill.isOverdue()) {
      statusColor = AppTheme.errorColor;
      statusIcon = Icons.warning;
    } else if (bill.isDueSoon()) {
      statusColor = AppTheme.warningColor;
      statusIcon = Icons.schedule_outlined;
    } else if (bill.status == 'paid') {
      statusColor = AppTheme.successColor;
      statusIcon = Icons.check_circle;
    }

    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: AppTheme.spacing2,
        vertical: AppTheme.spacing1,
      ),
      elevation: isOverdue ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        side: BorderSide(
          color: isOverdue
              ? AppTheme.errorColor.withValues(alpha: 0.3)
              : bill.isDueSoon()
              ? AppTheme.warningColor.withValues(alpha: 0.3)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        child: Padding(
          padding: EdgeInsets.all(AppTheme.spacing4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Category icon
                  Container(
                    padding: EdgeInsets.all(AppTheme.spacing2),
                    decoration: BoxDecoration(
                      color: _getCategoryColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        AppTheme.radiusMedium,
                      ),
                    ),
                    child: Icon(
                      _getCategoryIcon(),
                      color: _getCategoryColor(),
                      size: 24,
                    ),
                  ),

                  SizedBox(width: AppTheme.spacing3),

                  // Bill info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                bill.name,
                                style: AppTheme.titleMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (showUrgency)
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
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      statusIcon,
                                      color: statusColor,
                                      size: 16,
                                    ),
                                    SizedBox(width: AppTheme.spacing1),
                                    Text(
                                      isOverdue
                                          ? '${daysUntilDue.abs()}d quá hạn'
                                          : '${daysUntilDue}d',
                                      style: AppTheme.labelSmall.copyWith(
                                        color: statusColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),

                        if (bill.description.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: AppTheme.spacing1),
                            child: Text(
                              bill.description,
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.textMuted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Amount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${_formatAmount(bill.amount)}đ',
                        style: AppTheme.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                      Text(
                        bill.getFrequencyDisplayText(),
                        style: AppTheme.labelSmall.copyWith(
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: AppTheme.spacing3),

              // Due date and category
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: AppTheme.textMuted,
                    size: 16,
                  ),
                  SizedBox(width: AppTheme.spacing1),
                  Text(
                    'Đáo hạn: ${_formatDate(dueDate)}',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textMuted,
                    ),
                  ),

                  SizedBox(width: AppTheme.spacing4),

                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing2,
                      vertical: AppTheme.spacing1,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    child: Text(
                      bill.getCategoryDisplayText(),
                      style: AppTheme.labelSmall,
                    ),
                  ),

                  const Spacer(),

                  // Status indicator
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing2,
                      vertical: AppTheme.spacing1,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, color: statusColor, size: 14),
                        SizedBox(width: AppTheme.spacing1),
                        Text(
                          _getStatusText(),
                          style: AppTheme.labelSmall.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: AppTheme.spacing3),

              // Action buttons
              Row(
                children: [
                  if (bill.status != 'paid' && onMarkAsPaid != null)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onMarkAsPaid,
                        icon: const Icon(Icons.payment, size: 16),
                        label: const Text('Thanh toán'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.successColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusMedium,
                            ),
                          ),
                        ),
                      ),
                    ),

                  if (bill.status != 'paid' && onMarkAsPaid != null)
                    SizedBox(width: AppTheme.spacing2),

                  if (onEdit != null)
                    IconButton(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined),
                      color: AppTheme.primaryColor,
                      tooltip: 'Chỉnh sửa',
                    ),

                  if (onDelete != null)
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline),
                      color: AppTheme.errorColor,
                      tooltip: 'Xóa',
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor() {
    switch (bill.category) {
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

  IconData _getCategoryIcon() {
    switch (bill.category) {
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final billDate = DateTime(date.year, date.month, date.day);

    final difference = billDate.difference(today).inDays;

    if (difference == 0) {
      return 'Hôm nay';
    } else if (difference == 1) {
      return 'Ngày mai';
    } else if (difference == -1) {
      return 'Hôm qua';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _getStatusText() {
    if (bill.isOverdue()) {
      return 'Quá hạn';
    } else if (bill.isDueSoon()) {
      return 'Sắp hạn';
    } else if (bill.status == 'paid') {
      return 'Đã thanh toán';
    } else {
      return 'Bình thường';
    }
  }
}


