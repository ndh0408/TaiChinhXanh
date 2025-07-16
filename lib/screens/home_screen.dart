import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

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
  late AnimationController _indicatorController;

  late Animation<double> _navigationSlideAnimation;
  late Animation<double> _fabScaleAnimation;
  late Animation<double> _indicatorAnimation;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const TransactionsScreen(),
    const BudgetsScreen(),
    const AnalyticsScreen(),
    const SettingsScreen(),
  ];

  final List<NavigationItem> _navItems = [
    NavigationItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
      label: 'Tổng quan',
    ),
    NavigationItem(
      icon: Icons.swap_horizontal_circle_outlined,
      activeIcon: Icons.swap_horizontal_circle,
      label: 'Giao dịch',
    ),
    NavigationItem(
      icon: Icons.account_balance_wallet_outlined,
      activeIcon: Icons.account_balance_wallet,
      label: 'Ngân sách',
    ),
    NavigationItem(
      icon: Icons.pie_chart_outline,
      activeIcon: Icons.pie_chart,
      label: 'Phân tích',
    ),
    NavigationItem(
      icon: Icons.manage_accounts_outlined,
      activeIcon: Icons.manage_accounts,
      label: 'Cài đặt',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _setupAnimations();
    
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppTheme.vcbWhite,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  void _setupAnimations() {
    _navigationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fabController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _indicatorController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _navigationSlideAnimation = Tween<double>(
      begin: 100.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _navigationController,
      curve: Curves.easeOutCubic,
    ));

    _fabScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabController,
      curve: Curves.elasticOut,
    ));

    _indicatorAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _indicatorController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    Future.delayed(const Duration(milliseconds: 300), () {
      _navigationController.forward();
      _fabController.forward();
      _indicatorController.forward();
    });
  }

  void _onItemTapped(int index) {
    if (index != _currentIndex) {
      HapticFeedback.lightImpact();
      setState(() {
        _currentIndex = index;
      });
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _indicatorController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _navigationController.dispose();
    _fabController.dispose();
    _indicatorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.padding.bottom;
    
    return Scaffold(
      backgroundColor: AppTheme.vcbBackground,
      body: Stack(
        children: [
          // Main content
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
              _indicatorController.forward(from: 0);
            },
            physics: const NeverScrollableScrollPhysics(),
            children: _screens,
          ),
          
          // Vietcombank style bottom navigation
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _navigationSlideAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _navigationSlideAnimation.value),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.vcbWhite,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.vcbBlack.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Navigation indicator
                        AnimatedBuilder(
                          animation: _indicatorAnimation,
                          builder: (context, child) {
                            return Container(
                              height: 3,
                              margin: EdgeInsets.only(
                                left: (mediaQuery.size.width / 5) * _currentIndex,
                                right: (mediaQuery.size.width / 5) * (4 - _currentIndex),
                              ),
                              decoration: BoxDecoration(
                                gradient: AppTheme.vcbPrimaryGradient,
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(3),
                                  bottomRight: Radius.circular(3),
                                ),
                              ),
                            );
                          },
                        ),
                        
                        // Navigation items
                        Container(
                          padding: EdgeInsets.only(
                            top: 8,
                            bottom: bottomPadding + 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: _navItems.asMap().entries.map((entry) {
                              final index = entry.key;
                              final item = entry.value;
                              final isSelected = _currentIndex == index;
                              
                              return Expanded(
                                child: InkWell(
                                  onTap: () => _onItemTapped(index),
                                  splashColor: AppTheme.vcbPrimaryGreen.withOpacity(0.1),
                                  highlightColor: AppTheme.vcbPrimaryGreen.withOpacity(0.05),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        AnimatedSwitcher(
                                          duration: const Duration(milliseconds: 200),
                                          child: Icon(
                                            isSelected ? item.activeIcon : item.icon,
                                            key: ValueKey(isSelected),
                                            color: isSelected
                                                ? AppTheme.vcbPrimaryGreen
                                                : AppTheme.vcbGrey600,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        AnimatedDefaultTextStyle(
                                          duration: const Duration(milliseconds: 200),
                                          style: AppTheme.labelSmall.copyWith(
                                            color: isSelected
                                                ? AppTheme.vcbPrimaryGreen
                                                : AppTheme.vcbGrey600,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w500,
                                          ),
                                          child: Text(item.label),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Floating action button for quick actions
          Positioned(
            right: 16,
            bottom: bottomPadding + 100,
            child: AnimatedBuilder(
              animation: _fabScaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _fabScaleAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppTheme.vcbPrimaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.vcbPrimaryGreen.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          _showQuickActions(context);
                        },
                        customBorder: const CircleBorder(),
                        child: Container(
                          width: 56,
                          height: 56,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.add_rounded,
                            color: AppTheme.vcbWhite,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: AppTheme.vcbBlack.withOpacity(0.5),
      builder: (context) => _QuickActionsSheet(),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class _QuickActionsSheet extends StatelessWidget {
  final List<QuickAction> _actions = [
    QuickAction(
      icon: Icons.add_circle_outline,
      title: 'Thêm giao dịch',
      subtitle: 'Ghi lại thu chi hàng ngày',
      color: AppTheme.vcbPrimaryGreen,
      onTap: () {},
    ),
    QuickAction(
      icon: Icons.camera_alt_outlined,
      title: 'Quét hóa đơn',
      subtitle: 'Tự động nhận diện hóa đơn',
      color: AppTheme.vcbBlue,
      onTap: () {},
    ),
    QuickAction(
      icon: Icons.account_balance_outlined,
      title: 'Chuyển tiền',
      subtitle: 'Chuyển tiền nhanh chóng',
      color: AppTheme.vcbOrange,
      onTap: () {},
    ),
    QuickAction(
      icon: Icons.savings_outlined,
      title: 'Tạo mục tiêu',
      subtitle: 'Lập kế hoạch tiết kiệm',
      color: AppTheme.vcbGold,
      onTap: () {},
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.vcbWhite,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusXLarge),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.vcbGrey300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Title
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Thao tác nhanh',
              style: AppTheme.headlineSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          // Actions grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _actions.length,
              itemBuilder: (context, index) {
                final action = _actions[index];
                return _QuickActionCard(action: action);
              },
            ),
          ),
          
          SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
        ],
      ),
    );
  }
}

class QuickAction {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  QuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}

class _QuickActionCard extends StatelessWidget {
  final QuickAction action;

  const _QuickActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.vcbGrey100,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
          action.onTap();
        },
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: action.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Icon(
                  action.icon,
                  color: action.color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                action.title,
                style: AppTheme.titleSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                action.subtitle,
                style: AppTheme.labelSmall.copyWith(
                  color: AppTheme.vcbTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
