import 'package:flutter/material.dart';
import '../theme.dart';

class TextContrastHelper {
  // Enhanced high contrast colors specifically for gradient backgrounds
  static const Color highContrastWhite = Color(0xFFFFFFFF);
  static const Color highContrastBlack = Color(0xFF000000);
  static const Color semiTransparentWhite = Color(0xF0FFFFFF);
  static const Color semiTransparentBlack = Color(0xF0000000);

  // Shadow configurations for different scenarios
  static const List<Shadow> strongTextShadow = [
    Shadow(color: Color(0x80000000), offset: Offset(0, 1), blurRadius: 3),
    Shadow(color: Color(0x40000000), offset: Offset(0, 2), blurRadius: 6),
  ];

  static const List<Shadow> subtleTextShadow = [
    Shadow(color: Color(0x60000000), offset: Offset(0, 1), blurRadius: 2),
  ];

  static const List<Shadow> glowShadow = [
    Shadow(color: Color(0x80FFFFFF), offset: Offset(0, 0), blurRadius: 4),
  ];

  /// Enhanced method to get high contrast text color for any background
  static Color getContrastTextColor(Color backgroundColor) {
    final double luminance = backgroundColor.computeLuminance();

    // Use more aggressive contrast ratios for better readability
    if (luminance > 0.6) {
      return highContrastBlack;
    } else if (luminance > 0.3) {
      return const Color(0xFF1A1A1A); // Very dark gray
    } else {
      return highContrastWhite;
    }
  }

  /// Get text color specifically optimized for gradient backgrounds
  static Color getGradientTextColor(LinearGradient gradient) {
    // Calculate average luminance of gradient colors
    double totalLuminance = 0;
    for (Color color in gradient.colors) {
      totalLuminance += color.computeLuminance();
    }
    double averageLuminance = totalLuminance / gradient.colors.length;

    // For gradients, we need higher contrast ratios
    if (averageLuminance > 0.4) {
      return highContrastBlack;
    } else {
      return highContrastWhite;
    }
  }

  /// Get appropriate text shadows for gradient backgrounds
  static List<Shadow> getGradientTextShadows(LinearGradient gradient) {
    Color textColor = getGradientTextColor(gradient);

    if (textColor == highContrastWhite) {
      return strongTextShadow; // Dark shadows for white text
    } else {
      return glowShadow; // Light glow for dark text
    }
  }

  /// Enhanced text style for gradient backgrounds with optimal readability
  static TextStyle getGradientTextStyle(
    TextStyle baseStyle,
    LinearGradient gradient, {
    bool addShadow = true,
    FontWeight? fontWeight,
  }) {
    final Color textColor = getGradientTextColor(gradient);
    final List<Shadow> shadows = addShadow
        ? getGradientTextShadows(gradient)
        : [];

    return baseStyle.copyWith(
      color: textColor,
      shadows: shadows,
      fontWeight:
          fontWeight ??
          FontWeight.w600, // Slightly bolder for better readability
    );
  }

  /// Get semi-transparent overlay color for better text readability
  static Color getTextBackgroundOverlay(LinearGradient gradient) {
    Color textColor = getGradientTextColor(gradient);

    if (textColor == highContrastWhite) {
      return const Color(0x20000000); // Dark overlay for white text
    } else {
      return const Color(0x20FFFFFF); // Light overlay for dark text
    }
  }

  /// Create a text container with background for improved readability
  static Widget createReadableTextContainer({
    required Widget child,
    required LinearGradient backgroundGradient,
    EdgeInsetsGeometry? padding,
    BorderRadius? borderRadius,
  }) {
    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: getTextBackgroundOverlay(backgroundGradient),
        borderRadius: borderRadius ?? BorderRadius.circular(6),
      ),
      child: child,
    );
  }

  /// Enhanced method for AppTheme gradient text styles
  static TextStyle getPrimaryGradientTextStyle(TextStyle baseStyle) {
    return getGradientTextStyle(baseStyle, AppTheme.primaryGradient);
  }

  static TextStyle getSecondaryGradientTextStyle(TextStyle baseStyle) {
    return getGradientTextStyle(baseStyle, AppTheme.secondaryGradient);
  }

  static TextStyle getAccentGradientTextStyle(TextStyle baseStyle) {
    return getGradientTextStyle(baseStyle, AppTheme.accentGradient);
  }

  static TextStyle getSuccessGradientTextStyle(TextStyle baseStyle) {
    return getGradientTextStyle(baseStyle, AppTheme.successGradient);
  }

  static TextStyle getWarningGradientTextStyle(TextStyle baseStyle) {
    return getGradientTextStyle(baseStyle, AppTheme.warningGradient);
  }

  static TextStyle getErrorGradientTextStyle(TextStyle baseStyle) {
    return getGradientTextStyle(baseStyle, AppTheme.errorGradient);
  }

  /// Utility method to check if a color combination has sufficient contrast
  static bool hasSufficientContrast(Color foreground, Color background) {
    final double luminance1 = foreground.computeLuminance();
    final double luminance2 = background.computeLuminance();

    final double lighterLuminance = luminance1 > luminance2
        ? luminance1
        : luminance2;
    final double darkerLuminance = luminance1 > luminance2
        ? luminance2
        : luminance1;

    final double contrastRatio =
        (lighterLuminance + 0.05) / (darkerLuminance + 0.05);

    // WCAG AA standard requires 4.5:1 for normal text, 3:1 for large text
    return contrastRatio >= 4.5;
  }

  /// Get adaptive button text color based on button background
  static Color getButtonTextColor(Color buttonColor) {
    return getContrastTextColor(buttonColor);
  }

  /// Create enhanced button style with optimal text contrast
  static ButtonStyle getContrastButtonStyle({
    required Color backgroundColor,
    EdgeInsetsGeometry? padding,
    BorderRadius? borderRadius,
  }) {
    final Color textColor = getContrastTextColor(backgroundColor);

    return ElevatedButton.styleFrom(
      foregroundColor: textColor,
      backgroundColor: backgroundColor,
      padding: padding,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
    );
  }
}
