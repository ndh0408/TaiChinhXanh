import 'package:flutter/material.dart';
import '../models/ai_suggestion.dart';

class AISuggestionsCard extends StatelessWidget {
  final List<AISuggestion> suggestions;
  final Function(AISuggestion)? onSuggestionTap;
  final Function(AISuggestion)? onMarkAsRead;
  final Function()? onViewAll;

  const AISuggestionsCard({
    Key? key,
    required this.suggestions,
    this.onSuggestionTap,
    this.onMarkAsRead,
    this.onViewAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unreadSuggestions = suggestions.where((s) => !s.isRead).toList();
    final displaySuggestions = unreadSuggestions.take(3).toList();

    if (suggestions.isEmpty) {
      return _buildEmptyState(theme);
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(theme, unreadSuggestions.length),

            const SizedBox(height: 16),

            // Suggestions List
            ...displaySuggestions
                .map((suggestion) => _buildSuggestionTile(theme, suggestion))
                .toList(),

            // View All Button
            if (suggestions.length > 3) ...[
              const SizedBox(height: 12),
              _buildViewAllButton(theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: 48,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 12),
            Text(
              'Gợi ý AI',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Chưa có gợi ý nào. Hãy thêm dữ liệu giao dịch để AI có thể phân tích và đưa ra gợi ý cá nhân hóa.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, int unreadCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.psychology, color: theme.colorScheme.primary, size: 24),
            const SizedBox(width: 8),
            Text(
              'Gợi ý AI',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        IconButton(
          onPressed: onViewAll,
          icon: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionTile(ThemeData theme, AISuggestion suggestion) {
    final priorityColor = _getPriorityColor(suggestion.priority);
    final typeIcon = _getTypeIcon(suggestion.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => onSuggestionTap?.call(suggestion),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: suggestion.isRead
                ? theme.colorScheme.surface
                : priorityColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: suggestion.isRead
                  ? theme.dividerColor
                  : priorityColor.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and Icon
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: priorityColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(typeIcon, color: priorityColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          suggestion.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: suggestion.isRead
                                ? theme.colorScheme.onSurface.withValues(alpha: 0.7)
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            _buildPriorityIndicator(suggestion.priority),
                            const SizedBox(width: 8),
                            Text(
                              _formatCreatedAt(suggestion.createdAt),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 
                                  0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Actions
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!suggestion.isRead)
                        IconButton(
                          onPressed: () => onMarkAsRead?.call(suggestion),
                          icon: Icon(
                            Icons.check_circle_outline,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                            size: 20,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      IconButton(
                        onPressed: () => onSuggestionTap?.call(suggestion),
                        icon: Icon(
                          Icons.arrow_forward_ios,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          size: 16,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Content
              Text(
                suggestion.content,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: suggestion.isRead
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                      : theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityIndicator(int priority) {
    final color = _getPriorityColor(priority);
    final text = _getPriorityText(priority);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildViewAllButton(ThemeData theme) {
    return Center(
      child: TextButton.icon(
        onPressed: onViewAll,
        icon: Icon(
          Icons.visibility,
          size: 16,
          color: theme.colorScheme.primary,
        ),
        label: Text(
          'Xem tất cả gợi ý (${suggestions.length})',
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 5:
        return Colors.red;
      case 4:
        return Colors.orange;
      case 3:
        return Colors.blue;
      case 2:
        return Colors.green;
      case 1:
      default:
        return Colors.grey;
    }
  }

  String _getPriorityText(int priority) {
    switch (priority) {
      case 5:
        return 'RẤT QUAN TRỌNG';
      case 4:
        return 'QUAN TRỌNG';
      case 3:
        return 'TRUNG BÌNH';
      case 2:
        return 'THẤP';
      case 1:
      default:
        return 'THÔNG TIN';
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'expense_warning':
        return Icons.warning;
      case 'savings_improvement':
        return Icons.savings;
      case 'emergency_fund':
        return Icons.security;
      case 'income_stability':
        return Icons.trending_up;
      case 'budget_control':
        return Icons.account_balance_wallet;
      case 'debt_management':
        return Icons.credit_card;
      case 'income_growth':
        return Icons.show_chart;
      case 'income_diversification':
        return Icons.donut_large;
      case 'investment_start':
        return Icons.trending_up;
      case 'cash_optimization':
        return Icons.monetization_on;
      case 'lifestyle_optimization':
        return Icons.local_cafe;
      case 'subscription_cleanup':
        return Icons.subscriptions;
      case 'spending_pattern':
        return Icons.pattern;
      case 'category_optimization':
        return Icons.category;
      case 'tax_optimization':
        return Icons.receipt;
      case 'seasonal':
        return Icons.calendar_today;
      default:
        return Icons.lightbulb;
    }
  }

  String _formatCreatedAt(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }
}


