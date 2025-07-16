import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../theme.dart';
import '../../services/security_service.dart';

class PinSetupScreen extends StatefulWidget {
  final bool isChanging;
  final VoidCallback? onSuccess;

  const PinSetupScreen({Key? key, this.isChanging = false, this.onSuccess})
    : super(key: key);

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen>
    with TickerProviderStateMixin {
  String _enteredPin = '';
  String _confirmPin = '';
  String _currentPin = '';
  bool _isConfirming = false;
  bool _isLoading = false;
  String? _errorMessage;

  late AnimationController _shakeController;
  late AnimationController _fadeController;
  late AnimationController _securityIconController;
  late AnimationController _progressController;
  late AnimationController _errorAnimationController;
  late Animation<double> _shakeAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _securityRotationAnimation;
  late Animation<double> _securityScaleAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _errorAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _securityIconController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _errorAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );

    _securityRotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi)
        .animate(
          CurvedAnimation(
            parent: _securityIconController,
            curve: Curves.linear,
          ),
        );

    _securityScaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _securityIconController, curve: Curves.easeInOut),
    );

    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _errorAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _errorAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _fadeController.forward();
    _securityIconController.repeat(reverse: true);
    _updateProgress();
  }

  void _updateProgress() {
    double progress = 0.0;
    if (widget.isChanging) {
      if (_currentPin.isNotEmpty) {
        progress = 0.33;
        if (_enteredPin.isNotEmpty) {
          progress = 0.66;
          if (_isConfirming) {
            progress = 1.0;
          }
        }
      }
    } else {
      if (_enteredPin.isNotEmpty) {
        progress = _isConfirming ? 1.0 : 0.5;
      }
    }

    _progressController.animateTo(progress);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _fadeController.dispose();
    _securityIconController.dispose();
    _progressController.dispose();
    _errorAnimationController.dispose();
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
              AppTheme.primaryGradient.colors.first,
              AppTheme.primaryGradient.colors.last,
              AppTheme.secondaryGradient.colors.first,
              AppTheme.secondaryGradient.colors.last,
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: CustomPaint(
          painter: _SecurityPatternPainter(),
          child: SafeArea(
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.translate(
                    offset: Offset(0, 50 * (1 - _fadeAnimation.value)),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 40),
                          _buildProgressIndicator(),
                          const Spacer(flex: 1),
                          _buildPinDisplay(),
                          const SizedBox(height: 60),
                          _buildNumberPad(),
                          const Spacer(flex: 2),
                          _buildActions(),
                        ],
                      ),
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

  Widget _buildHeader() {
    String title;
    String subtitle;
    IconData icon;

    if (widget.isChanging) {
      if (_currentPin.isEmpty) {
        title = 'Nhập PIN hiện tại';
        subtitle = 'Xác nhận PIN cũ để tiếp tục thay đổi';
        icon = Icons.verified_user_rounded;
      } else if (!_isConfirming) {
        title = 'Tạo PIN mới';
        subtitle = 'Tạo mã PIN 6 số mới để bảo vệ ứng dụng';
        icon = Icons.security_rounded;
      } else {
        title = 'Xác nhận PIN mới';
        subtitle = 'Nhập lại PIN mới để hoàn tất thay đổi';
        icon = Icons.check_circle_rounded;
      }
    } else {
      if (!_isConfirming) {
        title = 'Tạo PIN bảo mật';
        subtitle = 'Tạo mã PIN 6 số để bảo vệ ứng dụng của bạn';
        icon = Icons.security_rounded;
      } else {
        title = 'Xác nhận PIN';
        subtitle = 'Nhập lại PIN để hoàn tất thiết lập bảo mật';
        icon = Icons.check_circle_rounded;
      }
    }

    return Column(
      children: [
        Row(
          children: [
            if (widget.isChanging || _isConfirming)
              GestureDetector(
                onTap: _onBack,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              )
            else
              const SizedBox(width: 44),

            const Spacer(),

            // Security icon with animation
            AnimatedBuilder(
              animation: _securityIconController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _securityScaleAnimation.value,
                  child: Transform.rotate(
                    angle: _securityRotationAnimation.value * 0.05,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.3),
                            Colors.white.withValues(alpha: 0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.2),
                            blurRadius: 15,
                            spreadRadius: 3,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Center(
                            child: Icon(icon, color: Colors.white, size: 36),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            const Spacer(),
            const SizedBox(width: 44),
          ],
        ),

        const SizedBox(height: 32),

        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.2,
            shadows: [
              Shadow(
                color: Colors.black26,
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 16),

        Text(
          subtitle,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),

        if (_errorMessage != null) ...[
          const SizedBox(height: 24),
          AnimatedBuilder(
            animation: _errorAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _errorAnimation.value,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.red.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: double.infinity,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _progressAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.8),
                        Colors.white.withValues(alpha: 0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPinDisplay() {
    final currentPin = widget.isChanging && _currentPin.isEmpty
        ? _currentPin
        : (_isConfirming ? _confirmPin : _enteredPin);

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(6, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index < currentPin.length
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.3),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.5),
                          width: 2,
                        ),
                        boxShadow: index < currentPin.length
                            ? [
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNumberPad() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
          ),
          child: Column(
            children: [
              // Numbers 1-3
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNumberButton('1'),
                  _buildNumberButton('2'),
                  _buildNumberButton('3'),
                ],
              ),
              const SizedBox(height: 20),

              // Numbers 4-6
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNumberButton('4'),
                  _buildNumberButton('5'),
                  _buildNumberButton('6'),
                ],
              ),
              const SizedBox(height: 20),

              // Numbers 7-9
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNumberButton('7'),
                  _buildNumberButton('8'),
                  _buildNumberButton('9'),
                ],
              ),
              const SizedBox(height: 20),

              // 0 and Delete
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const SizedBox(width: 80),
                  _buildNumberButton('0'),
                  _buildDeleteButton(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberButton(String number) {
    return GestureDetector(
      onTap: () => _onNumberTap(number),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.25),
              Colors.white.withValues(alpha: 0.15),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(19),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return GestureDetector(
      onTap: _onDeleteTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.25),
              Colors.white.withValues(alpha: 0.15),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(19),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: const Center(
              child: Icon(
                Icons.backspace_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActions() {
    if (_isLoading) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: const Text(
              'Hủy',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onNumberTap(String number) {
    HapticFeedback.lightImpact();
    setState(() {
      _errorMessage = null;

      if (widget.isChanging && _currentPin.isEmpty) {
        if (_currentPin.length < 6) {
          _currentPin += number;
          if (_currentPin.length == 6) {
            _verifyCurrentPin();
          }
        }
      } else if (_isConfirming) {
        if (_confirmPin.length < 6) {
          _confirmPin += number;
          if (_confirmPin.length == 6) {
            _confirmPinSetup();
          }
        }
      } else {
        if (_enteredPin.length < 6) {
          _enteredPin += number;
          if (_enteredPin.length == 6) {
            setState(() {
              _isConfirming = true;
            });
            _updateProgress();
          }
        }
      }
    });
  }

  void _onDeleteTap() {
    HapticFeedback.lightImpact();
    setState(() {
      _errorMessage = null;

      if (widget.isChanging && _currentPin.isEmpty) {
        if (_currentPin.isNotEmpty) {
          _currentPin = _currentPin.substring(0, _currentPin.length - 1);
        }
      } else if (_isConfirming) {
        if (_confirmPin.isNotEmpty) {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        }
      } else {
        if (_enteredPin.isNotEmpty) {
          _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        }
      }
    });
  }

  void _onBack() {
    setState(() {
      if (_isConfirming) {
        _isConfirming = false;
        _confirmPin = '';
        _errorMessage = null;
        _updateProgress();
      } else if (widget.isChanging && _currentPin.isNotEmpty) {
        _currentPin = '';
        _enteredPin = '';
        _errorMessage = null;
        _updateProgress();
      } else {
        Navigator.of(context).pop();
      }
    });
  }

  Future<void> _verifyCurrentPin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final isValid = await SecurityService.verifyPin(_currentPin);
      if (isValid) {
        setState(() {
          _isLoading = false;
        });
        _updateProgress();
      } else {
        _showError('PIN hiện tại không đúng');
        _currentPin = '';
      }
    } catch (e) {
      _showError('Có lỗi xảy ra khi xác minh PIN');
      _currentPin = '';
    }
  }

  Future<void> _confirmPinSetup() async {
    if (_enteredPin != _confirmPin) {
      _showError('PIN không khớp. Vui lòng thử lại');
      setState(() {
        _isConfirming = false;
        _confirmPin = '';
        _enteredPin = '';
      });
      _updateProgress();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await SecurityService.setPin(_enteredPin);
      if (success) {
        // Success
        if (widget.onSuccess != null) {
          widget.onSuccess!();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isChanging
                  ? 'Đã thay đổi PIN thành công!'
                  : 'Đã thiết lập PIN thành công!',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );

        Navigator.of(context).pop(true);
      } else {
        _showError('Không thể thiết lập PIN. Vui lòng thử lại');
      }
    } catch (e) {
      _showError('Có lỗi xảy ra khi thiết lập PIN');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
      _isLoading = false;
    });

    _shakeController.forward().then((_) {
      _shakeController.reverse();
    });

    _errorAnimationController.forward().then((_) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          _errorAnimationController.reverse();
        }
      });
    });

    HapticFeedback.heavyImpact();
  }
}

class _SecurityPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw security pattern
    for (int i = 0; i < 8; i++) {
      final radius = size.width * 0.05 + i * 15;
      canvas.drawCircle(
        Offset(size.width * 0.15, size.height * 0.25),
        radius,
        paint,
      );
      canvas.drawCircle(
        Offset(size.width * 0.85, size.height * 0.75),
        radius,
        paint,
      );
    }

    // Draw shield pattern
    final shieldPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 15; i++) {
      final x = size.width * 0.1 + (i % 5) * size.width * 0.2;
      final y = size.height * 0.1 + (i ~/ 5) * size.height * 0.25;
      canvas.drawCircle(Offset(x, y), 6 + (i % 4) * 3, shieldPaint);
    }

    // Draw connecting lines
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (int i = 0; i < 10; i++) {
      canvas.drawLine(
        Offset(0, size.height * 0.1 * i),
        Offset(size.width, size.height * 0.1 * i),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

