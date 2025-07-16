import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme.dart';
import '../utils/currency_formatter.dart';
import 'app_button.dart';

class FinancialOverviewCard extends StatelessWidget {
  final double monthlyIncome;
  final double monthlyExpenses;
  final double savingsRate;
  final double savingsGoal;
  final VoidCallback? onAddTransaction;
  final VoidCallback? onViewAnalytics;
  final VoidCallback? onSetBudget;

  const FinancialOverviewCard({
    Key? key,
    required this.monthlyIncome,
    required this.monthlyExpenses,
    required this.savingsRate,
    this.savingsGoal = 0.2, // Default 20% savings goal
    this.onAddTransaction,
    this.onViewAnalytics,
    this.onSetBudget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final savings = monthlyIncome - monthlyExpenses;
    final actualSavingsRate = monthlyIncome > 0 ? savings / monthlyIncome : 0.0;
    final isMobile = AppTheme.isMobile(context);

    return Container(
      margin: EdgeInsets.all(AppTheme.spacing4),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
        boxShadow: AppTheme.mediumShadow,
      ),
      child: Padding(
        padding: EdgeInsets.all(AppTheme.spacing6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header với icon và title
            _buildHeader(context, actualSavingsRate),

            SizedBox(height: AppTheme.spacing6),

            // Financial summary với số tiền được định dạng
            _buildFinancialSummary(context, savings, actualSavingsRate),

            SizedBox(height: AppTheme.spacing6),

            // Quick Actions
            _buildQuickActions(context, isMobile),

            SizedBox(height: AppTheme.spacing6),

            // Modern bar chart
            _buildModernChart(context),

            SizedBox(height: AppTheme.spacing6),

            // Savings progress
            _buildSavingsProgress(context, actualSavingsRate),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double actualSavingsRate) {
    return Row(
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppTheme.spacing3),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: Icon(
                Icons.account_balance_wallet,
                color: AppTheme.primaryColor,
                size: AppTheme.iconLarge,
              ),
            ),
            SizedBox(width: AppTheme.spacing3),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tổng quan tài chính',
                  style: AppTheme.headlineSmall.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Tháng ${DateTime.now().month}/${DateTime.now().year}',
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.textMuted),
                ),
              ],
            ),
          ],
        ),
        const Spacer(),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppTheme.spacing3,
            vertical: AppTheme.spacing1,
          ),
          decoration: BoxDecoration(
            color: actualSavingsRate >= savingsGoal
                ? AppTheme.successColor.withValues(alpha: 0.1)
                : AppTheme.warningColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                actualSavingsRate >= savingsGoal
                    ? Icons.trending_up
                    : Icons.trending_down,
                color: actualSavingsRate >= savingsGoal
                    ? AppTheme.successColor
                    : AppTheme.warningColor,
                size: AppTheme.iconSmall,
              ),
              SizedBox(width: AppTheme.spacing1),
              Text(
                CurrencyFormatter.formatPercentage(actualSavingsRate),
                style: AppTheme.labelSmall.copyWith(
                  color: actualSavingsRate >= savingsGoal
                      ? AppTheme.successColor
                      : AppTheme.warningColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialSummary(
    BuildContext context,
    double savings,
    double actualSavingsRate,
  ) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacing5),
      decoration: BoxDecoration(
        color: AppTheme.primarySurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Thu nhập
          _buildSummaryRow(
            icon: Icons.arrow_downward,
            iconColor: AppTheme.incomeColor,
            label: 'Thu nhập',
            amount: monthlyIncome,
            isIncome: true,
          ),

          SizedBox(height: AppTheme.spacing4),

          // Chi tiêu
          _buildSummaryRow(
            icon: Icons.arrow_upward,
            iconColor: AppTheme.expenseColor,
            label: 'Chi tiêu',
            amount: monthlyExpenses,
            isIncome: false,
          ),

          SizedBox(height: AppTheme.spacing4),

          // Divider
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withValues(alpha: 0.1),
                  AppTheme.primaryColor.withValues(alpha: 0.3),
                  AppTheme.primaryColor.withValues(alpha: 0.1),
                ],
              ),
            ),
          ),

          SizedBox(height: AppTheme.spacing4),

          // Tiết kiệm
          _buildSummaryRow(
            icon: Icons.savings,
            iconColor: AppTheme.savingsColor,
            label: 'Tiết kiệm',
            amount: savings,
            isIncome: savings >= 0,
            isHighlight: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required double amount,
    required bool isIncome,
    bool isHighlight = false,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(AppTheme.spacing2),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
          child: Icon(icon, color: iconColor, size: AppTheme.iconMedium),
        ),

        SizedBox(width: AppTheme.spacing3),

        Expanded(
          child: Text(
            label,
            style:
                (isHighlight
                        ? AppTheme.titleMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          )
                        : AppTheme.bodyMedium)
                    .copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
          ),
        ),

        Text(
          CurrencyFormatter.formatVND(amount),
          style: isHighlight
              ? TextStyle(
                  fontSize: AppTheme.currencyMedium,
                  color: amount >= 0
                      ? AppTheme.primaryColor
                      : AppTheme.expenseColor,
                  fontWeight: FontWeight.w700,
                )
              : TextStyle(
                  fontSize: AppTheme.currencySmall,
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
        ),
      ],
    );
  }

  Widget _buildModernChart(BuildContext context) {
    return Container(
      height: 200,
      padding: EdgeInsets.all(AppTheme.spacing4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.softShadow,
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY:
              [monthlyIncome, monthlyExpenses].reduce((a, b) => a > b ? a : b) *
              1.2,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => AppTheme.primaryColor,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                String text;
                if (groupIndex == 0) {
                  text = 'Thu nhập\n${CurrencyFormatter.formatVND(rod.toY)}';
                } else {
                  text = 'Chi tiêu\n${CurrencyFormatter.formatVND(rod.toY)}';
                }
                return BarTooltipItem(
                  text,
                  AppTheme.bodySmall.copyWith(color: Colors.white),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  switch (value.toInt()) {
                    case 0:
                      return Text('Thu nhập', style: AppTheme.labelSmall);
                    case 1:
                      return Text('Chi tiêu', style: AppTheme.labelSmall);
                    default:
                      return const Text('');
                  }
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: monthlyIncome,
                  gradient: AppTheme.incomeGradient,
                  width: 32,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: monthlyExpenses,
                  gradient: AppTheme.expenseGradient,
                  width: 32,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingsProgress(BuildContext context, double actualSavingsRate) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacing5),
      decoration: BoxDecoration(
        color: AppTheme.savingsColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: AppTheme.savingsColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Mục tiêu tiết kiệm', style: AppTheme.titleMedium),
              Text(
                '${CurrencyFormatter.formatPercentage(actualSavingsRate)} / ${CurrencyFormatter.formatPercentage(savingsGoal)}',
                style: AppTheme.labelMedium.copyWith(
                  color: AppTheme.savingsColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.spacing3),

          LinearProgressIndicator(
            value: (actualSavingsRate / savingsGoal).clamp(0.0, 1.0),
            backgroundColor: AppTheme.savingsColor.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.savingsColor),
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            minHeight: 8,
          ),

          SizedBox(height: AppTheme.spacing2),

          Text(
            actualSavingsRate >= savingsGoal
                ? '🎉 Xuất sắc! Bạn đã đạt mục tiêu tiết kiệm!'
                : '💪 Tiếp tục cố gắng để đạt mục tiêu!',
            style: AppTheme.bodySmall.copyWith(
              color: actualSavingsRate >= savingsGoal
                  ? AppTheme.successColor
                  : AppTheme.textMuted,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isMobile) {
    if (isMobile) {
      // Mobile: Horizontal scroll actions
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hành động nhanh',
            style: AppTheme.titleMedium.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: AppTheme.spacing3),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  child: QuickActionButton(
                    icon: Icons.add_circle_outline,
                    label: 'Thêm giao dịch',
                    onPressed: onAddTransaction,
                    color: AppTheme.primaryColor,
                  ),
                ),
                SizedBox(width: AppTheme.spacing3),
                SizedBox(
                  width: 100,
                  child: QuickActionButton(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Đặt ngân sách',
                    onPressed: onSetBudget,
                    color: AppTheme.secondaryColor,
                  ),
                ),
                SizedBox(width: AppTheme.spacing3),
                SizedBox(
                  width: 100,
                  child: QuickActionButton(
                    icon: Icons.analytics_outlined,
                    label: 'Xem phân tích',
                    onPressed: onViewAnalytics,
                    color: AppTheme.savingsColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      // Desktop/Tablet: Grid layout
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hành động nhanh',
            style: AppTheme.titleMedium.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: AppTheme.spacing3),
          Row(
            children: [
              Expanded(
                child: QuickActionButton(
                  icon: Icons.add_circle_outline,
                  label: 'Thêm giao dịch',
                  onPressed: onAddTransaction,
                  color: AppTheme.primaryColor,
                  isVertical: false,
                ),
              ),
              SizedBox(width: AppTheme.spacing3),
              Expanded(
                child: QuickActionButton(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Đặt ngân sách',
                  onPressed: onSetBudget,
                  color: AppTheme.secondaryColor,
                  isVertical: false,
                ),
              ),
              SizedBox(width: AppTheme.spacing3),
              Expanded(
                child: QuickActionButton(
                  icon: Icons.analytics_outlined,
                  label: 'Xem phân tích',
                  onPressed: onViewAnalytics,
                  color: AppTheme.savingsColor,
                  isVertical: false,
                ),
              ),
            ],
          ),
        ],
      );
    }
  }
}


