import 'package:flutter/material.dart';
import '../theme.dart';

class GoalTile extends StatelessWidget {
  final String name;
  final double targetAmount;
  final double? progress; // 0.0 - 1.0
  final DateTime targetDate;
  final String status; // in_progress, completed
  final int priority;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const GoalTile({
    Key? key,
    required this.name,
    required this.targetAmount,
    this.progress,
    required this.targetDate,
    required this.status,
    this.priority = 1,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: status == 'completed'
              ? AppTheme.secondaryColor.withValues(alpha: 0.15)
              : AppTheme.primaryColor.withValues(alpha: 0.15),
          child: Icon(
            status == 'completed' ? Icons.emoji_events : Icons.flag,
            color: status == 'completed'
                ? AppTheme.secondaryColor
                : AppTheme.primaryColor,
          ),
        ),
        title: Text(name, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mục tiêu: ₫${targetAmount.toStringAsFixed(0)} • Ưu tiên $priority',
            ),
            Text(
              'Hoàn thành: ${targetDate.day}/${targetDate.month}/${targetDate.year}',
            ),
            if (progress != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: LinearProgressIndicator(
                  value: progress!.clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: AppTheme.backgroundColor,
                  color: status == 'completed'
                      ? AppTheme.secondaryColor
                      : AppTheme.primaryColor,
                ),
              ),
            Text(
              status == 'completed' ? 'Đã hoàn thành' : 'Đang thực hiện',
              style: TextStyle(
                color: status == 'completed'
                    ? AppTheme.secondaryColor
                    : AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
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
      ),
    );
  }
}


