import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../providers/transaction_provider.dart';
import '../providers/income_source_provider.dart';
import '../providers/ai_provider.dart';
import '../providers/bill_provider.dart';
import '../models/ai_suggestion.dart';
import '../models/transaction.dart';
import '../theme.dart';
import '../utils/currency_formatter.dart';
import 'transactions_screen.dart';
import 'bills_screen.dart';
import 'goals_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _cardsController;
  late AnimationController _featuresController;
  late AnimationController _transactionsController;

  late Animation<double> _headerSlideAnimation;
  late Animation<double> _headerFadeAnimation;
  late Animation<double> _cardsScaleAnimation;
  late Animation<double> _featuresSlideAnimation;
  late Animation<double> _transactionsFadeAnimation;

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
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _cardsController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _featuresController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _transactionsController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _headerSlideAnimation = Tween<double>(
      begin: -30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutCubic,
    ));

    _headerFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeIn,
    ));

    _cardsScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardsController,
      curve: Curves.elasticOut,
    ));

    _featuresSlideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _featuresController,
      curve: Curves.easeOutCubic,
    ));

    _transactionsFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _transactionsController,
      curve: Curves.easeIn,
    ));

    // Start animations
    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _cardsController.forward();
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      _featuresController.forward();
    });
    Future.delayed(const Duration(milliseconds: 700), () {
      _transactionsController.forward();
    });
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      final isScrolled = _scrollController.offset > 20;
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
    _featuresController.dispose();
    _transactionsController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Consumer4<TransactionProvider, IncomeSourceProvider, AIProvider, BillProvider>(
      builder: (context, transactionProvider, incomeProvider, aiProvider, billProvider, child) {
        final now = DateTime.now();
        final monthlyStats = transactionProvider.getMonthlyStats(now);
        final monthlyIncome = incomeProvider.totalMonthlyIncome;
        final recentTransactions = transactionProvider.transactions.take(5).toList();
        final upcomingBills = billProvider.getUpcomingBills(7);

        return Scaffold(
          backgroundColor: AppTheme.vcbBackground,
          body: RefreshIndicator(
            onRefresh: () => _refreshData(
              transactionProvider,
              incomeProvider,
              aiProvider,
            ),
            color: AppTheme.vcbPrimaryGreen,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // VCB Style App Bar
                SliverAppBar(
                  expandedHeight: 280,
                  floating: false,
                  pinned: true,
                  elevation: 0,
                  backgroundColor: AppTheme.vcbPrimaryGreen,
                  flexibleSpace: FlexibleSpaceBar(
                    background: _buildVCBHeader(monthlyIncome, monthlyStats),
                  ),
                  title: AnimatedOpacity(
                    opacity: _isScrolled ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      'Tổng quan tài chính',
                      style: AppTheme.titleLarge.copyWith(
                        color: AppTheme.vcbWhite,
                      ),
                    ),
                  ),
                ),

                // Balance Cards
                SliverToBoxAdapter(
                  child: Transform.translate(
                    offset: const Offset(0, -30),
                    child: AnimatedBuilder(
                      animation: _cardsScaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _cardsScaleAnimation.value,
                          child: _buildBalanceCards(monthlyStats, monthlyIncome),
                        );
                      },
                    ),
                  ),
                ),

                // Quick Features
                SliverToBoxAdapter(
                  child: AnimatedBuilder(
                    animation: _featuresSlideAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _featuresSlideAnimation.value),
                        child: _buildQuickFeatures(),
                      );
                    },
                  ),
                ),

                // AI Insights Section
                if (aiProvider.suggestions.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _buildAIInsights(aiProvider),
                  ),

                // Recent Transactions
                SliverToBoxAdapter(
                  child: AnimatedBuilder(
                    animation: _transactionsFadeAnimation,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _transactionsFadeAnimation,
                        child: _buildRecentTransactions(recentTransactions),
                      );
                    },
                  ),
                ),

                // Upcoming Bills
                if (upcomingBills.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _buildUpcomingBills(upcomingBills),
                  ),

                // Bottom spacing
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVCBHeader(double monthlyIncome, Map<String, dynamic> monthlyStats) {
    return AnimatedBuilder(
      animation: _headerController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _headerSlideAnimation.value),
          child: FadeTransition(
            opacity: _headerFadeAnimation,
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.vcbPrimaryGradient,
              ),
              child: Stack(
                children: [
                  // Background pattern
                  Positioned.fill(
                    child: CustomPaint(
                      painter: VCBPatternPainter(),
                    ),
                  ),
                  
                  // Content
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spaceLarge),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Greeting
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getGreeting(),
                                    style: AppTheme.bodyLarge.copyWith(
                                      color: AppTheme.vcbWhite.withOpacity(0.9),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Quản lý tài chính thông minh',
                                    style: AppTheme.headlineMedium.copyWith(
                                      color: AppTheme.vcbWhite,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppTheme.vcbWhite.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppTheme.vcbWhite.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.notifications_outlined,
                                  color: AppTheme.vcbWhite,
                                ),
                              ),
                            ],
                          ),
                          
                          const Spacer(),
                          
                          // Total balance
                          Text(
                            'Số dư hiện tại',
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.vcbWhite.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                CurrencyFormatter.format(
                                  monthlyIncome - monthlyStats['totalExpense'],
                                ),
                                style: AppTheme.displayMedium.copyWith(
                                  color: AppTheme.vcbWhite,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.vcbWhite.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        monthlyStats['trend'] > 0
                                            ? Icons.trending_up
                                            : Icons.trending_down,
                                        size: 16,
                                        color: AppTheme.vcbWhite,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${monthlyStats['trend'].abs()}%',
                                        style: AppTheme.labelSmall.copyWith(
                                          color: AppTheme.vcbWhite,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
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

  Widget _buildBalanceCards(Map<String, dynamic> monthlyStats, double monthlyIncome) {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMedium),
      child: Row(
        children: [
          Expanded(
            child: _buildBalanceCard(
              title: 'Thu nhập',
              amount: monthlyIncome,
              icon: Icons.arrow_downward,
              color: AppTheme.vcbSuccess,
              isIncome: true,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildBalanceCard(
              title: 'Chi tiêu',
              amount: monthlyStats['totalExpense'],
              icon: Icons.arrow_upward,
              color: AppTheme.vcbError,
              isIncome: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard({
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
    required bool isIncome,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMedium),
      decoration: BoxDecoration(
        color: AppTheme.vcbWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.vcbShadowMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: color,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.vcbTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.format(amount),
            style: AppTheme.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.vcbTextPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFeatures() {
    final features = [
      QuickFeature(
        icon: Icons.add_card,
        title: 'Nạp tiền',
        color: AppTheme.vcbPrimaryGreen,
        onTap: () {},
      ),
      QuickFeature(
        icon: Icons.send,
        title: 'Chuyển tiền',
        color: AppTheme.vcbBlue,
        onTap: () {},
      ),
      QuickFeature(
        icon: Icons.qr_code_scanner,
        title: 'QR Pay',
        color: AppTheme.vcbOrange,
        onTap: () {},
      ),
      QuickFeature(
        icon: Icons.receipt,
        title: 'Hóa đơn',
        color: AppTheme.vcbGold,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BillsScreen()),
        ),
      ),
    ];

    return Container(
      margin: const EdgeInsets.all(AppTheme.spaceMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tính năng nhanh',
            style: AppTheme.headlineSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1.0,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: features.length,
            itemBuilder: (context, index) {
              final feature = features[index];
              return _buildFeatureItem(feature);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(QuickFeature feature) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        feature.onTap();
      },
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.vcbWhite,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          boxShadow: AppTheme.vcbShadowSmall,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: feature.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                feature.icon,
                color: feature.color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              feature.title,
              style: AppTheme.labelSmall.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIInsights(AIProvider aiProvider) {
    return Container(
      margin: const EdgeInsets.all(AppTheme.spaceMedium),
      padding: const EdgeInsets.all(AppTheme.spaceMedium),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.vcbBlue.withOpacity(0.1),
            AppTheme.vcbLightBlue.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: AppTheme.vcbBlue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.vcbBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: AppTheme.vcbBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'AI Insights',
                style: AppTheme.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                'Xem tất cả',
                style: AppTheme.labelMedium.copyWith(
                  color: AppTheme.vcbBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            aiProvider.suggestions.first.title,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.vcbTextPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(List<Transaction> transactions) {
    return Container(
      margin: const EdgeInsets.all(AppTheme.spaceMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Giao dịch gần đây',
                style: AppTheme.headlineSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TransactionsScreen()),
                ),
                child: Text(
                  'Xem tất cả',
                  style: AppTheme.labelMedium.copyWith(
                    color: AppTheme.vcbPrimaryGreen,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (transactions.isEmpty)
            Container(
              padding: const EdgeInsets.all(AppTheme.spaceLarge),
              decoration: BoxDecoration(
                color: AppTheme.vcbGrey100,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 48,
                      color: AppTheme.vcbGrey400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Chưa có giao dịch nào',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.vcbTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: AppTheme.vcbWhite,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                boxShadow: AppTheme.vcbShadowSmall,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.length,
                separatorBuilder: (context, index) => const Divider(
                  height: 1,
                  indent: 68,
                ),
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  return _buildTransactionItem(transaction);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final isExpense = transaction.type == TransactionType.expense;
    final color = isExpense ? AppTheme.vcbError : AppTheme.vcbSuccess;
    
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceMedium,
        vertical: AppTheme.spaceSmall,
      ),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          _getCategoryIcon(transaction.category),
          color: color,
          size: 24,
        ),
      ),
      title: Text(
        transaction.description,
        style: AppTheme.bodyMedium.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        '${transaction.category} • ${_formatDate(transaction.date)}',
        style: AppTheme.bodySmall.copyWith(
          color: AppTheme.vcbTextSecondary,
        ),
      ),
      trailing: Text(
        '${isExpense ? '-' : '+'} ${CurrencyFormatter.format(transaction.amount)}',
        style: AppTheme.titleMedium.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildUpcomingBills(List bills) {
    return Container(
      margin: const EdgeInsets.all(AppTheme.spaceMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hóa đơn sắp tới',
                style: AppTheme.headlineSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.vcbWarning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${bills.length} hóa đơn',
                  style: AppTheme.labelSmall.copyWith(
                    color: AppTheme.vcbWarning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(AppTheme.spaceMedium),
            decoration: BoxDecoration(
              color: AppTheme.vcbWarning.withOpacity(0.05),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(
                color: AppTheme.vcbWarning.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: AppTheme.vcbWarning,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bạn có ${bills.length} hóa đơn cần thanh toán',
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Trong 7 ngày tới',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.vcbTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BillsScreen()),
                  ),
                  child: const Text('Xem'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Chào buổi sáng!';
    } else if (hour < 18) {
      return 'Chào buổi chiều!';
    } else {
      return 'Chào buổi tối!';
    }
  }

  IconData _getCategoryIcon(String category) {
    final iconMap = {
      'Ăn uống': Icons.restaurant,
      'Di chuyển': Icons.directions_car,
      'Mua sắm': Icons.shopping_bag,
      'Giải trí': Icons.movie,
      'Sức khỏe': Icons.local_hospital,
      'Giáo dục': Icons.school,
      'Tiền nhà': Icons.home,
      'Tiện ích': Icons.bolt,
      'Lương': Icons.account_balance_wallet,
      'Thưởng': Icons.card_giftcard,
      'Đầu tư': Icons.trending_up,
      'Khác': Icons.more_horiz,
    };
    return iconMap[category] ?? Icons.category;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Hôm nay';
    } else if (difference.inDays == 1) {
      return 'Hôm qua';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Future<void> _refreshData(
    TransactionProvider transactionProvider,
    IncomeSourceProvider incomeProvider,
    AIProvider aiProvider,
  ) async {
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(seconds: 1));
    
    // Reload animations
    _headerController.forward(from: 0);
    _cardsController.forward(from: 0);
    _featuresController.forward(from: 0);
    _transactionsController.forward(from: 0);
  }
}

class QuickFeature {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  QuickFeature({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });
}

// VCB Pattern Painter for header background
class VCBPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.vcbWhite.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    // Draw circles pattern
    for (int i = 0; i < 5; i++) {
      final offset = Offset(
        size.width * (0.1 + i * 0.2),
        size.height * 0.3 + math.sin(i * 0.5) * 20,
      );
      canvas.drawCircle(offset, 60 + i * 10, paint);
    }

    // Draw wave pattern
    final path = Path();
    path.moveTo(0, size.height * 0.8);
    
    for (double x = 0; x <= size.width; x++) {
      final y = size.height * 0.8 + 
          math.sin((x / size.width * 3 * math.pi)) * 20;
      path.lineTo(x, y);
    }
    
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(VCBPatternPainter oldDelegate) => false;
}
