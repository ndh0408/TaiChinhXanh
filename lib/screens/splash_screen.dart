import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../providers/transaction_provider.dart';
import '../providers/income_source_provider.dart';
import '../providers/ai_provider.dart';
import '../providers/bill_provider.dart';
import '../providers/budget_provider.dart';
import '../providers/theme_provider.dart';
import '../theme.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;
  late AnimationController _particleController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _textSlideAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _particleAnimation;

  bool _isInitialized = false;
  String _currentTask = 'Đang khởi tạo ứng dụng...';
  double _progress = 0.0;

  List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeParticles();
    _initializeApp();
  }

  void _setupAnimations() {
    // Logo Animation
    _logoController = AnimationController(
      duration: AppTheme.extraSlowDuration,
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: AppTheme.bounceInCurve),
    );

    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: AppTheme.smoothCurve),
    );

    // Text Animation
    _textController = AnimationController(
      duration: AppTheme.slowDuration,
      vsync: this,
    );

    _textSlideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _textController, curve: AppTheme.quickCurve),
    );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: AppTheme.smoothCurve),
    );

    // Progress Animation
    _progressController = AnimationController(
      duration: AppTheme.normalDuration,
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: AppTheme.smoothCurve),
    );

    // Particle Animation
    _particleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_particleController);

    // Start animations
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _textController.forward();
    });
  }

  void _initializeParticles() {
    _particles = List.generate(15, (index) => Particle());
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    _particleController.dispose();
    super.dispose();
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

    final tasks = [
      'Đang tải cấu hình giao diện...',
      'Đang tải giao dịch...',
      'Đang tải nguồn thu nhập...',
      'Đang khởi tạo AI thông minh...',
      'Đang tải hóa đơn...',
      'Đang tải ngân sách...',
      'Đang hoàn tất thiết lập...',
    ];

    for (int i = 0; i < tasks.length; i++) {
      if (!mounted) return;

      setState(() {
        _currentTask = tasks[i];
        _progress = (i + 1) / tasks.length;
      });

      _progressController.forward();

      // Initialize providers
      if (i == 0) {
        await (providers[0] as ThemeProvider).initialize();
      } else if (i == 1) {
        await (providers[1] as TransactionProvider).initialize();
      } else if (i == 2) {
        await (providers[2] as IncomeSourceProvider).initialize();
      } else if (i == 3) {
        await (providers[3] as AIProvider).initialize();
      } else if (i == 4) {
        await (providers[4] as BillProvider).initialize();
      } else if (i == 5) {
        await (providers[5] as BudgetProvider).initialize();
      }

      await Future.delayed(const Duration(milliseconds: 600));
      _progressController.reset();
    }

    setState(() {
      _isInitialized = true;
      _currentTask = 'Hoàn thành! 🎉';
    });

    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: AppTheme.smoothCurve,
              ),
              child: child,
            );
          },
          transitionDuration: AppTheme.slowDuration,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        child: Stack(
          children: [
            // Animated Particles Background
            AnimatedBuilder(
              animation: _particleAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: ParticlePainter(
                    _particles,
                    _particleAnimation.value,
                  ),
                  size: screenSize,
                );
              },
            ),

            // Main Content
            SafeArea(
              child: Padding(
                padding: EdgeInsets.all(AppTheme.spacing8),
                child: Column(
                  children: [
                    const Spacer(flex: 2),

                    // Logo Section
                    AnimatedBuilder(
                      animation: _logoController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _logoScaleAnimation.value,
                          child: Opacity(
                            opacity: _logoFadeAnimation.value,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: AppTheme.glassMorphism(
                                color: AppTheme.white.withValues(alpha: 0.2),
                                borderRadius: AppTheme.radius2XL,
                              ),
                              child: const Icon(
                                Icons.account_balance_wallet_rounded,
                                size: 60,
                                color: AppTheme.white,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: AppTheme.spacing8),

                    // App Title & Subtitle
                    AnimatedBuilder(
                      animation: _textController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _textSlideAnimation.value),
                          child: Opacity(
                            opacity: _textFadeAnimation.value,
                            child: Column(
                              children: [
                                Text(
                                  'Quản Lý Tài Chính',
                                  style: AppTheme.displayMedium.copyWith(
                                    color: AppTheme.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: AppTheme.spacing2),
                                Text(
                                  'Thông Minh & Hiện Đại',
                                  style: AppTheme.headlineSmall.copyWith(
                                    color: AppTheme.white.withValues(alpha: 0.9),
                                    fontWeight: FontWeight.w400,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const Spacer(flex: 3),

                    // Progress Section
                    Column(
                      children: [
                        // Progress Text
                        AnimatedSwitcher(
                          duration: AppTheme.normalDuration,
                          child: Text(
                            _currentTask,
                            key: ValueKey(_currentTask),
                            style: AppTheme.titleMedium.copyWith(
                              color: AppTheme.white.withValues(alpha: 0.9),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        SizedBox(height: AppTheme.spacing6),

                        // Progress Bar
                        Container(
                          width: double.infinity,
                          height: 6,
                          decoration: BoxDecoration(
                            color: AppTheme.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusFull,
                            ),
                          ),
                          child: Stack(
                            children: [
                              AnimatedContainer(
                                duration: AppTheme.normalDuration,
                                width: screenSize.width * _progress,
                                height: 6,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppTheme.white,
                                      AppTheme.accentStart,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radiusFull,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.white.withValues(alpha: 0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),

                              // Progress Glow Effect
                              if (_progress > 0)
                                AnimatedBuilder(
                                  animation: _progressAnimation,
                                  builder: (context, child) {
                                    return Positioned(
                                      left: (screenSize.width * _progress) - 10,
                                      child: Container(
                                        width: 20,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: AppTheme.white.withValues(alpha: 
                                            0.6 * _progressAnimation.value,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            AppTheme.radiusFull,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),

                        SizedBox(height: AppTheme.spacing4),

                        // Progress Percentage
                        Text(
                          '${(_progress * 100).toInt()}%',
                          style: AppTheme.titleSmall.copyWith(
                            color: AppTheme.white.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: AppTheme.spacing12),

                    // Bottom Text
                    Text(
                      'Designed with ❤️',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.white.withValues(alpha: 0.7),
                      ),
                    ),

                    SizedBox(height: AppTheme.spacing4),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Particle class for animated background
class Particle {
  late double x;
  late double y;
  late double size;
  late double speedX;
  late double speedY;
  late double opacity;

  Particle() {
    _reset();
  }

  void _reset() {
    x = Random().nextDouble();
    y = Random().nextDouble();
    size = Random().nextDouble() * 4 + 1;
    speedX = (Random().nextDouble() - 0.5) * 0.02;
    speedY = (Random().nextDouble() - 0.5) * 0.02;
    opacity = Random().nextDouble() * 0.6 + 0.2;
  }

  void update() {
    x += speedX;
    y += speedY;

    if (x < -0.1 || x > 1.1 || y < -0.1 || y > 1.1) {
      _reset();
    }
  }
}

// Custom painter for particle animation
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;

  ParticlePainter(this.particles, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    for (var particle in particles) {
      particle.update();

      final x = particle.x * size.width;
      final y = particle.y * size.height;

      paint.color = AppTheme.white.withValues(alpha: particle.opacity * 0.5);
      canvas.drawCircle(Offset(x, y), particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

