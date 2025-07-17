import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../providers/transaction_provider.dart';
import '../providers/income_source_provider.dart';
import '../providers/ai_provider.dart';
import '../models/ai_suggestion.dart';
import '../models/transaction.dart';
import '../theme.dart';
import '../utils/currency_formatter.dart';
import '../utils/responsive_helper.dart';
import '../utils/text_contrast_helper.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _cardsController;
  late AnimationController _listController;

  late Animation<double> _headerSlideAnimation;
  late Animation<double> _headerFadeAnimation;
  late Animation<double> _cardsSlideAnimation;
  late Animation<double> _cardsFadeAnimation;

  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupScrollListener();
  }

  void _setupAnimations() {
    _headerController = AnimationController(
      duration: AppTheme.slowDuration,
      vsync: this,
    );

    _cardsController = AnimationController(
      duration: AppTheme.slowDuration,
      vsync: this,
    );

    _listController = AnimationController(
      duration: AppTheme.extraSlowDuration,
      vsync: this,
    );

    _headerSlideAnimation = Tween<double>(begin: -50.0, end: 0.0).animate(
      CurvedAnimation(parent: _headerController, curve: AppTheme.smoothCurve),
    );

    _headerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: AppTheme.smoothCurve),
    );

    _cardsSlideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _cardsController, curve: AppTheme.quickCurve),
    );

    _cardsFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardsController, curve: AppTheme.smoothCurve),
    );

    // Start animations
    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _cardsController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _listController.forward();
    });
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      final isScrolled = _scrollController.offset > 50;
      if (isScrolled != _isScrolled) {
        setState(() {
          _isScrolled = isScrolled;
        });
      }
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _cardsController.dispose();
    _listController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<TransactionProvider, IncomeSourceProvider, AIProvider>(
      builder:
          (context, transactionProvider, incomeProvider, aiProvider, child) {
            final now = DateTime.now();
            final monthlyStats = transactionProvider.getMonthlyStats(now);
            final monthlyIncome = incomeProvider.totalMonthlyIncome;
            final recentTransactions = transactionProvider.transactions
                .take(5)
                .toList();
            final suggestions = aiProvider.unreadSuggestions.take(3).toList();

            return Scaffold(
              extendBodyBehindAppBar: true,
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(0),
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
              ),
              body: SafeArea(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: AppTheme.backgroundGradient,
                  ),
                  child: RefreshIndicator(
                    onRefresh: () => _refreshData(
                      transactionProvider,
                      incomeProvider,
                      aiProvider,
                    ),
                    color: AppTheme.primaryColor,
                    child: CustomScrollView(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        // Beautiful Header with responsive design
                        SliverToBoxAdapter(
                          child: _buildHeader(monthlyIncome, monthlyStats),
                        ),

                        // Main Content
                        SliverPadding(
                          padding: EdgeInsets.all(AppTheme.spacing4),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              // Quick Stats Cards
                              _buildQuickStatsSection(
                                monthlyStats,
                                monthlyIncome,
                              ),

                              SizedBox(height: AppTheme.spacing6),

                              // AI Suggestions
                              if (suggestions.isNotEmpty) ...[
                                _buildSectionHeader('🤖 Gợi ý thông minh'),
                                SizedBox(height: AppTheme.spacing4),
                                _buildAISuggestionsSection(suggestions),
                                SizedBox(height: AppTheme.spacing6),
                              ] else ...[
                                _buildSectionHeader('🤖 Gợi ý thông minh'),
                                SizedBox(height: AppTheme.spacing4),
                                Center(
                                  child: Text(
                                    'Chưa có gợi ý nào',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                                SizedBox(height: AppTheme.spacing6),
                              ],

                              // Recent Transactions
                              _buildSectionHeader('💳 Giao dịch gần đây'),
                              SizedBox(height: AppTheme.spacing4),
                              recentTransactions.isNotEmpty
                                  ? _buildRecentTransactionsSection(
                                      recentTransactions,
                                    )
                                  : Center(
                                      child: Text(
                                        'Chưa có giao dịch nào',
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                    ),

                              SizedBox(height: AppTheme.spacing8),

                              // Quick Actions
                              _buildSectionHeader('⚡ Thao tác nhanh'),
                              SizedBox(height: AppTheme.spacing4),
                              _buildQuickActionsSection(),

                              // Bottom padding for FAB
                              SizedBox(height: AppTheme.spacing20),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
    );
  }

  Widget _buildHeader(double monthlyIncome, Map<String, dynamic> monthlyStats) {
    final totalExpenses = monthlyStats['totalExpenses'] ?? 0.0;
    final balance = monthlyIncome - totalExpenses;

    return AnimatedBuilder(
      animation: _headerController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _headerSlideAnimation.value),
          child: Opacity(
            opacity: _headerFadeAnimation.value,
            child: Container(
              height: ResponsiveHelper.isTablet(context)
                  ? 320
                  : ResponsiveHelper.isSmallPhone(context)
                  ? 240
                  : 280,
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
              ),
              child: Stack(
                children: [
                  // Background Pattern
                  Positioned.fill(
                    child: CustomPaint(painter: PatternPainter()),
                  ),

                  // Content with responsive padding
                  SafeArea(
                    child: Padding(
                      padding: ResponsiveHelper.responsivePadding(
                        context,
                        mobile: 20.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Greeting & Date with responsive text
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _getGreeting(),
                                      style: TextContrastHelper.getPrimaryGradientTextStyle(
                                        AppTheme.headlineLarge.copyWith(
                                          fontSize:
                                              ResponsiveHelper.responsiveFontSize(
                                                context,
                                                mobile: 28.0,
                                                tablet: 32.0,
                                                desktop: 36.0,
                                              ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height:
                                          ResponsiveHelper.responsiveSpacing(
                                            context,
                                            small: 8.0,
                                          ),
                                    ),
                                    Text(
                                      _getCurrentDateString(),
                                      style: TextContrastHelper.getPrimaryGradientTextStyle(
                                        AppTheme.bodyLarge.copyWith(
                                          fontSize:
                                              ResponsiveHelper.responsiveFontSize(
                                                context,
                                                mobile: 16.0,
                                                tablet: 18.0,
                                                desktop: 20.0,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(
                                  ResponsiveHelper.responsiveSpacing(
                                    context,
                                    small: 12.0,
                                  ),
                                ),
                                decoration: AppTheme.glassMorphism(
                                  color: AppTheme.white.withValues(alpha: 0.2),
                                  borderRadius: AppTheme.radiusFull,
                                ),
                                child: Icon(
                                  Icons.notifications_outlined,
                                  color: AppTheme.white,
                                  size: ResponsiveHelper.isTablet(context)
                                      ? 28
                                      : ResponsiveHelper.isSmallPhone(context)
                                      ? 20
                                      : 24,
                                ),
                              ),
                            ],
                          ),

                          const Spacer(),

                          // Balance Display with responsive sizing
                          Container(
                            width: double.infinity,
                            padding: ResponsiveHelper.responsivePadding(
                              context,
                              mobile: 20.0,
                            ),
                            decoration: AppTheme.glassMorphism(
                              color: AppTheme.white.withValues(alpha: 0.15),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Số dư hiện tại',
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: AppTheme.white.withValues(
                                      alpha: 0.9,
                                    ),
                                  ),
                                ),
                                SizedBox(height: AppTheme.spacing2),
                                Text(
                                  CurrencyFormatter.formatVND(balance),
                                  style: AppTheme.displayMedium.copyWith(
                                    color: AppTheme.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(height: AppTheme.spacing4),
                                Row(
                                  children: [
                                    _buildBalanceItem(
                                      'Thu nhập',
                                      monthlyIncome,
                                      Icons.trending_up_rounded,
                                      AppTheme.successStart,
                                    ),
                                    SizedBox(width: AppTheme.spacing6),
                                    _buildBalanceItem(
                                      'Chi tiêu',
                                      totalExpenses,
                                      Icons.trending_down_rounded,
                                      AppTheme.errorStart,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBalanceItem(
    String label,
    double amount,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(AppTheme.spacing3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: AppTheme.iconMD),
            SizedBox(width: AppTheme.spacing2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTheme.labelSmall.copyWith(
                      color: AppTheme.white.withValues(alpha: 0.8),
                    ),
                  ),
                  Text(
                    CurrencyFormatter.formatVND(amount),
                    style: AppTheme.titleMedium.copyWith(
                      color: AppTheme.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatsSection(
    Map<String, dynamic> monthlyStats,
    double monthlyIncome,
  ) {
    final totalExpenses = monthlyStats['totalExpenses'] ?? 0.0;
    final savingsRate = monthlyStats['savingsRate'] ?? 0.0;
    final transactionCount = monthlyStats['transactionCount'] ?? 0;

    return AnimatedBuilder(
      animation: _cardsController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _cardsSlideAnimation.value),
          child: Opacity(
            opacity: _cardsFadeAnimation.value,
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: AppTheme.spacing4,
              mainAxisSpacing: AppTheme.spacing4,
              childAspectRatio: 1.2,
              children: [
                _buildStatCard(
                  'Tiết kiệm',
                  '${savingsRate.toStringAsFixed(1)}%',
                  Icons.savings_rounded,
                  AppTheme.successGradient,
                ),
                _buildStatCard(
                  'Giao dịch',
                  '$transactionCount',
                  Icons.receipt_long_rounded,
                  AppTheme.accentGradient,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    LinearGradient gradient,
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(AppTheme.spacing3),
              decoration: BoxDecoration(
                color: AppTheme.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
              child: Icon(icon, color: AppTheme.white, size: AppTheme.iconXL),
            ),
            SizedBox(height: AppTheme.spacing3),
            Text(
              value,
              style: AppTheme.headlineLarge.copyWith(
                color: AppTheme.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              title,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: AppTheme.headlineSmall.copyWith(fontWeight: FontWeight.w700),
        ),
        const Spacer(),
        TextButton(
          onPressed: () {
            // TODO: Navigate to full section
          },
          child: Text(
            'Xem tất cả',
            style: AppTheme.labelMedium.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAISuggestionsSection(List<AISuggestion> suggestions) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return Container(
            width: 280,
            margin: EdgeInsets.only(right: AppTheme.spacing4),
            padding: EdgeInsets.all(AppTheme.spacing4),
            decoration: AppTheme.glassMorphism(
              color: Theme.of(
                context,
              ).colorScheme.surface.withValues(alpha: 0.9),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppTheme.spacing2),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                      ),
                      child: Icon(
                        Icons.lightbulb_outline_rounded,
                        color: AppTheme.primaryColor,
                        size: AppTheme.iconMD,
                      ),
                    ),
                    SizedBox(width: AppTheme.spacing2),
                    Expanded(
                      child: Text(
                        suggestion.title,
                        style: AppTheme.titleMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppTheme.spacing2),
                Expanded(
                  child: Text(
                    suggestion.content,
                    style: AppTheme.bodySmall.copyWith(
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentTransactionsSection(List<Transaction> transactions) {
    if (transactions.isEmpty) {
      return Container(
        padding: EdgeInsets.all(AppTheme.spacing6),
        decoration: AppTheme.glassMorphism(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
        ),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: AppTheme.icon3XL,
              color: AppTheme.gray400,
            ),
            SizedBox(height: AppTheme.spacing4),
            Text(
              'Chưa có giao dịch nào',
              style: AppTheme.titleMedium.copyWith(color: AppTheme.gray600),
            ),
            SizedBox(height: AppTheme.spacing2),
            Text(
              'Thêm giao dịch đầu tiên của bạn',
              style: AppTheme.bodySmall.copyWith(color: AppTheme.gray500),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: AppTheme.glassMorphism(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: transactions.length,
        separatorBuilder: (context, index) =>
            Divider(height: 1, color: AppTheme.gray200),
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          return _buildTransactionTile(transaction);
        },
      ),
    );
  }

  Widget _buildTransactionTile(Transaction transaction) {
    final isIncome = transaction.type == 'income';

    return ListTile(
      contentPadding: EdgeInsets.all(AppTheme.spacing4),
      leading: Container(
        padding: EdgeInsets.all(AppTheme.spacing3),
        decoration: BoxDecoration(
          color: (isIncome ? AppTheme.successStart : AppTheme.errorStart)
              .withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        ),
        child: Icon(
          isIncome ? Icons.trending_up_rounded : Icons.trending_down_rounded,
          color: isIncome ? AppTheme.successStart : AppTheme.errorStart,
          size: AppTheme.iconLG,
        ),
      ),
      title: Text(
        transaction.description ?? 'Giao dịch',
        style: AppTheme.titleMedium.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        _formatTransactionDate(transaction.transactionDate),
        style: AppTheme.bodySmall.copyWith(color: AppTheme.gray500),
      ),
      trailing: Text(
        '${isIncome ? '+' : '-'}${CurrencyFormatter.formatVND(transaction.amount)}',
        style: AppTheme.titleMedium.copyWith(
          color: isIncome ? AppTheme.successStart : AppTheme.errorStart,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: AppTheme.spacing4,
      mainAxisSpacing: AppTheme.spacing4,
      childAspectRatio: 2.5,
      children: [
        _buildQuickActionCard(
          'Xem báo cáo',
          Icons.analytics_rounded,
          AppTheme.primaryGradient,
          () {
            // TODO: Navigate to analytics
          },
        ),
        _buildQuickActionCard(
          'Đặt ngân sách',
          Icons.account_balance_wallet_rounded,
          AppTheme.warningGradient,
          () {
            // TODO: Navigate to budgets
          },
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    LinearGradient gradient,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(
            ResponsiveHelper.responsiveBorderRadius(context, mobile: 16.0),
          ),
          boxShadow: AppTheme.lightShadow,
        ),
        child: Padding(
          padding: ResponsiveHelper.responsivePadding(context, mobile: 16.0),
          child: Row(
            children: [
              Icon(
                icon,
                color: TextContrastHelper.getGradientTextColor(gradient),
                size: ResponsiveHelper.responsiveIconSize(
                  context,
                  mobile: 24.0,
                ),
              ),
              SizedBox(
                width: ResponsiveHelper.responsiveSpacing(context, small: 12.0),
              ),
              Expanded(
                child: Text(
                  title,
                  style: TextContrastHelper.getGradientTextStyle(
                    AppTheme.titleMedium,
                    gradient,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refreshData(
    TransactionProvider transactionProvider,
    IncomeSourceProvider incomeProvider,
    AIProvider aiProvider,
  ) async {
    await Future.wait([
      transactionProvider.loadTransactions(),
      incomeProvider.loadIncomeSources(),
      aiProvider.loadSuggestions(),
    ]);
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Chào buổi sáng! 😊';
    if (hour < 17) return 'Chào buổi chiều! 😊';
    return 'Chào buổi tối! 😊';
  }

  String _getCurrentDateString() {
    final now = DateTime.now();
    const months = [
      'Tháng 1',
      'Tháng 2',
      'Tháng 3',
      'Tháng 4',
      'Tháng 5',
      'Tháng 6',
      'Tháng 7',
      'Tháng 8',
      'Tháng 9',
      'Tháng 10',
      'Tháng 11',
      'Tháng 12',
    ];
    return '${months[now.month - 1]}, ${now.year}';
  }

  String _formatTransactionDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) return 'Hôm nay';
    if (difference == 1) return 'Hôm qua';
    if (difference < 7) return '$difference ngày trước';

    return '${date.day}/${date.month}/${date.year}';
  }
}

// Custom painter for background pattern
class PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    // Draw scattered circles
    final random = math.Random(42); // Fixed seed for consistent pattern
    for (int i = 0; i < 20; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 30 + 10;

      canvas.drawCircle(
        Offset(x, y),
        radius,
        paint..color = AppTheme.white.withValues(alpha: 0.05),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
