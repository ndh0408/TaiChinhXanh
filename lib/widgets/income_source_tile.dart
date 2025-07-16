import 'package:flutter/material.dart';
import '../theme.dart';

class IncomeSourceTile extends StatelessWidget {
  final String name;
  final String type;
  final double baseAmount;
  final String frequency;
  final bool isActive;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Color color;
  final IconData icon;

  const IncomeSourceTile({
    Key? key,
    required this.name,
    required this.type,
    required this.baseAmount,
    required this.frequency,
    required this.isActive,
    this.onEdit,
    this.onDelete,
    this.color = AppTheme.primaryColor,
    this.icon = Icons.monetization_on,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(name, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text('$type • $frequency\nSố tiền: ₫${baseAmount.toStringAsFixed(0)}', maxLines: 2),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isActive)
              const Icon(Icons.check_circle, color: Colors.green, size: 20)
            else
              const Icon(Icons.cancel, color: Colors.red, size: 20),
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

