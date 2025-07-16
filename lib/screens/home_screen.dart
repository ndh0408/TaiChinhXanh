import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dashboard_screen.dart';
import 'transactions_screen.dart';
import 'budgets_screen.dart';
import 'analytics_screen.dart';
import 'settings_screen.dart';
import '../theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _navigationController;
  late AnimationController _fabController;

  late Animation<double> _navigationSlideAnimation;
  late Animation<double> _fabScaleAnimation;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const TransactionsScreen(),
    const BudgetsScreen(),
    const AnalyticsScreen(),
    const SettingsScreen(),
  ];

  final List<NavigationItem> _navItems = [
    NavigationItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Tổng quan',
      color: AppTheme.vcbGreen,
    ),
    NavigationItem(
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long_rounded,
      label: 'Giao dịch',
      color: AppTheme.vcbGreen,
    ),
    NavigationItem(
      icon: Icons.account_balance_wallet_outlined,
      activeIcon: Icons.account_balance_wallet_rounded,
      label: 'Ngân sách',
      color: AppTheme.vcbGreen,
    ),
    NavigationItem(
      icon: Icons.insights_outlined,
      activeIcon: Icons.insights_rounded,
      label: 'Phân tích',
      color: AppTheme.vcbGreen,
    ),
    NavigationItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
      label: 'Cài đặt',
      color: AppTheme.vcbGreen,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _setupAnimations();
  }

  void _setupAnimations() {
    _navigationController = AnimationController(
      duration: AppTheme.slowDuration,
      vsync: this,
    );

    _fabController = AnimationController(
      duration: AppTheme.normalDuration,
      vsync: this,
    );

    _navigationSlideAnimation = Tween<double>(begin: 100.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _navigationController,
        curve: AppTheme.smoothCurve,
      ),
    );

    _fabScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabController, curve: AppTheme.bounceInCurve),
    );

    // Start animations
    Future.delayed(AppTheme.normalDuration, () {
      _navigationController.forward();
      _fabController.forward();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _navigationController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;

    // Haptic feedback
    HapticFeedback.lightImpact();

    setState(() {
      _currentIndex = index;
    });

    _pageController.animateToPage(
      index,
      duration: AppTheme.normalDuration,
      curve: AppTheme.smoothCurve,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
        child: SafeArea(
          bottom: false, // Allow bottom navigation to extend
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            children: _screens,
          ),
        ),
      ),

      // Beautiful Floating Action Button with responsive sizing
      floatingActionButton: ScaleTransition(
        scale: _fabScaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.vcbGreen,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.vcbGreen.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            onPressed: () {
              // TODO: Open quick add transaction dialog
              _showQuickAddDialog(context);
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            icon: const Icon(
              Icons.add_rounded,
              color: AppTheme.white,
              size: AppTheme.iconLG,
            ),
            label: Text(
              'Thêm',
              style: AppTheme.labelLarge.copyWith(
                color: AppTheme.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Beautiful Bottom Navigation Bar
      bottomNavigationBar: AnimatedBuilder(
        animation: _navigationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _navigationSlideAnimation.value),
            child: Container(
              margin: EdgeInsets.all(AppTheme.spacing4),
              decoration: AppTheme.glassMorphism(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.gray800.withValues(alpha: 0.9)
                    : AppTheme.white.withValues(alpha: 0.9),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusXL),
                child: BottomAppBar(
                  elevation: 0,
                  color: Colors.transparent,
                  shape: const CircularNotchedRectangle(),
                  notchMargin: AppTheme.spacing2,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing4,
                      vertical: AppTheme.spacing2,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // First two tabs
                        ..._navItems.take(2).map((item) {
                          final index = _navItems.indexOf(item);
                          return _buildNavItem(item, index);
                        }).toList(),

                        // Space for FAB
                        SizedBox(width: AppTheme.spacing12),

                        // Last three tabs
                        ..._navItems.skip(2).map((item) {
                          final index = _navItems.indexOf(item);
                          return _buildNavItem(item, index);
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavItem(NavigationItem item, int index) {
    final isActive = index == _currentIndex;

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isActive ? item.color : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isActive ? item.activeIcon : item.icon,
                key: ValueKey(isActive),
                color: isActive
                    ? AppTheme.vcbWhite
                    : Theme.of(context).brightness == Brightness.dark
                        ? AppTheme.vcbGrey
                        : AppTheme.vcbGrey,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOutCubic,
              style: TextStyle(
                fontSize: isActive ? 12 : 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive
                    ? AppTheme.vcbWhite
                    : Theme.of(context).brightness == Brightness.dark
                        ? AppTheme.vcbGrey
                        : AppTheme.vcbGrey,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickAddDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
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

            // Title
            Padding(
              padding: EdgeInsets.all(AppTheme.spacing6),
              child: Text(
                'Thêm giao dịch nhanh',
                style: AppTheme.headlineMedium,
              ),
            ),

            // Quick actions
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                padding: EdgeInsets.all(AppTheme.spacing6),
                childAspectRatio: 1.5,
                crossAxisSpacing: AppTheme.spacing4,
                mainAxisSpacing: AppTheme.spacing4,
                children: [
                  _buildQuickActionCard(
                    'Thu nhập',
                    Icons.trending_up_rounded,
                    AppTheme.successGradient,
                    () {
                      Navigator.pop(context);
                      // TODO: Open income form
                    },
                  ),
                  _buildQuickActionCard(
                    'Chi tiêu',
                    Icons.trending_down_rounded,
                    AppTheme.errorGradient,
                    () {
                      Navigator.pop(context);
                      // TODO: Open expense form
                    },
                  ),
                  _buildQuickActionCard(
                    'Chuyển khoản',
                    Icons.swap_horiz_rounded,
                    AppTheme.accentGradient,
                    () {
                      Navigator.pop(context);
                      // TODO: Open transfer form
                    },
                  ),
                  _buildQuickActionCard(
                    'Tiết kiệm',
                    Icons.savings_rounded,
                    AppTheme.warningGradient,
                    () {
                      Navigator.pop(context);
                      // TODO: Open savings form
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
          borderRadius: BorderRadius.circular(AppTheme.radiusLG),
          boxShadow: AppTheme.lightShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.white, size: AppTheme.icon2XL),
            SizedBox(height: AppTheme.spacing2),
            Text(
              title,
              style: AppTheme.titleMedium.copyWith(
                color: AppTheme.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Color color;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.color,
  });
}
