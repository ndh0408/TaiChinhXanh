import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../theme.dart';
import 'initialization_screen.dart';

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
  late AnimationController _shimmerController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotateAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _shimmerAnimation;

  double _loadingProgress = 0.0;
  Timer? _progressTimer;
  List<String> _loadingMessages = [
    'Đang khởi động ứng dụng...',
    'Kiểm tra kết nối...',
    'Tải dữ liệu tài chính...',
    'Chuẩn bị giao diện...',
    'Hoàn tất!',
  ];
  int _currentMessageIndex = 0;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startLoadingSequence();
    _setSystemUIStyle();
  }

  void _setSystemUIStyle() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppTheme.vcbGreen,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  void _setupAnimations() {
    // Logo animations
    _logoController = AnimationController(
      duration: AppTheme.slowDuration,
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: AppTheme.bounceInCurve),
    );

    _logoRotateAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: AppTheme.smoothCurve),
    );

    // Text animations
    _textController = AnimationController(
      duration: AppTheme.normalDuration,
      vsync: this,
    );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: AppTheme.smoothCurve),
    );

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    ));

    // Progress animation
    _progressController = AnimationController(
      duration: AppTheme.normalDuration,
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: AppTheme.smoothCurve),
    );

    // Shimmer animation
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.linear),
    );

    // Start animations
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _textController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      _progressController.forward();
    });
  }

  void _startLoadingSequence() {
    _progressTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        _loadingProgress += 0.01;
        
        // Update message based on progress
        int newIndex = (_loadingProgress * 5).floor();
        if (newIndex != _currentMessageIndex && newIndex < _loadingMessages.length) {
          _currentMessageIndex = newIndex;
        }

        if (_loadingProgress >= 1.0) {
          _loadingProgress = 1.0;
          timer.cancel();
          _navigateToHome();
        }
      });
    });
  }

  void _navigateToHome() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const InitializationScreen(),
            transitionDuration: AppTheme.slowDuration,
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.02),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: AppTheme.smoothCurve,
                  )),
                  child: child,
                ),
              );
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.vcbGreen,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.vcbGreen,
              AppTheme.vcbDarkGreen,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                // Logo with animations
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoScaleAnimation.value,
                      child: Transform.rotate(
                        angle: _logoRotateAnimation.value * 0.1,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(35),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 30,
                                spreadRadius: 5,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // VCB style icon
                              Icon(
                                Icons.account_balance,
                                size: 70,
                                color: AppTheme.vcbGreen,
                              ),
                              // Shimmer effect
                              AnimatedBuilder(
                                animation: _shimmerAnimation,
                                builder: (context, child) {
                                  return Positioned.fill(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(35),
                                      child: ShaderMask(
                                        shaderCallback: (bounds) {
                                          return LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Colors.white.withOpacity(0),
                                              Colors.white.withOpacity(0.3),
                                              Colors.white.withOpacity(0),
                                            ],
                                            stops: [
                                              _shimmerAnimation.value - 0.3,
                                              _shimmerAnimation.value,
                                              _shimmerAnimation.value + 0.3,
                                            ],
                                          ).createShader(bounds);
                                        },
                                        child: Container(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
                // App name with animation
                SlideTransition(
                  position: _textSlideAnimation,
                  child: FadeTransition(
                    opacity: _textFadeAnimation,
                    child: Column(
                      children: [
                        Text(
                          'Tài Chính Xanh',
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Quản lý tài chính thông minh',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                                letterSpacing: 0.5,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(flex: 2),
                // Loading section
                FadeTransition(
                  opacity: _progressAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 60),
                    child: Column(
                      children: [
                        // Loading progress bar
                        Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: AnimatedBuilder(
                              animation: _progressController,
                              builder: (context, child) {
                                return LinearProgressIndicator(
                                  value: _loadingProgress,
                                  backgroundColor: Colors.transparent,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Loading message
                        AnimatedSwitcher(
                          duration: AppTheme.normalDuration,
                          child: Text(
                            _loadingMessages[_currentMessageIndex],
                            key: ValueKey(_currentMessageIndex),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                // Footer
                FadeTransition(
                  opacity: _textFadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: Column(
                      children: [
                        Text(
                          'Phiên bản 1.0.0',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white.withOpacity(0.6),
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Phát triển bởi Nguyễn Đức Huy',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white.withOpacity(0.6),
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
      ),
    );
  }
}

