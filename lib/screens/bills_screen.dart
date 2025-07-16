import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:provider/provider.dart';

import '../providers/bill_provider.dart';
import '../widgets/bill_form.dart';
import '../theme.dart';
import '../models/bill.dart';

class BillsScreen extends StatefulWidget {
  const BillsScreen({Key? key}) : super(key: key);

  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _headerAnimationController;
  late AnimationController _cardAnimationController;
  late AnimationController _fabAnimationController;
  late Animation<double> _headerAnimation;
  late Animation<double> _cardAnimation;
  late Animation<double> _fabAnimation;

  String _searchQuery = '';
  bool _isSearchExpanded = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _headerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _cardAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _cardAnimationController,
        curve: Curves.easeOutBack,
      ),
    );

    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    // Load bills data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BillProvider>().loadBills();
      _startAnimations();
    });
  }

  void _startAnimations() {
    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _cardAnimationController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      _fabAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _headerAnimationController.dispose();
    _cardAnimationController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.secondaryGradient.colors.first,
              AppTheme.secondaryGradient.colors.last,
              AppTheme.gray100,
            ],
            stops: const [0.0, 0.7, 1.0],
          ),
        ),
        child: CustomPaint(
          painter: _BillPatternPainter(),
          child: SafeArea(
            child: Column(
              children: [
                _buildAnimatedHeader(),
                _buildSearchSection(),
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAllBills(),
                      _buildUpcomingBills(),
                      _buildOverdueBills(),
                      _buildStatistics(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _fabAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _fabAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                gradient: AppTheme.secondaryGradient,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.secondaryGradient.colors.first.withValues(
                      alpha: 0.3,
                    ),
                    blurRadius: 20,
                    spreadRadius: 4,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed: _showAddBillDialog,
                backgroundColor: Colors.transparent,
                elevation: 0,
                icon: const Icon(Icons.receipt_long, color: Colors.white),
                label: const Text(
                  'HÃ³a Ä‘Æ¡n má»›i',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedHeader() {
    return AnimatedBuilder(
      animation: _headerAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _headerAnimation.value)),
          child: Opacity(
            opacity: _headerAnimation.value,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.receipt_long,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quáº£n lÃ½ HÃ³a Ä‘Æ¡n',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.2,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    offset: const Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'Theo dÃµi thanh toÃ¡n thÃ´ng minh',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.1),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                        child: IconButton(
                          onPressed: _showBillOptions,
                          icon: const Icon(
                            Icons.more_vert,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildQuickStats(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickStats() {
    return Consumer<BillProvider>(
      builder: (context, provider, child) {
        final upcomingCount = provider.bills
            .where(
              (bill) =>
                  bill.dueDate.isAfter(DateTime.now()) &&
                  bill.dueDate.isBefore(
                    DateTime.now().add(const Duration(days: 7)),
                  ),
            )
            .length;

        final overdueCount = provider.bills
            .where(
              (bill) => bill.dueDate.isBefore(DateTime.now()) && !bill.isPaid,
            )
            .length;

        final totalAmount = provider.bills.fold<double>(
          0,
          (sum, bill) => sum + (bill.isPaid ? 0 : bill.amount),
        );

        return Row(
          children: [
            Expanded(
              child: _buildQuickStatCard(
                'HÃ³a Ä‘Æ¡n',
                '${provider.bills.length}',
                Icons.receipt_outlined,
                Colors.white.withValues(alpha: 0.1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickStatCard(
                'Sáº¯p Ä‘áº¿n háº¡n',
                '$upcomingCount',
                Icons.schedule,
                Colors.orange.shade300,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickStatCard(
                'QuÃ¡ háº¡n',
                '$overdueCount',
                Icons.warning,
                Colors.red.shade300,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickStatCard(
                'ChÆ°a thanh toÃ¡n',
                '${totalAmount.toStringAsFixed(0)} â‚«',
                Icons.attach_money,
                Colors.green.shade300,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickStatCard(
    String title,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(height: 6),
              Text(
                value.length > 10 ? '${value.substring(0, 10)}...' : value,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.white.withValues(alpha: 0.1),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isSearchExpanded ? 60 : 50,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 20),
                Icon(
                  Icons.search,
                  color: Colors.white.withValues(alpha: 0.1),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'TÃ¬m kiáº¿m hÃ³a Ä‘Æ¡n...',
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.1),
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    onTap: () {
                      setState(() {
                        _isSearchExpanded = true;
                      });
                    },
                    onSubmitted: (value) {
                      setState(() {
                        _isSearchExpanded = false;
                      });
                    },
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                        _isSearchExpanded = false;
                      });
                    },
                    icon: Icon(
                      Icons.clear,
                      color: Colors.white.withValues(alpha: 0.1),
                      size: 20,
                    ),
                  ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: TabBar(
              controller: _tabController,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.1),
                    Colors.white.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withValues(alpha: 0.1),
              labelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(text: 'Táº¥t cáº£'),
                Tab(text: 'Sáº¯p háº¡n'),
                Tab(text: 'QuÃ¡ háº¡n'),
                Tab(text: 'Thá»‘ng kÃª'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAllBills() {
    return Consumer<BillProvider>(
      builder: (context, provider, child) {
        final bills = provider.bills
            .where(
              (bill) =>
                  bill.title.toLowerCase().contains(_searchQuery.toLowerCase()),
            )
            .toList();

        if (bills.isEmpty) {
          return _buildEmptyState();
        }

        return AnimatedBuilder(
          animation: _cardAnimation,
          builder: (context, child) {
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
              itemCount: bills.length,
              itemBuilder: (context, index) {
                return Transform.translate(
                  offset: Offset(0, 30 * (1 - _cardAnimation.value)),
                  child: Opacity(
                    opacity: _cardAnimation.value,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: _buildBillCard(bills[index], index),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildBillCard(Bill bill, int index) {
    final isOverdue = bill.dueDate.isBefore(DateTime.now()) && !bill.isPaid;
    final isUpcoming =
        bill.dueDate.isAfter(DateTime.now()) &&
        bill.dueDate.isBefore(DateTime.now().add(const Duration(days: 7)));
    final daysDiff = bill.dueDate.difference(DateTime.now()).inDays;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showBillDetails(bill);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isOverdue
                    ? Colors.red.withValues(alpha: 0.1)
                    : isUpcoming
                    ? Colors.orange.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getBillCategoryColor(
                              bill.category,
                            ).withValues(alpha: 0.1),
                            _getBillCategoryColor(bill.category),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: _getBillCategoryColor(
                              bill.category,
                            ).withValues(alpha: 0.1),
                            blurRadius: 8,
                            spreadRadius: 0,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        _getBillCategoryIcon(bill.category),
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bill.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            bill.category,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.1),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${bill.amount.toStringAsFixed(0)} â‚«',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: bill.isPaid
                                ? Colors.green.shade300
                                : isOverdue
                                ? Colors.red.shade300
                                : Colors.white,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: bill.isPaid
                                ? Colors.green.withValues(alpha: 0.1)
                                : isOverdue
                                ? Colors.red.withValues(alpha: 0.1)
                                : isUpcoming
                                ? Colors.orange.withValues(alpha: 0.1)
                                : Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: bill.isPaid
                                  ? Colors.green.withValues(alpha: 0.1)
                                  : isOverdue
                                  ? Colors.red.withValues(alpha: 0.1)
                                  : isUpcoming
                                  ? Colors.orange.withValues(alpha: 0.1)
                                  : Colors.blue.withValues(alpha: 0.1),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            bill.isPaid
                                ? 'ÄÃ£ thanh toÃ¡n'
                                : isOverdue
                                ? 'QuÃ¡ háº¡n'
                                : isUpcoming
                                ? 'Sáº¯p Ä‘áº¿n háº¡n'
                                : 'BÃ¬nh thÆ°á»ng',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: bill.isPaid
                                  ? Colors.green.shade300
                                  : isOverdue
                                  ? Colors.red.shade300
                                  : isUpcoming
                                  ? Colors.orange.shade300
                                  : Colors.blue.shade300,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: Colors.white.withValues(alpha: 0.1),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Háº¡n: ${bill.dueDate.day}/${bill.dueDate.month}/${bill.dueDate.year}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.1),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    if (!bill.isPaid)
                      Text(
                        daysDiff > 0
                            ? 'CÃ²n $daysDiff ngÃ y'
                            : daysDiff == 0
                            ? 'HÃ´m nay'
                            : 'QuÃ¡ ${-daysDiff} ngÃ y',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: daysDiff < 0
                              ? Colors.red.shade300
                              : daysDiff <= 3
                              ? Colors.orange.shade300
                              : Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                  ],
                ),
                if (bill.description?.isNotEmpty == true) ...[
                  const SizedBox(height: 12),
                  Text(
                    bill.description!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingBills() {
    return Consumer<BillProvider>(
      builder: (context, provider, child) {
        final upcomingBills = provider.bills
            .where(
              (bill) =>
                  bill.dueDate.isAfter(DateTime.now()) &&
                  bill.dueDate.isBefore(
                    DateTime.now().add(const Duration(days: 7)),
                  ) &&
                  !bill.isPaid &&
                  bill.title.toLowerCase().contains(_searchQuery.toLowerCase()),
            )
            .toList();

        if (upcomingBills.isEmpty) {
          return _buildEmptyState('KhÃ´ng cÃ³ hÃ³a Ä‘Æ¡n sáº¯p Ä‘áº¿n háº¡n');
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
          itemCount: upcomingBills.length,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: _buildBillCard(upcomingBills[index], index),
            );
          },
        );
      },
    );
  }

  Widget _buildOverdueBills() {
    return Consumer<BillProvider>(
      builder: (context, provider, child) {
        final overdueBills = provider.bills
            .where(
              (bill) =>
                  bill.dueDate.isBefore(DateTime.now()) &&
                  !bill.isPaid &&
                  bill.title.toLowerCase().contains(_searchQuery.toLowerCase()),
            )
            .toList();

        if (overdueBills.isEmpty) {
          return _buildEmptyState('KhÃ´ng cÃ³ hÃ³a Ä‘Æ¡n quÃ¡ háº¡n');
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
          itemCount: overdueBills.length,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: _buildBillCard(overdueBills[index], index),
            );
          },
        );
      },
    );
  }

  Widget _buildStatistics() {
    return Consumer<BillProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
          child: Column(
            children: [
              _buildStatisticsSummary(provider),
              const SizedBox(height: 24),
              _buildCategoryBreakdown(provider),
              const SizedBox(height: 24),
              _buildMonthlyTrend(provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatisticsSummary(BillProvider provider) {
    final totalBills = provider.bills.length;
    final paidBills = provider.bills.where((b) => b.isPaid).length;
    final unpaidBills = totalBills - paidBills;
    final totalAmount = provider.bills.fold<double>(
      0,
      (sum, bill) => sum + bill.amount,
    );
    final paidAmount = provider.bills
        .where((b) => b.isPaid)
        .fold<double>(0, (sum, bill) => sum + bill.amount);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tá»•ng quan hÃ³a Ä‘Æ¡n',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'Tá»•ng hÃ³a Ä‘Æ¡n',
                      '$totalBills',
                      Icons.receipt_long,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 60,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'ÄÃ£ thanh toÃ¡n',
                      '$paidBills',
                      Icons.check_circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'ChÆ°a thanh toÃ¡n',
                      '$unpaidBills',
                      Icons.pending,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 60,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Tá»•ng tiá»n',
                      '${totalAmount.toStringAsFixed(0)} â‚«',
                      Icons.attach_money,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.1), size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.1),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCategoryBreakdown(BillProvider provider) {
    final categoryTotals = <String, double>{};
    for (final bill in provider.bills) {
      categoryTotals[bill.category] =
          (categoryTotals[bill.category] ?? 0) + bill.amount;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'HÃ³a Ä‘Æ¡n theo danh má»¥c',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              ...categoryTotals.entries
                  .map(
                    (entry) => Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _getBillCategoryColor(
                                entry.key,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getBillCategoryColor(
                                  entry.key,
                                ).withValues(alpha: 0.1),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              _getBillCategoryIcon(entry.key),
                              color: _getBillCategoryColor(entry.key),
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.key,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value:
                                        categoryTotals.values.fold<double>(
                                              0,
                                              (a, b) => a + b,
                                            ) >
                                            0
                                        ? entry.value /
                                              categoryTotals.values
                                                  .fold<double>(
                                                    0,
                                                    (a, b) => a + b,
                                                  )
                                        : 0,
                                    backgroundColor: Colors.white.withValues(
                                      alpha: 0.2,
                                    ),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      _getBillCategoryColor(entry.key),
                                    ),
                                    minHeight: 6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '${entry.value.toStringAsFixed(0)} â‚«',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthlyTrend(BillProvider provider) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Xu hÆ°á»›ng thanh toÃ¡n',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.trending_up,
                        color: Colors.white.withValues(alpha: 0.1),
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Biá»ƒu Ä‘á»“ xu hÆ°á»›ng',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.1),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Sáº½ Ä‘Æ°á»£c cáº­p nháº­t sau',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.1),
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
  }

  Widget _buildEmptyState([String? message]) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(32),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.receipt_long_outlined,
                    size: 48,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  message ?? 'ChÆ°a cÃ³ hÃ³a Ä‘Æ¡n nÃ o',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'ThÃªm hÃ³a Ä‘Æ¡n Ä‘áº§u tiÃªn Ä‘á»ƒ theo dÃµi thanh toÃ¡n',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _showAddBillDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text(
                    'ThÃªm hÃ³a Ä‘Æ¡n',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getBillCategoryColor(String category) {
    final colors = [
      Colors.blue.shade400,
      Colors.green.shade400,
      Colors.orange.shade400,
      Colors.purple.shade400,
      Colors.red.shade400,
      Colors.teal.shade400,
      Colors.indigo.shade400,
      Colors.pink.shade400,
    ];
    return colors[category.hashCode % colors.length];
  }

  IconData _getBillCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'Ä‘iá»‡n':
        return Icons.electric_bolt;
      case 'nÆ°á»›c':
        return Icons.water_drop;
      case 'internet':
        return Icons.wifi;
      case 'Ä‘iá»‡n thoáº¡i':
        return Icons.phone;
      case 'báº£o hiá»ƒm':
        return Icons.security;
      case 'thuÃª nhÃ ':
        return Icons.home;
      case 'xÄƒng xe':
        return Icons.local_gas_station;
      case 'y táº¿':
        return Icons.medical_services;
      default:
        return Icons.receipt;
    }
  }

  void _showBillDetails(Bill bill) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBillDetailsSheet(bill),
    );
  }

  Widget _buildBillDetailsSheet(Bill bill) {
    final isOverdue = bill.dueDate.isBefore(DateTime.now()) && !bill.isPaid;
    final daysDiff = bill.dueDate.difference(DateTime.now()).inDays;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _getBillCategoryColor(
                                    bill.category,
                                  ).withValues(alpha: 0.1),
                                  _getBillCategoryColor(bill.category),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: _getBillCategoryColor(
                                    bill.category,
                                  ).withValues(alpha: 0.1),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Icon(
                              _getBillCategoryIcon(bill.category),
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bill.title,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  bill.category,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: bill.isPaid
                                  ? Colors.green.withValues(alpha: 0.1)
                                  : isOverdue
                                  ? Colors.red.withValues(alpha: 0.1)
                                  : Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: bill.isPaid
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : isOverdue
                                    ? Colors.red.withValues(alpha: 0.1)
                                    : Colors.orange.withValues(alpha: 0.1),
                              ),
                            ),
                            child: Text(
                              bill.isPaid
                                  ? 'ÄÃ£ thanh toÃ¡n'
                                  : isOverdue
                                  ? 'QuÃ¡ háº¡n'
                                  : 'ChÆ°a thanh toÃ¡n',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: bill.isPaid
                                    ? Colors.green.shade700
                                    : isOverdue
                                    ? Colors.red.shade700
                                    : Colors.orange.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.secondaryGradient.colors.first
                                  .withValues(alpha: 0.1),
                              AppTheme.secondaryGradient.colors.last.withValues(
                                alpha: 0.1,
                              ),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.secondaryGradient.colors.first
                                .withValues(alpha: 0.1),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Sá»‘ tiá»n',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      '${bill.amount.toStringAsFixed(0)} â‚«',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Háº¡n thanh toÃ¡n',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      '${bill.dueDate.day}/${bill.dueDate.month}/${bill.dueDate.year}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (!bill.isPaid) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isOverdue
                                      ? Colors.red.withValues(alpha: 0.1)
                                      : daysDiff <= 3
                                      ? Colors.orange.withValues(alpha: 0.1)
                                      : Colors.blue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isOverdue
                                        ? Colors.red.withValues(alpha: 0.1)
                                        : daysDiff <= 3
                                        ? Colors.orange.withValues(alpha: 0.1)
                                        : Colors.blue.withValues(alpha: 0.1),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isOverdue
                                          ? Icons.warning
                                          : daysDiff <= 3
                                          ? Icons.schedule
                                          : Icons.info,
                                      color: isOverdue
                                          ? Colors.red.shade700
                                          : daysDiff <= 3
                                          ? Colors.orange.shade700
                                          : Colors.blue.shade700,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        isOverdue
                                            ? 'HÃ³a Ä‘Æ¡n Ä‘Ã£ quÃ¡ háº¡n ${-daysDiff} ngÃ y'
                                            : daysDiff == 0
                                            ? 'HÃ³a Ä‘Æ¡n Ä‘áº¿n háº¡n hÃ´m nay'
                                            : daysDiff <= 3
                                            ? 'HÃ³a Ä‘Æ¡n sáº¯p Ä‘áº¿n háº¡n trong $daysDiff ngÃ y'
                                            : 'CÃ²n $daysDiff ngÃ y Ä‘áº¿n háº¡n',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: isOverdue
                                              ? Colors.red.shade700
                                              : daysDiff <= 3
                                              ? Colors.orange.shade700
                                              : Colors.blue.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (bill.description?.isNotEmpty == true) ...[
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ghi chÃº',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                bill.description!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          if (!bill.isPaid) ...[
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _markAsPaid(bill);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade600,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                icon: const Icon(Icons.check),
                                label: const Text(
                                  'ÄÃ¡nh dáº¥u Ä‘Ã£ thanh toÃ¡n',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _showEditBillDialog(bill);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              icon: const Icon(Icons.edit),
                              label: const Text(
                                'Chá»‰nh sá»­a',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _deleteBill(bill);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade400,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              icon: const Icon(Icons.delete),
                              label: const Text(
                                'XÃ³a',
                                style: TextStyle(fontWeight: FontWeight.w600),
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
  }

  void _showAddBillDialog() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: BillForm(
              onSubmit: (billData) {
                // Handle bill creation/update
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showEditBillDialog(Bill bill) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: BillForm(
              bill: bill,
              onSubmit: (billData) {
                // Handle bill update
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showBillOptions() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'TÃ¹y chá»n hÃ³a Ä‘Æ¡n',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.notifications, color: Colors.blue),
                  ),
                  title: const Text('CÃ i Ä‘áº·t nháº¯c nhá»Ÿ'),
                  subtitle: const Text('Quáº£n lÃ½ thÃ´ng bÃ¡o hÃ³a Ä‘Æ¡n'),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Implement bill reminders
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.analytics, color: Colors.green),
                  ),
                  title: const Text('BÃ¡o cÃ¡o chi tiáº¿t'),
                  subtitle: const Text('Xem phÃ¢n tÃ­ch hÃ³a Ä‘Æ¡n'),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Implement bill analytics
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.download, color: Colors.orange),
                  ),
                  title: const Text('Xuáº¥t dá»¯ liá»‡u'),
                  subtitle: const Text('Táº£i xuá»‘ng danh sÃ¡ch hÃ³a Ä‘Æ¡n'),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Implement export functionality
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _markAsPaid(Bill bill) {
    HapticFeedback.lightImpact();
    // Update bill as paid
    context.read<BillProvider>().markBillAsPaid(bill.id!, bill.amount);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('ÄÃ£ Ä‘Ã¡nh dáº¥u "${bill.title}" lÃ  Ä‘Ã£ thanh toÃ¡n'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _deleteBill(Bill bill) {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('XÃ¡c nháº­n xÃ³a'),
        content: Text(
          'Báº¡n cÃ³ cháº¯c cháº¯n muá»‘n xÃ³a hÃ³a Ä‘Æ¡n "${bill.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Há»§y'),
          ),
          TextButton(
            onPressed: () {
              context.read<BillProvider>().deleteBill(bill.id!);
              Navigator.pop(context);
            },
            child: const Text('XÃ³a', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _BillPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const spacing = 50.0;

    // Draw diagonal lines pattern
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }

    // Draw decorative circles
    final circlePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 8; i++) {
      final x = (size.width / 9) * (i + 1);
      final y = size.height * 0.2 + (i % 3) * size.height * 0.3;
      canvas.drawCircle(Offset(x, y), 15 + (i % 4) * 8, circlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
