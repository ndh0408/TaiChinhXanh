import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../theme.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import '../widgets/transaction_form.dart';
import '../utils/currency_formatter.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _listController;
  late AnimationController _fabController;

  late Animation<double> _headerSlideAnimation;
  late Animation<double> _headerFadeAnimation;
  late Animation<double> _listSlideAnimation;
  late Animation<double> _fabScaleAnimation;

  String _currentFilter = 'all';
  String _sortBy = 'date_desc';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filterOptions = ['all', 'income', 'expense'];
  final List<String> _sortOptions = [
    'date_desc',
    'date_asc',
    'amount_desc',
    'amount_asc',
  ];

  bool _isSearching = false;
  List<Transaction> _filteredTransactions = [];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _searchController.addListener(_onSearchChanged);
  }

  void _setupAnimations() {
    _headerController = AnimationController(
      duration: AppTheme.slowDuration,
      vsync: this,
    );

    _listController = AnimationController(
      duration: AppTheme.extraSlowDuration,
      vsync: this,
    );

    _fabController = AnimationController(
      duration: AppTheme.normalDuration,
      vsync: this,
    );

    _headerSlideAnimation = Tween<double>(begin: -30.0, end: 0.0).animate(
      CurvedAnimation(parent: _headerController, curve: AppTheme.smoothCurve),
    );

    _headerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: AppTheme.smoothCurve),
    );

    _listSlideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _listController, curve: AppTheme.quickCurve),
    );

    _fabScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabController, curve: AppTheme.bounceInCurve),
    );

    // Start animations
    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _listController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _fabController.forward();
    });
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _updateFilteredTransactions();
    });
  }

  void _updateFilteredTransactions() {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    var transactions = provider.transactions;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      transactions = transactions.where((transaction) {
        return transaction.description?.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ??
            false;
      }).toList();
    }

    // Apply type filter
    if (_currentFilter != 'all') {
      transactions = transactions.where((transaction) {
        return transaction.type == _currentFilter;
      }).toList();
    }

    // Apply sorting
    transactions.sort((a, b) {
      switch (_sortBy) {
        case 'date_desc':
          return b.transactionDate.compareTo(a.transactionDate);
        case 'date_asc':
          return a.transactionDate.compareTo(b.transactionDate);
        case 'amount_desc':
          return b.amount.compareTo(a.amount);
        case 'amount_asc':
          return a.amount.compareTo(b.amount);
        default:
          return b.transactionDate.compareTo(a.transactionDate);
      }
    });

    _filteredTransactions = transactions;
  }

  @override
  void dispose() {
    _headerController.dispose();
    _listController.dispose();
    _fabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (provider.error != null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: AppTheme.errorStart),
                  SizedBox(height: AppTheme.spacing4),
                  Text('Lá»—i: ${provider.error}'),
                  SizedBox(height: AppTheme.spacing4),
                  ElevatedButton(
                    onPressed: () => provider.loadTransactions(),
                    child: const Text('Thá»­ láº¡i'),
                  ),
                ],
              ),
            ),
          );
        }

        // Update filtered transactions when provider data changes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateFilteredTransactions();
        });

        return Scaffold(
          extendBodyBehindAppBar: true,
          body: Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.backgroundGradient,
            ),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Beautiful Header
                _buildSliverAppBar(),

                // Search & Filter Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(AppTheme.spacing4),
                    child: Column(
                      children: [
                        _buildSearchBar(),
                        SizedBox(height: AppTheme.spacing4),
                        _buildFilterRow(),
                      ],
                    ),
                  ),
                ),

                // Summary Cards
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing4,
                    ),
                    child: _buildSummaryCards(provider),
                  ),
                ),

                // Transactions List
                _buildTransactionsList(),
              ],
            ),
          ),

          // Beautiful FAB
          floatingActionButton: AnimatedBuilder(
            animation: _fabController,
            builder: (context, child) {
              return Transform.scale(
                scale: _fabScaleAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    boxShadow: AppTheme.glowShadow,
                  ),
                  child: FloatingActionButton(
                    onPressed: () => _showAddTransactionDialog(context),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    child: const Icon(
                      Icons.add_rounded,
                      color: AppTheme.white,
                      size: AppTheme.iconLG,
                    ),
                  ),
                ),
              );
            },
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
          decoration: const BoxDecoration(gradient: AppTheme.accentGradient),
          child: Stack(
            children: [
              // Background Pattern
              Positioned.fill(
                child: CustomPaint(painter: TransactionPatternPainter()),
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
                                      Icons.receipt_long_rounded,
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
                                          'Giao dá»‹ch',
                                          style: AppTheme.displaySmall.copyWith(
                                            color: AppTheme.white,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        Text(
                                          'Quáº£n lÃ½ thu chi thÃ´ng minh',
                                          style: AppTheme.bodyLarge.copyWith(
                                            color: AppTheme.white.withValues(alpha: 
                                              0.9,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isSearching = !_isSearching;
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(
                                        AppTheme.spacing3,
                                      ),
                                      decoration: AppTheme.glassMorphism(
                                        color: AppTheme.white.withValues(alpha: 0.9),
                                        borderRadius: AppTheme.radiusFull,
                                      ),
                                      child: Icon(
                                        _isSearching
                                            ? Icons.close
                                            : Icons.search,
                                        color: AppTheme.white,
                                        size: AppTheme.iconLG,
                                      ),
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

  Widget _buildSearchBar() {
    return AnimatedContainer(
      duration: AppTheme.normalDuration,
      height: _isSearching ? 60 : 0,
      child: _isSearching
          ? Container(
              decoration: AppTheme.glassMorphism(
                color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'TÃ¬m kiáº¿m giao dá»‹ch...',
                  prefixIcon: const Icon(Icons.search, color: AppTheme.gray500),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(AppTheme.spacing4),
                ),
                onChanged: (value) => _onSearchChanged(),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildFilterRow() {
    return Row(
      children: [
        // Filter Chips
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Táº¥t cáº£', 'all'),
                SizedBox(width: AppTheme.spacing2),
                _buildFilterChip('Thu nháº­p', 'income'),
                SizedBox(width: AppTheme.spacing2),
                _buildFilterChip('Chi tiÃªu', 'expense'),
              ],
            ),
          ),
        ),

        SizedBox(width: AppTheme.spacing4),

        // Sort Button
        GestureDetector(
          onTap: _showSortDialog,
          child: Container(
            padding: EdgeInsets.all(AppTheme.spacing3),
            decoration: AppTheme.glassMorphism(
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
            ),
            child: const Icon(
              Icons.sort_rounded,
              color: AppTheme.primaryColor,
              size: AppTheme.iconLG,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _currentFilter == value;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _currentFilter = value;
          _updateFilteredTransactions();
        });
      },
      child: AnimatedContainer(
        duration: AppTheme.normalDuration,
        padding: EdgeInsets.symmetric(
          horizontal: AppTheme.spacing4,
          vertical: AppTheme.spacing2,
        ),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.primaryGradient : null,
          color: isSelected
              ? null
              : Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          boxShadow: isSelected ? AppTheme.lightShadow : null,
          border: isSelected
              ? null
              : Border.all(color: AppTheme.gray300, width: 1),
        ),
        child: Text(
          label,
          style: AppTheme.labelMedium.copyWith(
            color: isSelected ? AppTheme.white : AppTheme.gray600,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(TransactionProvider provider) {
    final totalIncome = _filteredTransactions
        .where((t) => t.type == 'income')
        .fold(0.0, (sum, t) => sum + t.amount);

    final totalExpense = _filteredTransactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (sum, t) => sum + t.amount);

    final balance = totalIncome - totalExpense;

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Thu nháº­p',
            CurrencyFormatter.formatVNDShort(totalIncome),
            Icons.trending_up_rounded,
            AppTheme.successGradient,
          ),
        ),
        SizedBox(width: AppTheme.spacing4),
        Expanded(
          child: _buildSummaryCard(
            'Chi tiÃªu',
            CurrencyFormatter.formatVNDShort(totalExpense),
            Icons.trending_down_rounded,
            AppTheme.errorGradient,
          ),
        ),
        SizedBox(width: AppTheme.spacing4),
        Expanded(
          child: _buildSummaryCard(
            'Sá»‘ dÆ°',
            CurrencyFormatter.formatVNDShort(balance),
            Icons.account_balance_wallet_rounded,
            balance >= 0 ? AppTheme.accentGradient : AppTheme.warningGradient,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    LinearGradient gradient,
  ) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacing4),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        boxShadow: AppTheme.lightShadow,
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.white, size: AppTheme.iconLG),
          SizedBox(height: AppTheme.spacing2),
          Text(
            value,
            style: AppTheme.titleMedium.copyWith(
              color: AppTheme.white,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            title,
            style: AppTheme.labelSmall.copyWith(
              color: AppTheme.white.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList() {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        AppTheme.spacing4,
        AppTheme.spacing6,
        AppTheme.spacing4,
        AppTheme.spacing20, // Extra padding for FAB
      ),
      sliver: AnimatedBuilder(
        animation: _listController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _listSlideAnimation.value),
            child: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (_filteredTransactions.isEmpty) {
                    return _buildEmptyState();
                  }

                  final transaction = _filteredTransactions[index];
                  return AnimatedBuilder(
                    animation: _listController,
                    builder: (context, child) {
                      final delay = index * 0.1;
                      final animationValue = Curves.easeOutQuart.transform(
                        (_listController.value - delay).clamp(0.0, 1.0),
                      );

                      return Transform.translate(
                        offset: Offset(0, 50 * (1 - animationValue)),
                        child: Opacity(
                          opacity: animationValue,
                          child: Container(
                            margin: EdgeInsets.only(bottom: AppTheme.spacing3),
                            child: _buildTransactionCard(transaction),
                          ),
                        ),
                      );
                    },
                  );
                },
                childCount: _filteredTransactions.isEmpty
                    ? 1
                    : _filteredTransactions.length,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: AppTheme.icon3XL,
            color: AppTheme.gray400,
          ),
          SizedBox(height: AppTheme.spacing4),
          Text(
            _searchQuery.isNotEmpty
                ? 'Không tìm thấy giao dịch nào'
                : 'Chưa có giao dịch nào',
            style: AppTheme.headlineSmall.copyWith(
              color: AppTheme.gray600,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppTheme.spacing2),
          Text(
            _searchQuery.isNotEmpty
                ? 'Thử thay đổi từ khóa tìm kiếm'
                : 'Thêm giao dịch đầu tiên của bạn',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.gray500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    final isIncome = transaction.type == 'income';
    final gradient = isIncome
        ? AppTheme.successGradient
        : AppTheme.errorGradient;
    final icon = isIncome
        ? Icons.trending_up_rounded
        : Icons.trending_down_rounded;

    return Container(
      decoration: AppTheme.glassMorphism(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(AppTheme.spacing4),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(AppTheme.radiusLG),
            boxShadow: AppTheme.lightShadow,
          ),
          child: Icon(icon, color: AppTheme.white, size: AppTheme.iconLG),
        ),
        title: Text(
          transaction.description ?? 'Giao dá»‹ch',
          style: AppTheme.titleMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: AppTheme.spacing1),
            Text(
              _formatTransactionDate(transaction.transactionDate),
              style: AppTheme.bodySmall.copyWith(color: AppTheme.gray500),
            ),
            if (transaction.paymentMethod != null) ...[
              SizedBox(height: AppTheme.spacing1),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing2,
                  vertical: AppTheme.spacing1,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.gray200,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                ),
                child: Text(
                  _getPaymentMethodLabel(transaction.paymentMethod!),
                  style: AppTheme.labelSmall.copyWith(
                    color: AppTheme.gray600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isIncome ? '+' : '-'}${CurrencyFormatter.formatVNDShort(transaction.amount)}',
              style: AppTheme.titleMedium.copyWith(
                color: isIncome ? AppTheme.successStart : AppTheme.errorStart,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: AppTheme.spacing1),
            Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.gray400,
              size: AppTheme.iconMD,
            ),
          ],
        ),
        onTap: () => _showTransactionDetails(transaction),
      ),
    );
  }

  void _showSortDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppTheme.radiusXL),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.symmetric(vertical: AppTheme.spacing4),
              decoration: BoxDecoration(
                color: AppTheme.gray300,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
            ),

            Text(
              'Sáº¯p xáº¿p theo',
              style: AppTheme.headlineSmall.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),

            SizedBox(height: AppTheme.spacing4),

            ..._getSortOptions()
                .map(
                  (option) => ListTile(
                    leading: Icon(
                      option['icon'] as IconData,
                      color: _sortBy == option['value']
                          ? AppTheme.primaryColor
                          : AppTheme.gray500,
                    ),
                    title: Text(
                      option['label'] as String,
                      style: AppTheme.titleMedium.copyWith(
                        color: _sortBy == option['value']
                            ? AppTheme.primaryColor
                            : null,
                        fontWeight: _sortBy == option['value']
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                    trailing: _sortBy == option['value']
                        ? const Icon(Icons.check, color: AppTheme.primaryColor)
                        : null,
                    onTap: () {
                      setState(() {
                        _sortBy = option['value'] as String;
                        _updateFilteredTransactions();
                      });
                      Navigator.pop(context);
                    },
                  ),
                )
                .toList(),

            SizedBox(height: AppTheme.spacing6),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getSortOptions() {
    return [
      {
        'label': 'Má»›i nháº¥t',
        'value': 'date_desc',
        'icon': Icons.calendar_today_rounded,
      },
      {'label': 'CÅ© nháº¥t', 'value': 'date_asc', 'icon': Icons.history_rounded},
      {
        'label': 'Sá»‘ tiá»n cao nháº¥t',
        'value': 'amount_desc',
        'icon': Icons.trending_up_rounded,
      },
      {
        'label': 'Sá»‘ tiá»n tháº¥p nháº¥t',
        'value': 'amount_asc',
        'icon': Icons.trending_down_rounded,
      },
    ];
  }

  void _showAddTransactionDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppTheme.radiusXL),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.symmetric(vertical: AppTheme.spacing4),
              decoration: BoxDecoration(
                color: AppTheme.gray300,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
            ),

            // Header
            Padding(
              padding: EdgeInsets.all(AppTheme.spacing6),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(AppTheme.spacing2),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                    ),
                    child: const Icon(
                      Icons.add_circle_outline_rounded,
                      color: AppTheme.primaryColor,
                      size: AppTheme.iconLG,
                    ),
                  ),
                  SizedBox(width: AppTheme.spacing3),
                  Expanded(
                    child: Text(
                      'ThÃªm giao dá»‹ch má»›i',
                      style: AppTheme.headlineMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(AppTheme.spacing6),
                child: TransactionForm(
                  onSubmit: (data) {
                    final transaction = Transaction(
                      type: data['type'],
                      categoryId: data['categoryId'],
                      amount: data['amount'],
                      description: data['description'] ?? '',
                      transactionDate: data['date'] ?? DateTime.now(),
                      paymentMethod: data['paymentMethod'] ?? 'cash',
                      incomeSourceId: data['incomeSourceId'],
                      location: data['location'],
                      receiptPhoto: data['receiptPhoto'],
                      tags: data['tags'],
                      createdAt: DateTime.now(),
                    );

                    Provider.of<TransactionProvider>(
                      context,
                      listen: false,
                    ).addTransaction(transaction);
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('ÄÃ£ thÃªm giao dá»‹ch thÃ nh cÃ´ng!'),
                        backgroundColor: AppTheme.successStart,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusLG,
                          ),
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
    );
  }

  void _showTransactionDetails(Transaction transaction) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppTheme.radiusXL),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(AppTheme.spacing6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(bottom: AppTheme.spacing4),
                decoration: BoxDecoration(
                  color: AppTheme.gray300,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
              ),

              Text(
                'Chi tiáº¿t giao dá»‹ch',
                style: AppTheme.headlineSmall.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),

              SizedBox(height: AppTheme.spacing6),

              // Transaction details
              _buildDetailRow('MÃ´ táº£', transaction.description ?? 'KhÃ´ng cÃ³'),
              _buildDetailRow(
                'Sá»‘ tiá»n',
                CurrencyFormatter.formatVND(transaction.amount),
              ),
              _buildDetailRow(
                'Loáº¡i',
                transaction.type == 'income' ? 'Thu nháº­p' : 'Chi tiÃªu',
              ),
              _buildDetailRow(
                'NgÃ y',
                _formatTransactionDate(transaction.transactionDate),
              ),
              if (transaction.paymentMethod != null)
                _buildDetailRow(
                  'PhÆ°Æ¡ng thá»©c',
                  _getPaymentMethodLabel(transaction.paymentMethod!),
                ),
              if (transaction.location != null)
                _buildDetailRow('Äá»‹a Ä‘iá»ƒm', transaction.location!),

              SizedBox(height: AppTheme.spacing6),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppTheme.spacing2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.gray600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTransactionDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) return 'HÃ´m nay';
    if (difference == 1) return 'HÃ´m qua';
    if (difference < 7) return '$difference ngÃ y trÆ°á»›c';

    return '${date.day}/${date.month}/${date.year}';
  }

  String _getPaymentMethodLabel(String method) {
    switch (method) {
      case 'cash':
        return 'Tiá»n máº·t';
      case 'card':
        return 'Tháº»';
      case 'bank':
        return 'Chuyá»ƒn khoáº£n';
      case 'ewallet':
        return 'VÃ­ Ä‘iá»‡n tá»­';
      default:
        return method;
    }
  }
}

// Custom painter for transaction background pattern
class TransactionPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw flowing lines
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final startY = size.height / 5 * i;
      path.moveTo(0, startY);
      path.quadraticBezierTo(
        size.width / 2,
        startY + (i.isEven ? -20 : 20),
        size.width,
        startY,
      );
    }

    canvas.drawPath(path, paint);

    // Draw scattered circles
    final circlePaint = Paint()
      ..color = AppTheme.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;

    final random = Random(42);
    for (int i = 0; i < 15; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 15 + 5;

      canvas.drawCircle(Offset(x, y), radius, circlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

