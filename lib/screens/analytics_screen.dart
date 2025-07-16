import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import '../theme.dart';
import '../providers/transaction_provider.dart';
import '../providers/income_source_provider.dart';
import '../utils/currency_formatter.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _chartsController;
  late AnimationController _statsController;

  late Animation<double> _headerSlideAnimation;
  late Animation<double> _headerFadeAnimation;
  late Animation<double> _chartsScaleAnimation;
  late Animation<double> _chartsFadeAnimation;

  int _selectedTimeRange = 0; // 0: Tuần, 1: Tháng, 2: Năm
  final List<String> _timeRanges = ['7 ngày', '30 ngày', '12 tháng'];

  int _selectedChartType = 0; // 0: Thu chi, 1: Danh mục, 2: Xu hướng
  final List<String> _chartTypes = ['Thu chi', 'Danh mục', 'Xu hướng'];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _headerController = AnimationController(
      duration: AppTheme.slowDuration,
      vsync: this,
    );

    _chartsController = AnimationController(
      duration: AppTheme.extraSlowDuration,
      vsync: this,
    );

    _statsController = AnimationController(
      duration: AppTheme.slowDuration,
      vsync: this,
    );

    _headerSlideAnimation = Tween<double>(begin: -30.0, end: 0.0).animate(
      CurvedAnimation(parent: _headerController, curve: AppTheme.smoothCurve),
    );

    _headerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: AppTheme.smoothCurve),
    );

    _chartsScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _chartsController, curve: AppTheme.bounceInCurve),
    );

    _chartsFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _chartsController, curve: AppTheme.smoothCurve),
    );

    // Start animations
    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _chartsController.forward();
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      _statsController.forward();
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _chartsController.dispose();
    _statsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<TransactionProvider, IncomeSourceProvider>(
      builder: (context, transactionProvider, incomeProvider, child) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          body: Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.backgroundGradient,
            ),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Beautiful Header với gradient
                _buildSliverAppBar(),

                // Main Content
                SliverPadding(
                  padding: EdgeInsets.all(AppTheme.spacing4),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Time Range Selector
                      _buildTimeRangeSelector(),

                      SizedBox(height: AppTheme.spacing6),

                      // Overview Stats Cards
                      _buildOverviewStats(transactionProvider, incomeProvider),

                      SizedBox(height: AppTheme.spacing6),

                      // Chart Type Selector
                      _buildChartTypeSelector(),

                      SizedBox(height: AppTheme.spacing4),

                      // Main Chart
                      _buildMainChart(transactionProvider),

                      SizedBox(height: AppTheme.spacing6),

                      // Category Breakdown
                      _buildCategoryBreakdown(transactionProvider),

                      SizedBox(height: AppTheme.spacing6),

                      // Insights Cards
                      _buildInsightsSection(transactionProvider),

                      // Bottom padding
                      SizedBox(height: AppTheme.spacing20),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
          child: Stack(
            children: [
              // Background Pattern
              Positioned.fill(
                child: CustomPaint(painter: AnalyticsPatternPainter()),
              ),

              // Content
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(AppTheme.spacing6),
                  child: AnimatedBuilder(
                    animation: _headerController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _headerSlideAnimation.value),
                        child: Opacity(
                          opacity: _headerFadeAnimation.value,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(AppTheme.spacing3),
                                    decoration: AppTheme.glassMorphism(
                                      color: AppTheme.white.withValues(alpha: 0.9),
                                      borderRadius: AppTheme.radiusLG,
                                    ),
                                    child: const Icon(
                                      Icons.analytics_rounded,
                                      color: AppTheme.white,
                                      size: AppTheme.iconXL,
                                    ),
                                  ),
                                  SizedBox(width: AppTheme.spacing4),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Phân tích tài chính',
                                          style: AppTheme.displaySmall.copyWith(
                                            color: AppTheme.white,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        Text(
                                          'Insights thông minh cho tài chính',
                                          style: AppTheme.bodyLarge.copyWith(
                                            color: AppTheme.white.withValues(alpha: 
                                              0.9,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacing1),
      decoration: AppTheme.glassMorphism(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
      ),
      child: Row(
        children: _timeRanges.asMap().entries.map((entry) {
          final index = entry.key;
          final range = entry.value;
          final isSelected = index == _selectedTimeRange;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTimeRange = index;
                });
              },
              child: AnimatedContainer(
                duration: AppTheme.normalDuration,
                margin: EdgeInsets.all(AppTheme.spacing1),
                padding: EdgeInsets.symmetric(
                  vertical: AppTheme.spacing3,
                  horizontal: AppTheme.spacing4,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppTheme.primaryGradient : null,
                  color: isSelected ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                  boxShadow: isSelected ? AppTheme.lightShadow : null,
                ),
                child: Text(
                  range,
                  textAlign: TextAlign.center,
                  style: AppTheme.titleSmall.copyWith(
                    color: isSelected
                        ? AppTheme.white
                        : Theme.of(context).textTheme.bodyMedium?.color,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOverviewStats(
    TransactionProvider transactionProvider,
    IncomeSourceProvider incomeProvider,
  ) {
    final monthlyStats = transactionProvider.getMonthlyStats(DateTime.now());
    final totalIncome = incomeProvider.totalMonthlyIncome;
    final totalExpenses = monthlyStats['totalExpenses'] ?? 0.0;
    final balance = totalIncome - totalExpenses;
    final savingsRate = monthlyStats['savingsRate'] ?? 0.0;

    return AnimatedBuilder(
      animation: _statsController,
      builder: (context, child) {
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: AppTheme.spacing4,
          mainAxisSpacing: AppTheme.spacing4,
          childAspectRatio: 1.3,
          children: [
            _buildStatCard(
              'Thu nhập',
              CurrencyFormatter.formatVNDShort(totalIncome),
              Icons.trending_up_rounded,
              AppTheme.successGradient,
              '+${((totalIncome / 10000000) * 100).toStringAsFixed(1)}%',
            ),
            _buildStatCard(
              'Chi tiêu',
              CurrencyFormatter.formatVNDShort(totalExpenses),
              Icons.trending_down_rounded,
              AppTheme.errorGradient,
              '-${((totalExpenses / 8000000) * 100).toStringAsFixed(1)}%',
            ),
            _buildStatCard(
              'Số dư',
              CurrencyFormatter.formatVNDShort(balance),
              Icons.account_balance_wallet_rounded,
              AppTheme.accentGradient,
              balance > 0
                  ? '+${((balance / totalIncome) * 100).toStringAsFixed(1)}%'
                  : '0%',
            ),
            _buildStatCard(
              'Tiết kiệm',
              '${savingsRate.toStringAsFixed(1)}%',
              Icons.savings_rounded,
              AppTheme.warningGradient,
              savingsRate > 20 ? 'Tốt' : 'Cần cải thiện',
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    LinearGradient gradient,
    String change,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        boxShadow: AppTheme.lightShadow,
      ),
      child: Padding(
        padding: EdgeInsets.all(AppTheme.spacing4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppTheme.spacing2),
                  decoration: BoxDecoration(
                    color: AppTheme.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                  ),
                  child: Icon(
                    icon,
                    color: AppTheme.white,
                    size: AppTheme.iconMD,
                  ),
                ),
                const Spacer(),
                Text(
                  change,
                  style: AppTheme.labelSmall.copyWith(
                    color: AppTheme.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: AppTheme.headlineLarge.copyWith(
                color: AppTheme.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              title,
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartTypeSelector() {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacing1),
      decoration: AppTheme.glassMorphism(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
      ),
      child: Row(
        children: _chartTypes.asMap().entries.map((entry) {
          final index = entry.key;
          final type = entry.value;
          final isSelected = index == _selectedChartType;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedChartType = index;
                });
              },
              child: AnimatedContainer(
                duration: AppTheme.normalDuration,
                margin: EdgeInsets.all(AppTheme.spacing1),
                padding: EdgeInsets.symmetric(
                  vertical: AppTheme.spacing3,
                  horizontal: AppTheme.spacing4,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppTheme.secondaryGradient : null,
                  color: isSelected ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                  boxShadow: isSelected ? AppTheme.lightShadow : null,
                ),
                child: Text(
                  type,
                  textAlign: TextAlign.center,
                  style: AppTheme.titleSmall.copyWith(
                    color: isSelected
                        ? AppTheme.white
                        : Theme.of(context).textTheme.bodyMedium?.color,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMainChart(TransactionProvider transactionProvider) {
    return AnimatedBuilder(
      animation: _chartsController,
      builder: (context, child) {
        return Transform.scale(
          scale: _chartsScaleAnimation.value,
          child: Opacity(
            opacity: _chartsFadeAnimation.value,
            child: Container(
              height: 300,
              padding: EdgeInsets.all(AppTheme.spacing6),
              decoration: AppTheme.glassMorphism(
                color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getChartTitle(),
                    style: AppTheme.headlineSmall.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: AppTheme.spacing4),
                  Expanded(child: _buildChart(transactionProvider)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildChart(TransactionProvider transactionProvider) {
    switch (_selectedChartType) {
      case 0:
        return _buildIncomeExpenseChart(transactionProvider);
      case 1:
        return _buildCategoryPieChart(transactionProvider);
      case 2:
        return _buildTrendChart(transactionProvider);
      default:
        return _buildIncomeExpenseChart(transactionProvider);
    }
  }

  Widget _buildIncomeExpenseChart(TransactionProvider transactionProvider) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 20000000,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => AppTheme.gray800,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                CurrencyFormatter.formatVNDShort(rod.toY),
                AppTheme.bodySmall.copyWith(
                  color: AppTheme.white,
                  fontWeight: FontWeight.w600,
                ),
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
              getTitlesWidget: (value, meta) {
                const style = TextStyle(
                  color: AppTheme.gray600,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                );
                final days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
                return Text(days[value.toInt()], style: style);
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              getTitlesWidget: (value, meta) {
                return Text(
                  CurrencyFormatter.formatVNDShort(value),
                  style: const TextStyle(
                    color: AppTheme.gray600,
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 5000000,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: AppTheme.gray200, strokeWidth: 1);
          },
        ),
        barGroups: _generateBarData(),
      ),
    );
  }

  List<BarChartGroupData> _generateBarData() {
    final random = Random(42); // Fixed seed for consistent data
    return List.generate(7, (index) {
      final income = random.nextDouble() * 15000000 + 5000000;
      final expense = random.nextDouble() * 12000000 + 3000000;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: income,
            gradient: AppTheme.successGradient,
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
          BarChartRodData(
            toY: expense,
            gradient: AppTheme.errorGradient,
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    });
  }

  Widget _buildCategoryPieChart(TransactionProvider transactionProvider) {
    return PieChart(
      PieChartData(
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            setState(() {
              // Handle touch
            });
          },
        ),
        borderData: FlBorderData(show: false),
        sectionsSpace: 4,
        centerSpaceRadius: 60,
        sections: _generatePieData(),
      ),
    );
  }

  List<PieChartSectionData> _generatePieData() {
    final categories = [
      {'name': 'Ăn uống', 'value': 35.0, 'color': AppTheme.errorStart},
      {'name': 'Di chuyển', 'value': 25.0, 'color': AppTheme.warningStart},
      {'name': 'Mua sắm', 'value': 20.0, 'color': AppTheme.accentStart},
      {'name': 'Giải trí', 'value': 15.0, 'color': AppTheme.primaryColor},
      {'name': 'Khác', 'value': 5.0, 'color': AppTheme.gray500},
    ];

    return categories.map((category) {
      return PieChartSectionData(
        color: category['color'] as Color,
        value: category['value'] as double,
        title: '${category['value']}%',
        radius: 80,
        titleStyle: AppTheme.labelMedium.copyWith(
          color: AppTheme.white,
          fontWeight: FontWeight.w600,
        ),
        badgeWidget: Container(
          padding: EdgeInsets.all(AppTheme.spacing1),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            boxShadow: AppTheme.lightShadow,
          ),
          child: Text(
            category['name'] as String,
            style: AppTheme.labelSmall.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        badgePositionPercentageOffset: 1.3,
      );
    }).toList();
  }

  Widget _buildTrendChart(TransactionProvider transactionProvider) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 2000000,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: AppTheme.gray200, strokeWidth: 1);
          },
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
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                const months = ['T1', 'T2', 'T3', 'T4', 'T5', 'T6'];
                return Text(
                  months[value.toInt() % months.length],
                  style: const TextStyle(
                    color: AppTheme.gray600,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 2000000,
              reservedSize: 60,
              getTitlesWidget: (value, meta) {
                return Text(
                  CurrencyFormatter.formatVNDShort(value),
                  style: const TextStyle(
                    color: AppTheme.gray600,
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 5,
        minY: 0,
        maxY: 12000000,
        lineBarsData: [
          LineChartBarData(
            spots: _generateTrendData(),
            isCurved: true,
            gradient: AppTheme.primaryGradient,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 6,
                  color: AppTheme.white,
                  strokeWidth: 3,
                  strokeColor: AppTheme.primaryColor,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.primaryColor.withValues(alpha: 0.9),
                  AppTheme.primaryColor.withValues(alpha: 0.9),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _generateTrendData() {
    final random = Random(42);
    return List.generate(6, (index) {
      final value = random.nextDouble() * 8000000 + 2000000;
      return FlSpot(index.toDouble(), value);
    });
  }

  Widget _buildCategoryBreakdown(TransactionProvider transactionProvider) {
    final categories = [
      {
        'name': 'Ăn uống',
        'amount': 8500000.0,
        'color': AppTheme.errorStart,
        'icon': Icons.restaurant_rounded,
      },
      {
        'name': 'Di chuyển',
        'amount': 3200000.0,
        'color': AppTheme.warningStart,
        'icon': Icons.directions_car_rounded,
      },
      {
        'name': 'Mua sắm',
        'amount': 5600000.0,
        'color': AppTheme.accentStart,
        'icon': Icons.shopping_bag_rounded,
      },
      {
        'name': 'Giải trí',
        'amount': 2100000.0,
        'color': AppTheme.primaryColor,
        'icon': Icons.movie_rounded,
      },
    ];

    return Container(
      padding: EdgeInsets.all(AppTheme.spacing6),
      decoration: AppTheme.glassMorphism(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💰 Chi tiêu theo danh mục',
            style: AppTheme.headlineSmall.copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: AppTheme.spacing4),
          ...categories
              .map((category) => _buildCategoryItem(category))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(Map<String, dynamic> category) {
    final percentage = (category['amount'] as double) / 20000000 * 100;

    return Container(
      margin: EdgeInsets.only(bottom: AppTheme.spacing3),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppTheme.spacing2),
                decoration: BoxDecoration(
                  color: (category['color'] as Color).withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                ),
                child: Icon(
                  category['icon'] as IconData,
                  color: category['color'] as Color,
                  size: AppTheme.iconMD,
                ),
              ),
              SizedBox(width: AppTheme.spacing3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category['name'] as String,
                      style: AppTheme.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.formatVNDShort(
                        category['amount'] as double,
                      ),
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.gray600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: AppTheme.titleSmall.copyWith(
                  color: category['color'] as Color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacing2),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: AppTheme.gray200,
            color: category['color'] as Color,
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsSection(TransactionProvider transactionProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🧠 Insights thông minh',
          style: AppTheme.headlineSmall.copyWith(fontWeight: FontWeight.w700),
        ),
        SizedBox(height: AppTheme.spacing4),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 1,
          crossAxisSpacing: AppTheme.spacing4,
          mainAxisSpacing: AppTheme.spacing4,
          childAspectRatio: 3.5,
          children: [
            _buildInsightCard(
              'Chi tiêu ăn uống cao',
              'Bạn chi 35% cho ăn uống, cao hơn khuyến nghị 25%',
              Icons.restaurant_rounded,
              AppTheme.warningStart,
              'Giảm 500k/tháng',
            ),
            _buildInsightCard(
              'Tiết kiệm tốt',
              'Tỷ lệ tiết kiệm 25% rất tốt, cao hơn mức trung bình',
              Icons.savings_rounded,
              AppTheme.successStart,
              'Duy trì',
            ),
            _buildInsightCard(
              'Thu nhập ổn định',
              'Thu nhập đều đặn mỗi tháng, xu hướng tăng nhẹ',
              Icons.trending_up_rounded,
              AppTheme.accentStart,
              'Tuyệt vời',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInsightCard(
    String title,
    String description,
    IconData icon,
    Color color,
    String action,
  ) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacing4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        border: Border.all(color: color.withValues(alpha: 0.9), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppTheme.spacing3),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            ),
            child: Icon(icon, color: AppTheme.white, size: AppTheme.iconLG),
          ),
          SizedBox(width: AppTheme.spacing4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: AppTheme.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                Text(
                  description,
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.gray600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.spacing3,
              vertical: AppTheme.spacing1,
            ),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            ),
            child: Text(
              action,
              style: AppTheme.labelSmall.copyWith(
                color: AppTheme.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getChartTitle() {
    switch (_selectedChartType) {
      case 0:
        return '📊 Thu nhập vs Chi tiêu';
      case 1:
        return '🥧 Phân bố theo danh mục';
      case 2:
        return '📈 Xu hướng theo thời gian';
      default:
        return '📊 Biểu đồ tài chính';
    }
  }
}

// Custom painter for analytics background pattern
class AnalyticsPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw grid pattern
    const spacing = 30.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw some chart-like elements
    final chartPaint = Paint()
      ..color = AppTheme.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;

    final random = Random(42);
    for (int i = 0; i < 8; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 20 + 5;

      canvas.drawCircle(Offset(x, y), radius, chartPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

