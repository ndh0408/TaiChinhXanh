import 'package:flutter/material.dart';

class ResponsiveHelper {
  static const double _mobileBreakpoint = 600;
  static const double _tabletBreakpoint = 900;
  static const double _desktopBreakpoint = 1200;

  // Enhanced device detection
  static bool isSmallPhone(BuildContext context) =>
      MediaQuery.of(context).size.width < 360;
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < _mobileBreakpoint;
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= _mobileBreakpoint &&
      MediaQuery.of(context).size.width < _tabletBreakpoint;
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= _desktopBreakpoint;
  static bool isLargePhone(BuildContext context) =>
      MediaQuery.of(context).size.width >= 360 &&
      MediaQuery.of(context).size.width < _mobileBreakpoint;

  // Enhanced screen size helpers
  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;
  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;
  static double screenShortestSide(BuildContext context) =>
      MediaQuery.of(context).size.shortestSide;
  static double screenLongestSide(BuildContext context) =>
      MediaQuery.of(context).size.longestSide;

  // Safe area helpers
  static EdgeInsets safeAreaPadding(BuildContext context) =>
      MediaQuery.of(context).padding;
  static double safeAreaTop(BuildContext context) =>
      MediaQuery.of(context).padding.top;
  static double safeAreaBottom(BuildContext context) =>
      MediaQuery.of(context).padding.bottom;

  // Enhanced responsive padding with consistent values
  static EdgeInsets responsivePadding(
    BuildContext context, {
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop(context)) {
      final value = desktop ?? 32.0;
      return EdgeInsets.all(value);
    } else if (isTablet(context)) {
      final value = tablet ?? 24.0;
      return EdgeInsets.all(value);
    } else if (isLargePhone(context)) {
      final value = mobile ?? 20.0;
      return EdgeInsets.all(value);
    } else {
      final value = (mobile ?? 20.0) * 0.8; // Smaller for small phones
      return EdgeInsets.all(value);
    }
  }

  // Enhanced responsive margin
  static EdgeInsets responsiveMargin(
    BuildContext context, {
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop(context)) {
      final value = desktop ?? 24.0;
      return EdgeInsets.all(value);
    } else if (isTablet(context)) {
      final value = tablet ?? 20.0;
      return EdgeInsets.all(value);
    } else if (isLargePhone(context)) {
      final value = mobile ?? 16.0;
      return EdgeInsets.all(value);
    } else {
      final value = (mobile ?? 16.0) * 0.8;
      return EdgeInsets.all(value);
    }
  }

  // Consistent font size scaling
  static double responsiveFontSize(
    BuildContext context, {
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop(context)) {
      return desktop ?? (mobile ?? 16.0) * 1.3;
    } else if (isTablet(context)) {
      return tablet ?? (mobile ?? 16.0) * 1.15;
    } else if (isLargePhone(context)) {
      return mobile ?? 16.0;
    } else {
      return (mobile ?? 16.0) * 0.9; // Slightly smaller for small phones
    }
  }

  // Enhanced icon sizing
  static double responsiveIconSize(
    BuildContext context, {
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop(context)) {
      return desktop ?? (mobile ?? 24.0) * 1.4;
    } else if (isTablet(context)) {
      return tablet ?? (mobile ?? 24.0) * 1.2;
    } else if (isLargePhone(context)) {
      return mobile ?? 24.0;
    } else {
      return (mobile ?? 24.0) * 0.9;
    }
  }

  // Button sizing with consistent ratios
  static Size responsiveButtonSize(
    BuildContext context, {
    Size? mobile,
    Size? tablet,
    Size? desktop,
  }) {
    const defaultMobile = Size(280, 48);
    final mobileSize = mobile ?? defaultMobile;

    if (isDesktop(context)) {
      return desktop ?? Size(mobileSize.width * 1.3, mobileSize.height * 1.1);
    } else if (isTablet(context)) {
      return tablet ?? Size(mobileSize.width * 1.15, mobileSize.height * 1.05);
    } else if (isLargePhone(context)) {
      return mobileSize;
    } else {
      return Size(mobileSize.width * 0.9, mobileSize.height * 0.95);
    }
  }

  // Enhanced card sizing
  static double responsiveCardWidth(
    BuildContext context, {
    double? maxWidth,
    double? minWidth,
  }) {
    final width = screenWidth(context);
    final maxW = maxWidth ?? 400;
    final minW = minWidth ?? 280;

    if (isDesktop(context)) {
      return (width * 0.3).clamp(minW, maxW);
    } else if (isTablet(context)) {
      return (width * 0.45).clamp(minW, maxW);
    } else {
      return (width * 0.9).clamp(minW, double.infinity);
    }
  }

  // Grid columns with better responsiveness
  static int responsiveGridColumns(
    BuildContext context, {
    int? mobile,
    int? tablet,
    int? desktop,
  }) {
    if (isDesktop(context)) {
      return desktop ?? 4;
    } else if (isTablet(context)) {
      return tablet ?? 3;
    } else if (isLargePhone(context)) {
      return mobile ?? 2;
    } else {
      return 1; // Single column for small phones
    }
  }

  // Enhanced responsive height
  static double responsiveHeight(
    BuildContext context, {
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop(context)) {
      return desktop ?? (mobile ?? 200.0) * 1.3;
    } else if (isTablet(context)) {
      return tablet ?? (mobile ?? 200.0) * 1.15;
    } else {
      return mobile ?? 200.0;
    }
  }

  // Smart spacing based on available space
  static double responsiveSpacing(
    BuildContext context, {
    double? small,
    double? medium,
    double? large,
  }) {
    final width = screenWidth(context);

    if (width > 1200) {
      return large ?? 32.0;
    } else if (width > 600) {
      return medium ?? 24.0;
    } else if (width > 360) {
      return small ?? 16.0;
    } else {
      return (small ?? 16.0) * 0.8;
    }
  }

  // Enhanced border radius scaling
  static double responsiveBorderRadius(
    BuildContext context, {
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop(context)) {
      return desktop ?? (mobile ?? 12.0) * 1.2;
    } else if (isTablet(context)) {
      return tablet ?? (mobile ?? 12.0) * 1.1;
    } else {
      return mobile ?? 12.0;
    }
  }

  // Consistent elevation scaling
  static double responsiveElevation(
    BuildContext context, {
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop(context)) {
      return desktop ?? (mobile ?? 4.0) * 1.5;
    } else if (isTablet(context)) {
      return tablet ?? (mobile ?? 4.0) * 1.2;
    } else {
      return mobile ?? 4.0;
    }
  }

  // App bar height scaling
  static double responsiveAppBarHeight(BuildContext context) {
    if (isDesktop(context)) {
      return kToolbarHeight * 1.2;
    } else if (isTablet(context)) {
      return kToolbarHeight * 1.1;
    } else {
      return kToolbarHeight;
    }
  }

  // Bottom navigation bar height
  static double responsiveBottomNavHeight(BuildContext context) {
    if (isDesktop(context)) {
      return 70.0;
    } else if (isTablet(context)) {
      return 65.0;
    } else if (isLargePhone(context)) {
      return 60.0;
    } else {
      return 56.0;
    }
  }

  // Floating action button size
  static double responsiveFABSize(BuildContext context) {
    if (isDesktop(context)) {
      return 64.0;
    } else if (isTablet(context)) {
      return 60.0;
    } else {
      return 56.0;
    }
  }

  // Text field height
  static double responsiveTextFieldHeight(BuildContext context) {
    if (isDesktop(context)) {
      return 56.0;
    } else if (isTablet(context)) {
      return 52.0;
    } else if (isLargePhone(context)) {
      return 48.0;
    } else {
      return 44.0;
    }
  }

  // List tile height
  static double responsiveListTileHeight(BuildContext context) {
    if (isDesktop(context)) {
      return 72.0;
    } else if (isTablet(context)) {
      return 68.0;
    } else if (isLargePhone(context)) {
      return 64.0;
    } else {
      return 56.0;
    }
  }

  // Dialog sizing
  static double responsiveDialogWidth(BuildContext context) {
    final width = screenWidth(context);

    if (isDesktop(context)) {
      return (width * 0.4).clamp(400, 600);
    } else if (isTablet(context)) {
      return (width * 0.6).clamp(350, 500);
    } else {
      return (width * 0.9).clamp(280, 400);
    }
  }

  // Adaptive content width for readable text
  static double responsiveContentWidth(BuildContext context) {
    final width = screenWidth(context);

    if (isDesktop(context)) {
      return (width * 0.7).clamp(600, 1000);
    } else if (isTablet(context)) {
      return (width * 0.85).clamp(400, 700);
    } else {
      return width * 0.95;
    }
  }

  // Smart grid aspect ratio
  static double responsiveGridAspectRatio(BuildContext context) {
    if (isDesktop(context)) {
      return 1.4;
    } else if (isTablet(context)) {
      return 1.3;
    } else if (isLargePhone(context)) {
      return 1.2;
    } else {
      return 1.1;
    }
  }

  // Enhanced utility methods
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  static double get textScaleFactor => 1.0; // Keep consistent text scaling

  // Screen size category for decision making
  static ScreenSizeCategory getScreenSizeCategory(BuildContext context) {
    final width = screenWidth(context);

    if (width < 360) return ScreenSizeCategory.smallPhone;
    if (width < _mobileBreakpoint) return ScreenSizeCategory.largePhone;
    if (width < _tabletBreakpoint) return ScreenSizeCategory.tablet;
    if (width < _desktopBreakpoint) return ScreenSizeCategory.desktop;
    return ScreenSizeCategory.largeDesktop;
  }
}

enum ScreenSizeCategory {
  smallPhone,
  largePhone,
  tablet,
  desktop,
  largeDesktop,
}
