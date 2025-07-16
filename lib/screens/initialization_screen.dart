import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/income_source_provider.dart';
import '../providers/ai_provider.dart';
import '../providers/bill_provider.dart';
import '../providers/budget_provider.dart';
import '../providers/theme_provider.dart';
import '../theme.dart';
import 'home_screen.dart';

class InitializationScreen extends StatefulWidget {
  const InitializationScreen({super.key});

  @override
  State<InitializationScreen> createState() => _InitializationScreenState();
}

class _InitializationScreenState extends State<InitializationScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _itemController;
  late Animation<double> _progressAnimation;
  late Animation<double> _itemAnimation;

  final List<InitTask> _tasks = [
    InitTask('Khởi tạo cơ sở dữ liệu', Icons.storage_rounded),
    InitTask('Đồng bộ dữ liệu', Icons.sync_rounded),
    InitTask('Tải cấu hình', Icons.settings_rounded),
    InitTask('Khởi động AI', Icons.auto_awesome_rounded),
    InitTask('Chuẩn bị giao diện', Icons.palette_rounded),
    InitTask('Hoàn tất', Icons.check_circle_rounded),
  ];

  int _currentTaskIndex = 0;
  double _overallProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _itemController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _itemAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _itemController, curve: Curves.easeOutBack),
    );
  }

  Future<void> _initializeApp() async {
    final providers = [
      Provider.of<ThemeProvider>(context, listen: false),
      Provider.of<TransactionProvider>(context, listen: false),
      Provider.of<IncomeSourceProvider>(context, listen: false),
      Provider.of<AIProvider>(context, listen: false),
      Provider.of<BillProvider>(context, listen: false),
      Provider.of<BudgetProvider>(context, listen: false),
    ];

    for (int i = 0; i < _tasks.length; i++) {
      if (!mounted) return;

      setState(() {
        _currentTaskIndex = i;
        _overallProgress = (i / _tasks.length);
      });

      _itemController.forward();
      _progressController.forward();

      // Initialize providers
      if (i < providers.length) {
        if (i == 0) await (providers[0] as ThemeProvider).initialize();
        else if (i == 1) await (providers[1] as TransactionProvider).initialize();
        else if (i == 2) await (providers[2] as IncomeSourceProvider).initialize();
        else if (i == 3) await (providers[3] as AIProvider).initialize();
        else if (i == 4) await (providers[4] as BillProvider).initialize();
        else if (i == 5) await (providers[5] as BudgetProvider).initialize();
      }

      await Future.delayed(const Duration(milliseconds: 600));
      
      if (i < _tasks.length - 1) {
        _itemController.reset();
        _progressController.reset();
      }
    }

    setState(() {
      _overallProgress = 1.0;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HomeScreen(),
          transitionDuration: const Duration(milliseconds: 800),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.05),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              ),
            );
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _itemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.vcbLightGrey,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // VCB Logo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.vcbGreen,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.vcbGreen.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.account_balance,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              // Title
              Text(
                'Đang chuẩn bị',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.vcbBlack,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Vui lòng đợi trong giây lát',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.vcbGrey,
                    ),
              ),
              const SizedBox(height: 48),
              // Progress indicator
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.vcbGrey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, child) {
                    return LinearProgressIndicator(
                      value: _overallProgress + 
                             (_progressAnimation.value / _tasks.length),
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.vcbGreen,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    );
                  },
                ),
              ),
              const SizedBox(height: 48),
              // Task list
              Expanded(
                child: ListView.builder(
                  itemCount: _tasks.length,
                  itemBuilder: (context, index) {
                    final task = _tasks[index];
                    final isActive = index == _currentTaskIndex;
                    final isCompleted = index < _currentTaskIndex;

                    return AnimatedBuilder(
                      animation: _itemAnimation,
                      builder: (context, child) {
                        final scale = isActive 
                            ? 0.95 + (_itemAnimation.value * 0.05)
                            : 1.0;
                        final opacity = isActive
                            ? 0.5 + (_itemAnimation.value * 0.5)
                            : (isCompleted ? 1.0 : 0.5);

                        return Transform.scale(
                          scale: scale,
                          child: Opacity(
                            opacity: opacity,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppTheme.vcbGreen.withOpacity(0.1)
                                    : (isCompleted
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.5)),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isActive
                                      ? AppTheme.vcbGreen
                                      : (isCompleted
                                          ? AppTheme.vcbGreen.withOpacity(0.3)
                                          : Colors.transparent),
                                  width: isActive ? 2 : 1,
                                ),
                                boxShadow: isActive || isCompleted
                                    ? [
                                        BoxShadow(
                                          color: AppTheme.vcbGreen
                                              .withOpacity(0.1),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  // Icon
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? AppTheme.vcbGreen
                                          : (isCompleted
                                              ? AppTheme.vcbGreen
                                                  .withOpacity(0.2)
                                              : AppTheme.vcbGrey
                                                  .withOpacity(0.1)),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      task.icon,
                                      color: isActive
                                          ? Colors.white
                                          : (isCompleted
                                              ? AppTheme.vcbGreen
                                              : AppTheme.vcbGrey),
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Text
                                  Expanded(
                                    child: Text(
                                      task.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: isActive
                                                ? AppTheme.vcbGreen
                                                : (isCompleted
                                                    ? AppTheme.vcbBlack
                                                    : AppTheme.vcbGrey),
                                            fontWeight: isActive
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                    ),
                                  ),
                                  // Status
                                  if (isActive)
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          AppTheme.vcbGreen,
                                        ),
                                      ),
                                    )
                                  else if (isCompleted)
                                    Icon(
                                      Icons.check_circle,
                                      color: AppTheme.vcbGreen,
                                      size: 24,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InitTask {
  final String name;
  final IconData icon;

  InitTask(this.name, this.icon);
}

