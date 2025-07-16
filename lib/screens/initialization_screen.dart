import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/income_source_provider.dart';
import '../providers/ai_provider.dart';
import '../providers/bill_provider.dart';
import '../providers/budget_provider.dart';
import '../theme.dart';
import 'home_screen.dart';

class InitializationScreen extends StatefulWidget {
  const InitializationScreen({Key? key}) : super(key: key);

  @override
  State<InitializationScreen> createState() => _InitializationScreenState();
}

class _InitializationScreenState extends State<InitializationScreen>
    with TickerProviderStateMixin {
  bool _isInitialized = false;
  String _currentTask = '';
  double _progress = 0.0;
  int _currentStep = 0;

  late AnimationController _logoController;
  late AnimationController _progressController;
  late AnimationController _floatingController;
  late AnimationController _particleController;
  late AnimationController _titleController;
  late AnimationController _fadeController;

  late Animation<double> _logoAnimation;
  late Animation<double> _logoRotationAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _floatingAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _titleAnimation;
  late Animation<double> _fadeAnimation;

  final List<String> _steps = [
    'Khởi tạo ứng dụng...',
    'Đang tải giao dịch...',
    'Đang tải nguồn thu nhập...',
    'Đang tải hóa đơn...',
    'Đang tải ngân sách...',
    'Đang khởi tạo AI...',
    'Đang tạo dữ liệu mẫu...',
    'Hoàn tất khởi tạo...',
    'Hoàn thành!',
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimationSequence();
    _initializeApp();
  }

  void _setupAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 5000),
      vsync: this,
    );

    _titleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoRotationAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi)
        .animate(
          CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
        );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );

    _floatingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.linear),
    );

    _titleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));
  }

  void _startAnimationSequence() {
    _fadeController.forward();

    Future.delayed(const Duration(milliseconds: 300), () {
      _logoController.forward();
      _floatingController.repeat(reverse: true);
      _particleController.repeat();
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      _titleController.forward();
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _progressController.dispose();
    _floatingController.dispose();
    _particleController.dispose();
    _titleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    final transactionProvider = Provider.of<TransactionProvider>(
      context,
      listen: false,
    );
    final incomeSourceProvider = Provider.of<IncomeSourceProvider>(
      context,
      listen: false,
    );
    final aiProvider = Provider.of<AIProvider>(context, listen: false);
    final billProvider = Provider.of<BillProvider>(context, listen: false);
    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);

    try {
      // Initialize transaction provider
      await _updateProgress('Đang tải giao dịch...', 1, 0.15);
      await transactionProvider.initialize();

      // Initialize income source provider
      await _updateProgress('Đang tải nguồn thu nhập...', 2, 0.3);
      await incomeSourceProvider.initialize();

      // Initialize bill provider
      await _updateProgress('Đang tải hóa đơn...', 3, 0.45);
      await billProvider.initialize();

      // Initialize budget provider
      await _updateProgress('Đang tải ngân sách...', 4, 0.6);
      await budgetProvider.initialize();

      // Initialize AI provider
      await _updateProgress('Đang khởi tạo AI...', 5, 0.75);
      await aiProvider.initialize();

      // Add sample data if empty
      await _updateProgress('Đang tạo dữ liệu mẫu...', 6, 0.85);
      await _generateSampleDataIfNeeded(
        transactionProvider,
        incomeSourceProvider,
        aiProvider,
        billProvider,
      );

      // Final setup
      await _updateProgress('Hoàn tất khởi tạo...', 7, 0.95);

      // Add small delay for smooth transition
      await Future.delayed(const Duration(milliseconds: 800));

      await _updateProgress('Hoàn thành!', 8, 1.0);

      // Add completion animation
      setState(() {
        _isInitialized = true;
      });

      HapticFeedback.mediumImpact();

      // Navigate to dashboard
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const HomeScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _currentTask = 'Lỗi khởi tạo ứng dụng: $e';
      });
    }
  }

  Future<void> _updateProgress(String task, int step, double progress) async {
    setState(() {
      _currentTask = task;
      _currentStep = step;
      _progress = progress;
    });

    _progressController.reset();
    _progressController.forward();

    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 1200));
  }

  Future<void> _generateSampleDataIfNeeded(
    TransactionProvider transactionProvider,
    IncomeSourceProvider incomeSourceProvider,
    AIProvider aiProvider,
    BillProvider billProvider,
  ) async {
    // Just load existing data - sample data generation will be handled elsewhere
    // This is a simpler approach for initialization
    await transactionProvider.loadTransactions();
    await incomeSourceProvider.loadIncomeSources();
    await aiProvider.loadSuggestions();
    await billProvider.loadBills();
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
              AppTheme.primaryGradient.colors.first,
              AppTheme.primaryGradient.colors.last,
              AppTheme.secondaryGradient.colors.first,
              AppTheme.secondaryGradient.colors.last,
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: CustomPaint(
          painter: _InitializationPatternPainter(_particleAnimation),
          child: SafeArea(
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(flex: 2),
                        _buildLogo(),
                        const SizedBox(height: 60),
                        _buildTitle(),
                        const Spacer(flex: 2),
                        _buildProgressSection(),
                        const SizedBox(height: 80),
                        _buildFooter(),
                        const Spacer(flex: 1),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: Listenable.merge([_logoAnimation, _floatingAnimation]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -15 * _floatingAnimation.value),
          child: Transform.scale(
            scale: _logoAnimation.value,
            child: Transform.rotate(
              angle: _logoRotationAnimation.value * 0.1,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.8),
                      Colors.white.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.8),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.8),
                      blurRadius: 30,
                      spreadRadius: 8,
                      offset: const Offset(0, 12),
                    ),
                    BoxShadow(
                      color: AppTheme.primaryGradient.colors.first.withValues(alpha: 
                        0.4,
                      ),
                      blurRadius: 20,
                      spreadRadius: 4,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(37),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.8),
                            Colors.white.withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.account_balance_wallet_rounded,
                          size: 70,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitle() {
    return AnimatedBuilder(
      animation: _titleAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _titleAnimation.value)),
          child: Opacity(
            opacity: _titleAnimation.value,
            child: Column(
              children: [
                Text(
                  'Tài Chính Thông Minh',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.8),
                        offset: const Offset(0, 3),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.8),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Quản lý tài chính với công nghệ AI',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressSection() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.8),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              // Progress steps
              _buildProgressSteps(),
              const SizedBox(height: 32),

              // Progress bar
              _buildProgressBar(),
              const SizedBox(height: 24),

              // Current task
              _buildCurrentTask(),
              const SizedBox(height: 32),

              // Loading indicator
              _buildLoadingIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSteps() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(5, (index) {
        final isActive = index <= (_currentStep / 2).floor();
        final isCompleted = index < (_currentStep / 2).floor();

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? Colors.green.shade400
                : isActive
                ? Colors.white
                : Colors.white.withValues(alpha: 0.8),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.8),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: isCompleted
              ? const Icon(Icons.check, size: 8, color: Colors.white)
              : null,
        );
      }),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tiến trình',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(_progress * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _progress * _progressAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white, Colors.white.withValues(alpha: 0.8)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.8),
                          blurRadius: 12,
                          spreadRadius: 2,
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
    );
  }

  Widget _buildCurrentTask() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 1),
      ),
      child: Text(
        _currentTask.isEmpty ? 'Đang khởi tạo...' : _currentTask,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: _isInitialized
          ? Container(
              key: const ValueKey('completed'),
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade400, Colors.green.shade600],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.8),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 32,
              ),
            )
          : Container(
              key: const ValueKey('loading'),
              width: 60,
              height: 60,
              child: Stack(
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      value: _progress,
                      backgroundColor: Colors.white.withValues(alpha: 0.8),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white60),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'Powered by AI Technology',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Secure & Smart Finance Management',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.8),
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _InitializationPatternPainter extends CustomPainter {
  final Animation<double> animation;

  _InitializationPatternPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw animated circles
    for (int i = 0; i < 12; i++) {
      final progress = (animation.value + i * 0.1) % 1.0;
      final radius = size.width * 0.05 + progress * 80;
      final opacity = 1.0 - progress;

      paint.color = Colors.white.withValues(alpha: opacity * 0.1);

      canvas.drawCircle(
        Offset(size.width * 0.2, size.height * 0.3),
        radius,
        paint,
      );
      canvas.drawCircle(
        Offset(size.width * 0.8, size.height * 0.7),
        radius,
        paint,
      );
    }

    // Draw floating particles
    final particlePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 20; i++) {
      final progress = (animation.value * 0.5 + i * 0.05) % 1.0;
      final x = size.width * 0.1 + (i % 4) * size.width * 0.25;
      final y = size.height * 0.1 + progress * size.height * 0.8;
      final radius = 3.0 + (i % 3) * 2.0;

      canvas.drawCircle(Offset(x, y), radius, particlePaint);
    }

    // Draw connecting lines
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (int i = 0; i < 8; i++) {
      final progress = (animation.value + i * 0.125) % 1.0;
      final startX = size.width * progress;
      final endX = size.width * (1 - progress);
      final y = size.height * 0.2 + i * size.height * 0.1;

      canvas.drawLine(Offset(startX, y), Offset(endX, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

