import 'package:flutter/material.dart';
import '../theme.dart';

enum AppButtonType { primary, secondary, outline, text, floating, icon, card }

enum AppButtonSize { small, medium, large, extraLarge }

class AppButton extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final AppButtonSize size;
  final bool isLoading;
  final bool isExpanded;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Widget? child;

  const AppButton({
    Key? key,
    this.text,
    this.icon,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isExpanded = false,
    this.backgroundColor,
    this.textColor,
    this.padding,
    this.borderRadius,
    this.child,
  }) : super(key: key);

  // Factory constructors cho các loại button phổ biến
  factory AppButton.primary({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    IconData? icon,
    AppButtonSize size = AppButtonSize.medium,
    bool isLoading = false,
    bool isExpanded = false,
  }) => AppButton(
    key: key,
    text: text,
    icon: icon,
    onPressed: onPressed,
    type: AppButtonType.primary,
    size: size,
    isLoading: isLoading,
    isExpanded: isExpanded,
  );

  factory AppButton.secondary({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    IconData? icon,
    AppButtonSize size = AppButtonSize.medium,
    bool isLoading = false,
    bool isExpanded = false,
  }) => AppButton(
    key: key,
    text: text,
    icon: icon,
    onPressed: onPressed,
    type: AppButtonType.secondary,
    size: size,
    isLoading: isLoading,
    isExpanded: isExpanded,
  );

  factory AppButton.outline({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    IconData? icon,
    AppButtonSize size = AppButtonSize.medium,
    bool isLoading = false,
    bool isExpanded = false,
  }) => AppButton(
    key: key,
    text: text,
    icon: icon,
    onPressed: onPressed,
    type: AppButtonType.outline,
    size: size,
    isLoading: isLoading,
    isExpanded: isExpanded,
  );

  factory AppButton.icon({
    Key? key,
    required IconData icon,
    required VoidCallback? onPressed,
    AppButtonSize size = AppButtonSize.medium,
    Color? backgroundColor,
    Color? iconColor,
  }) => AppButton(
    key: key,
    icon: icon,
    onPressed: onPressed,
    type: AppButtonType.icon,
    size: size,
    backgroundColor: backgroundColor,
    textColor: iconColor,
  );

  factory AppButton.floating({
    Key? key,
    required IconData icon,
    required VoidCallback? onPressed,
    String? text,
    bool isExtended = false,
  }) => AppButton(
    key: key,
    icon: icon,
    text: isExtended ? text : null,
    onPressed: onPressed,
    type: AppButtonType.floating,
    size: AppButtonSize.large,
  );

  @override
  Widget build(BuildContext context) {
    final responsive = AppTheme.isMobile(context);

    switch (type) {
      case AppButtonType.primary:
        return _buildPrimaryButton(context, responsive);
      case AppButtonType.secondary:
        return _buildSecondaryButton(context, responsive);
      case AppButtonType.outline:
        return _buildOutlineButton(context, responsive);
      case AppButtonType.text:
        return _buildTextButton(context, responsive);
      case AppButtonType.floating:
        return _buildFloatingButton(context);
      case AppButtonType.icon:
        return _buildIconButton(context, responsive);
      case AppButtonType.card:
        return _buildCardButton(context, responsive);
    }
  }

  Widget _buildPrimaryButton(BuildContext context, bool isMobile) {
    return Container(
      width: isExpanded ? double.infinity : null,
      height: _getButtonHeight(),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppTheme.primaryColor,
          foregroundColor: textColor ?? Colors.white,
          elevation: 2,
          shadowColor: AppTheme.primaryColor.withValues(alpha: 0.3),
          padding: padding ?? _getPadding(isMobile),
          shape: RoundedRectangleBorder(
            borderRadius:
                borderRadius ?? BorderRadius.circular(_getBorderRadius()),
          ),
        ),
        child: _buildButtonContent(),
      ),
    );
  }

  Widget _buildSecondaryButton(BuildContext context, bool isMobile) {
    return Container(
      width: isExpanded ? double.infinity : null,
      height: _getButtonHeight(),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppTheme.secondaryColor,
          foregroundColor: textColor ?? Colors.white,
          elevation: 1,
          padding: padding ?? _getPadding(isMobile),
          shape: RoundedRectangleBorder(
            borderRadius:
                borderRadius ?? BorderRadius.circular(_getBorderRadius()),
          ),
        ),
        child: _buildButtonContent(),
      ),
    );
  }

  Widget _buildOutlineButton(BuildContext context, bool isMobile) {
    return Container(
      width: isExpanded ? double.infinity : null,
      height: _getButtonHeight(),
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor ?? AppTheme.primaryColor,
          side: BorderSide(
            color: backgroundColor ?? AppTheme.primaryColor,
            width: 1.5,
          ),
          padding: padding ?? _getPadding(isMobile),
          shape: RoundedRectangleBorder(
            borderRadius:
                borderRadius ?? BorderRadius.circular(_getBorderRadius()),
          ),
        ),
        child: _buildButtonContent(),
      ),
    );
  }

  Widget _buildTextButton(BuildContext context, bool isMobile) {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: textColor ?? AppTheme.primaryColor,
        padding: padding ?? _getPadding(isMobile),
        shape: RoundedRectangleBorder(
          borderRadius:
              borderRadius ?? BorderRadius.circular(_getBorderRadius()),
        ),
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildFloatingButton(BuildContext context) {
    if (text != null) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        backgroundColor: backgroundColor ?? AppTheme.primaryColor,
        foregroundColor: textColor ?? Colors.white,
        icon: icon != null ? Icon(icon) : null,
        label: Text(
          text!,
          style: AppTheme.labelLarge.copyWith(color: Colors.white),
        ),
      );
    }

    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: backgroundColor ?? AppTheme.primaryColor,
      foregroundColor: textColor ?? Colors.white,
      child: icon != null ? Icon(icon) : null,
    );
  }

  Widget _buildIconButton(BuildContext context, bool isMobile) {
    final iconSize = _getIconSize();
    final buttonSize = _getIconButtonSize();

    return Container(
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(_getBorderRadius()),
        border: Border.all(
          color: (backgroundColor ?? AppTheme.primaryColor).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: iconSize,
          color: textColor ?? AppTheme.primaryColor,
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildCardButton(BuildContext context, bool isMobile) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_getBorderRadius()),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(_getBorderRadius()),
        child: Container(
          width: isExpanded ? double.infinity : null,
          padding: padding ?? _getPadding(isMobile),
          child: child ?? _buildButtonContent(),
        ),
      ),
    );
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return SizedBox(
        width: _getLoadingSize(),
        height: _getLoadingSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(textColor ?? Colors.white),
        ),
      );
    }

    if (icon != null && text != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: _getIconSize()),
          SizedBox(width: AppTheme.spacing2),
          Text(text!, style: _getTextStyle()),
        ],
      );
    }

    if (icon != null) {
      return Icon(icon, size: _getIconSize());
    }

    if (text != null) {
      return Text(text!, style: _getTextStyle());
    }

    return child ?? const SizedBox.shrink();
  }

  // Helper methods để tính toán size
  double _getButtonHeight() {
    switch (size) {
      case AppButtonSize.small:
        return 36;
      case AppButtonSize.medium:
        return 44;
      case AppButtonSize.large:
        return 52;
      case AppButtonSize.extraLarge:
        return 60;
    }
  }

  double _getBorderRadius() {
    switch (size) {
      case AppButtonSize.small:
        return AppTheme.radiusSmall;
      case AppButtonSize.medium:
        return AppTheme.radiusMedium;
      case AppButtonSize.large:
        return AppTheme.radiusLarge;
      case AppButtonSize.extraLarge:
        return AppTheme.radiusXLarge;
    }
  }

  EdgeInsetsGeometry _getPadding(bool isMobile) {
    final baseSpacing = isMobile ? AppTheme.spacing3 : AppTheme.spacing4;

    switch (size) {
      case AppButtonSize.small:
        return EdgeInsets.symmetric(
          horizontal: baseSpacing,
          vertical: AppTheme.spacing2,
        );
      case AppButtonSize.medium:
        return EdgeInsets.symmetric(
          horizontal: baseSpacing * 1.5,
          vertical: AppTheme.spacing3,
        );
      case AppButtonSize.large:
        return EdgeInsets.symmetric(
          horizontal: baseSpacing * 2,
          vertical: AppTheme.spacing4,
        );
      case AppButtonSize.extraLarge:
        return EdgeInsets.symmetric(
          horizontal: baseSpacing * 2.5,
          vertical: AppTheme.spacing5,
        );
    }
  }

  double _getIconSize() {
    switch (size) {
      case AppButtonSize.small:
        return 16;
      case AppButtonSize.medium:
        return 20;
      case AppButtonSize.large:
        return 24;
      case AppButtonSize.extraLarge:
        return 28;
    }
  }

  double _getIconButtonSize() {
    switch (size) {
      case AppButtonSize.small:
        return 36;
      case AppButtonSize.medium:
        return 44;
      case AppButtonSize.large:
        return 52;
      case AppButtonSize.extraLarge:
        return 60;
    }
  }

  double _getLoadingSize() {
    switch (size) {
      case AppButtonSize.small:
        return 16;
      case AppButtonSize.medium:
        return 20;
      case AppButtonSize.large:
        return 24;
      case AppButtonSize.extraLarge:
        return 28;
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case AppButtonSize.small:
        return AppTheme.labelSmall.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        );
      case AppButtonSize.medium:
        return AppTheme.labelMedium.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        );
      case AppButtonSize.large:
        return AppTheme.labelLarge.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        );
      case AppButtonSize.extraLarge:
        return AppTheme.titleMedium.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        );
    }
  }
}

// Quick Action Button cho Dashboard
class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final bool isVertical;

  const QuickActionButton({
    Key? key,
    required this.icon,
    required this.label,
    this.onPressed,
    this.color,
    this.isVertical = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = AppTheme.isMobile(context);

    return AppButton(
      type: AppButtonType.card,
      onPressed: onPressed,
      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      child: isVertical
          ? _buildVerticalLayout(isMobile)
          : _buildHorizontalLayout(isMobile),
    );
  }

  Widget _buildVerticalLayout(bool isMobile) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isMobile ? 48 : 56,
          height: isMobile ? 48 : 56,
          decoration: BoxDecoration(
            color: (color ?? AppTheme.primaryColor).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          child: Icon(
            icon,
            color: color ?? AppTheme.primaryColor,
            size: isMobile ? 24 : 28,
          ),
        ),
        SizedBox(height: AppTheme.spacing2),
        Text(
          label,
          style: (isMobile ? AppTheme.labelSmall : AppTheme.labelMedium)
              .copyWith(
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildHorizontalLayout(bool isMobile) {
    return Row(
      children: [
        Container(
          width: isMobile ? 40 : 48,
          height: isMobile ? 40 : 48,
          decoration: BoxDecoration(
            color: (color ?? AppTheme.primaryColor).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          child: Icon(
            icon,
            color: color ?? AppTheme.primaryColor,
            size: isMobile ? 20 : 24,
          ),
        ),
        SizedBox(width: AppTheme.spacing3),
        Expanded(
          child: Text(
            label,
            style: (isMobile ? AppTheme.bodyMedium : AppTheme.bodyLarge)
                .copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}


