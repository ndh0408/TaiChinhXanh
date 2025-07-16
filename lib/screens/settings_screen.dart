import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../theme.dart';
import '../providers/theme_provider.dart';
import '../services/security_service.dart';
import 'auth/pin_setup_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _sectionsController;

  late Animation<double> _headerSlideAnimation;
  late Animation<double> _headerFadeAnimation;
  late Animation<double> _sectionsSlideAnimation;
  late Animation<double> _sectionsFadeAnimation;

  bool _pinEnabled = false;
  bool _biometricEnabled = false;
  bool _notificationsEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadSecuritySettings();
  }

  void _setupAnimations() {
    _headerController = AnimationController(
      duration: AppTheme.slowDuration,
      vsync: this,
    );

    _sectionsController = AnimationController(
      duration: AppTheme.extraSlowDuration,
      vsync: this,
    );

    _headerSlideAnimation = Tween<double>(begin: -30.0, end: 0.0).animate(
      CurvedAnimation(parent: _headerController, curve: AppTheme.smoothCurve),
    );

    _headerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: AppTheme.smoothCurve),
    );

    _sectionsSlideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _sectionsController, curve: AppTheme.quickCurve),
    );

    _sectionsFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sectionsController, curve: AppTheme.smoothCurve),
    );

    // Start animations
    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _sectionsController.forward();
    });
  }

  Future<void> _loadSecuritySettings() async {
    try {
      final pinEnabled = await SecurityService.hasPinSet();
      final biometricAvailable = await SecurityService.isBiometricAvailable();

      setState(() {
        _pinEnabled = pinEnabled;
        _biometricEnabled = biometricAvailable && pinEnabled;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _headerController.dispose();
    _sectionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
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

                // Settings Content
                SliverPadding(
                  padding: EdgeInsets.all(AppTheme.spacing4),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      if (_isLoading)
                        _buildLoadingSection()
                      else ...[
                        // User Profile Section
                        _buildUserProfileSection(),

                        SizedBox(height: AppTheme.spacing6),

                        // Theme Section
                        _buildThemeSection(themeProvider),

                        SizedBox(height: AppTheme.spacing6),

                        // Security Section
                        _buildSecuritySection(),

                        SizedBox(height: AppTheme.spacing6),

                        // Notifications Section
                        _buildNotificationsSection(),

                        SizedBox(height: AppTheme.spacing6),

                        // Data & Privacy Section
                        _buildDataPrivacySection(),

                        SizedBox(height: AppTheme.spacing6),

                        // About Section
                        _buildAboutSection(),

                        SizedBox(height: AppTheme.spacing20),
                      ],
                    ]),
                  ),
                ),
              ],
            ),
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
          decoration: const BoxDecoration(gradient: AppTheme.secondaryGradient),
          child: Stack(
            children: [
              // Background Pattern
              Positioned.fill(
                child: CustomPaint(painter: SettingsPatternPainter()),
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
                                      color: AppTheme.white.withValues(
                                        alpha: 0.9,
                                      ),
                                      borderRadius: AppTheme.radiusLG,
                                    ),
                                    child: const Icon(
                                      Icons.settings_rounded,
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
                                          'Cài đặt',
                                          style: AppTheme.displaySmall.copyWith(
                                            color: AppTheme.white,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        Text(
                                          'Tùy chỉnh ứng dụng theo ý bạn',
                                          style: AppTheme.bodyLarge.copyWith(
                                            color: AppTheme.white.withValues(
                                              alpha: 0.9,
                                            ),
                                          ),
                                        ),
                                      ],
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

  Widget _buildLoadingSection() {
    return Container(
      height: 200,
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildUserProfileSection() {
    return AnimatedBuilder(
      animation: _sectionsController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _sectionsSlideAnimation.value),
          child: Opacity(
            opacity: _sectionsFadeAnimation.value,
            child: Container(
              decoration: AppTheme.glassMorphism(
                color: Theme.of(
                  context,
                ).colorScheme.surface.withValues(alpha: 0.9),
              ),
              child: Padding(
                padding: EdgeInsets.all(AppTheme.spacing6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '👤 Hồ sơ cá nhân',
                      style: AppTheme.headlineSmall.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacing4),
                    Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusFull,
                            ),
                            boxShadow: AppTheme.lightShadow,
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: AppTheme.white,
                            size: AppTheme.icon2XL,
                          ),
                        ),
                        SizedBox(width: AppTheme.spacing4),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Người dùng',
                                style: AppTheme.headlineSmall.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: AppTheme.spacing1),
                              Text(
                                'Quản lý tài chính thông minh',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: AppTheme.gray600,
                                ),
                              ),
                              SizedBox(height: AppTheme.spacing3),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppTheme.spacing3,
                                  vertical: AppTheme.spacing1,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.successStart.withValues(
                                    alpha: 0.9,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radiusFull,
                                  ),
                                  border: Border.all(
                                    color: AppTheme.successStart.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Đã xác thực',
                                  style: AppTheme.labelSmall.copyWith(
                                    color: AppTheme.successStart,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeSection(ThemeProvider themeProvider) {
    return AnimatedBuilder(
      animation: _sectionsController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _sectionsSlideAnimation.value * 0.8),
          child: Opacity(
            opacity: _sectionsFadeAnimation.value,
            child: Container(
              decoration: AppTheme.glassMorphism(
                color: Theme.of(
                  context,
                ).colorScheme.surface.withValues(alpha: 0.9),
              ),
              child: Padding(
                padding: EdgeInsets.all(AppTheme.spacing6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🎨 Giao diện',
                      style: AppTheme.headlineSmall.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacing4),
                    Row(
                      children: AppThemeMode.values.map((mode) {
                        final isSelected = themeProvider.themeMode == mode;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              themeProvider.setThemeMode(mode);
                            },
                            child: AnimatedContainer(
                              duration: AppTheme.normalDuration,
                              margin: EdgeInsets.symmetric(
                                horizontal: AppTheme.spacing1,
                              ),
                              padding: EdgeInsets.all(AppTheme.spacing4),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? AppTheme.primaryGradient
                                    : null,
                                color: isSelected ? null : AppTheme.gray100,
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusLG,
                                ),
                                boxShadow: isSelected
                                    ? AppTheme.lightShadow
                                    : null,
                                border: !isSelected
                                    ? Border.all(
                                        color: AppTheme.gray300,
                                        width: 1,
                                      )
                                    : null,
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    _getThemeIcon(mode),
                                    color: isSelected
                                        ? AppTheme.white
                                        : AppTheme.gray600,
                                    size: AppTheme.iconLG,
                                  ),
                                  SizedBox(height: AppTheme.spacing2),
                                  Text(
                                    _getThemeLabel(mode),
                                    style: AppTheme.labelMedium.copyWith(
                                      color: isSelected
                                          ? AppTheme.white
                                          : AppTheme.gray600,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSecuritySection() {
    return AnimatedBuilder(
      animation: _sectionsController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _sectionsSlideAnimation.value * 0.6),
          child: Opacity(
            opacity: _sectionsFadeAnimation.value,
            child: Container(
              decoration: AppTheme.glassMorphism(
                color: Theme.of(
                  context,
                ).colorScheme.surface.withValues(alpha: 0.9),
              ),
              child: Padding(
                padding: EdgeInsets.all(AppTheme.spacing6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🔒 Bảo mật',
                      style: AppTheme.headlineSmall.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacing4),

                    // PIN Setting
                    _buildSettingTile(
                      icon: Icons.lock_outline_rounded,
                      title: 'Mã PIN',
                      subtitle: _pinEnabled ? 'Đã bật' : 'Chưa thiết lập',
                      trailing: Switch(
                        value: _pinEnabled,
                        onChanged: (value) => _handlePinToggle(value),
                        activeColor: AppTheme.primaryColor,
                      ),
                      onTap: () => _handlePinToggle(!_pinEnabled),
                    ),

                    if (_pinEnabled) ...[
                      SizedBox(height: AppTheme.spacing3),

                      // Biometric Setting
                      _buildSettingTile(
                        icon: Icons.fingerprint_rounded,
                        title: 'Sinh trắc học',
                        subtitle: _biometricEnabled ? 'Đã bật' : 'Chưa bật',
                        trailing: Switch(
                          value: _biometricEnabled,
                          onChanged: (value) => _handleBiometricToggle(value),
                          activeColor: AppTheme.primaryColor,
                        ),
                        onTap: () => _handleBiometricToggle(!_biometricEnabled),
                      ),
                    ],

                    SizedBox(height: AppTheme.spacing3),

                    // Change PIN
                    _buildSettingTile(
                      icon: Icons.key_rounded,
                      title: 'Đổi mã PIN',
                      subtitle: 'Cập nhật mã PIN của bạn',
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        color: AppTheme.gray400,
                      ),
                      onTap: _showChangePinDialog,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationsSection() {
    return AnimatedBuilder(
      animation: _sectionsController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _sectionsSlideAnimation.value * 0.4),
          child: Opacity(
            opacity: _sectionsFadeAnimation.value,
            child: Container(
              decoration: AppTheme.glassMorphism(
                color: Theme.of(
                  context,
                ).colorScheme.surface.withValues(alpha: 0.9),
              ),
              child: Padding(
                padding: EdgeInsets.all(AppTheme.spacing6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🔔 Thông báo',
                      style: AppTheme.headlineSmall.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacing4),

                    _buildSettingTile(
                      icon: Icons.notifications_outlined,
                      title: 'Thông báo chung',
                      subtitle: 'Nhận thông báo về giao dịch',
                      trailing: Switch(
                        value: _notificationsEnabled,
                        onChanged: (value) {
                          setState(() {
                            _notificationsEnabled = value;
                          });
                        },
                        activeColor: AppTheme.primaryColor,
                      ),
                      onTap: () {
                        setState(() {
                          _notificationsEnabled = !_notificationsEnabled;
                        });
                      },
                    ),

                    SizedBox(height: AppTheme.spacing3),

                    _buildSettingTile(
                      icon: Icons.schedule_rounded,
                      title: 'Nhắc nhở hóa đơn',
                      subtitle: 'Nhắc nhở khi hóa đơn sắp đến hạn',
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        color: AppTheme.gray400,
                      ),
                      onTap: () {
                        // TODO: Navigate to bill reminders settings
                      },
                    ),

                    SizedBox(height: AppTheme.spacing3),

                    _buildSettingTile(
                      icon: Icons.insights_rounded,
                      title: 'Báo cáo tài chính',
                      subtitle: 'Báo cáo hàng tuần và hàng tháng',
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        color: AppTheme.gray400,
                      ),
                      onTap: () {
                        // TODO: Navigate to financial reports settings
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDataPrivacySection() {
    return AnimatedBuilder(
      animation: _sectionsController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _sectionsSlideAnimation.value * 0.2),
          child: Opacity(
            opacity: _sectionsFadeAnimation.value,
            child: Container(
              decoration: AppTheme.glassMorphism(
                color: Theme.of(
                  context,
                ).colorScheme.surface.withValues(alpha: 0.9),
              ),
              child: Padding(
                padding: EdgeInsets.all(AppTheme.spacing6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🛡️ Dữ liệu & Quyền riêng tư',
                      style: AppTheme.headlineSmall.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacing4),

                    _buildSettingTile(
                      icon: Icons.backup_rounded,
                      title: 'Sao lưu dữ liệu',
                      subtitle: 'Xuất và sao lưu dữ liệu của bạn',
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        color: AppTheme.gray400,
                      ),
                      onTap: _showBackupDialog,
                    ),

                    SizedBox(height: AppTheme.spacing3),

                    _buildSettingTile(
                      icon: Icons.restore_rounded,
                      title: 'Khôi phục dữ liệu',
                      subtitle: 'Khôi phục từ file sao lưu',
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        color: AppTheme.gray400,
                      ),
                      onTap: _showRestoreDialog,
                    ),

                    SizedBox(height: AppTheme.spacing3),

                    _buildSettingTile(
                      icon: Icons.delete_forever_rounded,
                      title: 'Xóa tất cả dữ liệu',
                      subtitle: 'Xóa vĩnh viễn tất cả dữ liệu',
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        color: AppTheme.errorStart,
                      ),
                      onTap: _showDeleteAllDataDialog,
                      isDestructive: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAboutSection() {
    return AnimatedBuilder(
      animation: _sectionsController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _sectionsSlideAnimation.value * 0.1),
          child: Opacity(
            opacity: _sectionsFadeAnimation.value,
            child: Container(
              decoration: AppTheme.glassMorphism(
                color: Theme.of(
                  context,
                ).colorScheme.surface.withValues(alpha: 0.9),
              ),
              child: Padding(
                padding: EdgeInsets.all(AppTheme.spacing6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ℹ️ Về ứng dụng',
                      style: AppTheme.headlineSmall.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacing4),

                    _buildSettingTile(
                      icon: Icons.info_outline_rounded,
                      title: 'Phiên bản',
                      subtitle: '1.0.0 (Build 100)',
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        color: AppTheme.gray400,
                      ),
                      onTap: _showVersionDialog,
                    ),

                    SizedBox(height: AppTheme.spacing3),

                    _buildSettingTile(
                      icon: Icons.help_outline_rounded,
                      title: 'Trợ giúp & Hỗ trợ',
                      subtitle: 'Câu hỏi thường gặp và hỗ trợ',
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        color: AppTheme.gray400,
                      ),
                      onTap: () {
                        // TODO: Navigate to help & support
                      },
                    ),

                    SizedBox(height: AppTheme.spacing3),

                    _buildSettingTile(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Chính sách bảo mật',
                      subtitle: 'Điều khoản và chính sách',
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        color: AppTheme.gray400,
                      ),
                      onTap: () {
                        // TODO: Navigate to privacy policy
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.all(AppTheme.spacing4),
        decoration: BoxDecoration(
          color: isDestructive
              ? AppTheme.errorStart.withValues(alpha: 0.9)
              : AppTheme.gray50,
          borderRadius: BorderRadius.circular(AppTheme.radiusLG),
          border: Border.all(
            color: isDestructive
                ? AppTheme.errorStart.withValues(alpha: 0.9)
                : AppTheme.gray200,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppTheme.spacing2),
              decoration: BoxDecoration(
                color: isDestructive
                    ? AppTheme.errorStart.withValues(alpha: 0.9)
                    : AppTheme.primaryColor.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(AppTheme.radiusSM),
              ),
              child: Icon(
                icon,
                color: isDestructive
                    ? AppTheme.errorStart
                    : AppTheme.primaryColor,
                size: AppTheme.iconMD,
              ),
            ),
            SizedBox(width: AppTheme.spacing3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDestructive ? AppTheme.errorStart : null,
                    ),
                  ),
                  SizedBox(height: AppTheme.spacing1),
                  Text(
                    subtitle,
                    style: AppTheme.bodySmall.copyWith(color: AppTheme.gray600),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  IconData _getThemeIcon(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return Icons.light_mode_rounded;
      case AppThemeMode.dark:
        return Icons.dark_mode_rounded;
      case AppThemeMode.system:
        return Icons.settings_system_daydream_rounded;
    }
  }

  String _getThemeLabel(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'Sáng';
      case AppThemeMode.dark:
        return 'Tối';
      case AppThemeMode.system:
        return 'Hệ thống';
    }
  }

  void _handlePinToggle(bool value) async {
    if (value) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PinSetupScreen()),
      ).then((_) => _loadSecuritySettings());
    } else {
      _showDisablePinDialog();
    }
  }

  void _handleBiometricToggle(bool value) async {
    try {
      if (value) {
        final available = await SecurityService.isBiometricAvailable();
        if (available) {
          await SecurityService.setBiometricEnabled(true);
          setState(() {
            _biometricEnabled = true;
          });
          _showSuccessSnackBar('Đã bật sinh trắc học');
        } else {
          _showErrorSnackBar('Thiết bị không hỗ trợ sinh trắc học');
        }
      } else {
        await SecurityService.setBiometricEnabled(false);
        setState(() {
          _biometricEnabled = false;
        });
        _showSuccessSnackBar('Đã tắt sinh trắc học');
      }
    } catch (e) {
      _showErrorSnackBar('Có lỗi xảy ra: $e');
    }
  }

  void _showDisablePinDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tắt mã PIN'),
        content: const Text(
          'Bạn có chắc chắn muốn tắt mã PIN? Điều này sẽ giảm bảo mật cho ứng dụng.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await SecurityService.removePin();
              setState(() {
                _pinEnabled = false;
                _biometricEnabled = false;
              });
              _showSuccessSnackBar('Đã tắt mã PIN');
            },
            child: Text('Tắt', style: TextStyle(color: AppTheme.errorStart)),
          ),
        ],
      ),
    );
  }

  void _showChangePinDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PinSetupScreen(isChanging: true),
      ),
    ).then((_) => _loadSecuritySettings());
  }

  void _showBackupDialog() {
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
                'Sao lưu dữ liệu',
                style: AppTheme.headlineSmall.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),

              SizedBox(height: AppTheme.spacing4),

              Text(
                'Tạo file sao lưu chứa tất cả dữ liệu giao dịch, ngân sách và cài đặt của bạn.',
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.gray600),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: AppTheme.spacing6),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Hủy'),
                    ),
                  ),
                  SizedBox(width: AppTheme.spacing4),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _performBackup();
                      },
                      child: const Text('Sao lưu'),
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

  void _showRestoreDialog() {
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
                'Khôi phục dữ liệu',
                style: AppTheme.headlineSmall.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),

              SizedBox(height: AppTheme.spacing4),

              Text(
                'Khôi phục dữ liệu từ file sao lưu. Tất cả dữ liệu hiện tại sẽ bị thay thế.',
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.gray600),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: AppTheme.spacing6),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Hủy'),
                    ),
                  ),
                  SizedBox(width: AppTheme.spacing4),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _performRestore();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.warningStart,
                      ),
                      child: const Text('Khôi phục'),
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

  void _showDeleteAllDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Xóa tất cả dữ liệu',
          style: TextStyle(color: AppTheme.errorStart),
        ),
        content: const Text(
          'Bạn có chắc chắn muốn xóa TẤT CẢ dữ liệu? Hành động này KHÔNG THỂ hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performDeleteAllData();
            },
            child: Text('Xóa', style: TextStyle(color: AppTheme.errorStart)),
          ),
        ],
      ),
    );
  }

  void _showVersionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thông tin phiên bản'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phiên bản: 1.0.0'),
            Text('Build: 100'),
            Text('Ngày phát hành: ${DateTime.now().toString().split(' ')[0]}'),
            SizedBox(height: AppTheme.spacing4),
            Text(
              'Ứng dụng quản lý tài chính thông minh với AI.',
              style: AppTheme.bodySmall.copyWith(color: AppTheme.gray600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _performBackup() {
    // TODO: Implement backup functionality
    _showSuccessSnackBar('Tính năng sao lưu sẽ được triển khai sớm');
  }

  void _performRestore() {
    // TODO: Implement restore functionality
    _showSuccessSnackBar('Tính năng khôi phục sẽ được triển khai sớm');
  }

  void _performDeleteAllData() {
    // TODO: Implement delete all data functionality
    _showSuccessSnackBar('Tính năng xóa dữ liệu sẽ được triển khai sớm');
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successStart,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorStart,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        ),
      ),
    );
  }
}

// Custom painter for settings background pattern
class SettingsPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw gear-like pattern
    const centerX = 0.0;
    const centerY = 0.0;
    const radius = 100.0;
    const teeth = 12;

    for (int i = 0; i < teeth; i++) {
      final angle = (i * 2 * pi) / teeth;
      final x1 = centerX + cos(angle) * radius;
      final y1 = centerY + sin(angle) * radius;
      final x2 = centerX + cos(angle) * (radius + 20);
      final y2 = centerY + sin(angle) * (radius + 20);

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }

    // Draw scattered dots
    final dotPaint = Paint()
      ..color = AppTheme.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;

    final random = Random(42);
    for (int i = 0; i < 20; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 8 + 2;

      canvas.drawCircle(Offset(x, y), radius, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
