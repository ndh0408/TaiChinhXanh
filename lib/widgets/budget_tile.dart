import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/budget.dart';

class BudgetTile extends StatelessWidget {
  final String? name;
  final String? type;
  final Color? color;
  final IconData? icon;
  final double? budgetLimit;
  final bool isEssential;
  final int priority;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  // New parameters for Budget object
  final Budget? budget;
  final VoidCallback? onTap;

  const BudgetTile({
    Key? key,
    this.name,
    this.type,
    this.color,
    this.icon,
    this.budgetLimit,
    this.isEssential = false,
    this.priority = 1,
    this.onEdit,
    this.onDelete,
    this.budget,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use budget data if available, otherwise use individual properties
    final String displayName = name ?? budget?.name ?? 'Ngân sách';
    final String displayType =
        type ?? (budget?.type.toString().split('.').last ?? 'expense');
    final Color displayColor =
        color ?? _getColorFromBudgetType(budget?.type) ?? AppTheme.primaryColor;
    final IconData displayIcon =
        icon ??
        _getIconFromBudgetType(budget?.type) ??
        Icons.account_balance_wallet;
    final double? displayLimit = budgetLimit ?? budget?.budgetLimit;
    final bool displayEssential = budget?.isEssential ?? isEssential;
    final int displayPriority = budget?.priority ?? priority;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: displayColor.withValues(alpha: 0.15),
          child: Icon(displayIcon, color: displayColor),
        ),
        title: Text(
          displayName,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${displayType == 'income' ? 'Thu nhập' : 'Chi tiêu'} • Ưu tiên $displayPriority',
            ),
            if (displayLimit != null)
              Text('Hạn mức: ₫${displayLimit.toStringAsFixed(0)}'),
            if (displayEssential)
              const Text(
                'Thiết yếu',
                style: TextStyle(
                  color: AppTheme.warningColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (budget != null) ...[
              Text('Đã chi: ₫${budget!.spentAmount.toStringAsFixed(0)}'),
              Text('Còn lại: ₫${budget!.remainingAmount.toStringAsFixed(0)}'),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: AppTheme.primaryColor),
              onPressed: onEdit,
              tooltip: 'Sửa',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: AppTheme.errorColor),
              onPressed: onDelete,
              tooltip: 'Xóa',
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  Color _getColorFromBudgetType(BudgetType? type) {
    switch (type) {
      case BudgetType.fixed:
        return AppTheme.primaryColor;
      case BudgetType.flexible:
        return AppTheme.successColor;
      case BudgetType.aiSuggested:
        return AppTheme.accentOrange;
      case BudgetType.percentage:
        return AppTheme.primaryColor;
      default:
        return AppTheme.primaryColor;
    }
  }

  IconData _getIconFromBudgetType(BudgetType? type) {
    switch (type) {
      case BudgetType.fixed:
        return Icons.lock;
      case BudgetType.flexible:
        return Icons.trending_up;
      case BudgetType.aiSuggested:
        return Icons.smart_toy;
      case BudgetType.percentage:
        return Icons.percent;
      default:
        return Icons.account_balance_wallet;
    }
  }

  IconData _getTypeIcon() {
    return _getIconFromBudgetType(budget?.type);
  }

  String _getTypeText() {
    switch (budget?.type) {
      case BudgetType.fixed:
        return 'Cố định';
      case BudgetType.flexible:
        return 'Linh hoạt';
      case BudgetType.aiSuggested:
        return 'AI gợi ý';
      case BudgetType.percentage:
        return 'Phần trăm';
      default:
        return 'Khác';
    }
  }
}


