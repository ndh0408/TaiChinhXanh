import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ==================== MODERN COLOR PALETTE ====================

  // Primary Brand Colors - Beautiful Blue Gradient
  static const Color primaryStart = Color(0xFF667eea);
  static const Color primaryEnd = Color(0xFF764ba2);
  static const Color primaryColor = Color(0xFF6366f1);
  static const Color primaryLight = Color(0xFF8b87ff);
  static const Color primaryDark = Color(0xFF4338ca);

  // Secondary Colors - Purple & Pink Gradients
  static const Color secondaryStart = Color(0xFFf093fb);
  static const Color secondaryEnd = Color(0xFFf5576c);
  static const Color accentStart = Color(0xFF4facfe);
  static const Color accentEnd = Color(0xFF00f2fe);

  // Status Colors with Gradients
  static const Color successStart = Color(0xFF56ab2f);
  static const Color successEnd = Color(0xFFa8e6cf);
  static const Color warningStart = Color(0xFFf7971e);
  static const Color warningEnd = Color(0xFFffd200);
  static const Color errorStart = Color(0xFFff6b6b);
  static const Color errorEnd = Color(0xFFff8e8e);
  static const Color infoStart = Color(0xFF74b9ff);
  static const Color infoEnd = Color(0xFF0984e3);

  // Neutral Colors - Modern Gray Scale
  static const Color white = Color(0xFFffffff);
  static const Color gray50 = Color(0xFFf8fafc);
  static const Color gray100 = Color(0xFFf1f5f9);
  static const Color gray200 = Color(0xFFe2e8f0);
  static const Color gray300 = Color(0xFFcbd5e1);
  static const Color gray400 = Color(0xFF94a3b8);
  static const Color gray500 = Color(0xFF64748b);
  static const Color gray600 = Color(0xFF475569);
  static const Color gray700 = Color(0xFF334155);
  static const Color gray800 = Color(0xFF1e293b);
  static const Color gray900 = Color(0xFF0f172a);

  // Glass Morphism Colors
  static const Color glassWhite = Color(0x1AFFFFFF);
  static const Color glassDark = Color(0x1A000000);
  static const Color glassBlur = Color(0x33FFFFFF);

  // ==================== GRADIENTS ====================

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryStart, primaryEnd],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryStart, secondaryEnd],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentStart, accentEnd],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [successStart, successEnd],
  );

  static const LinearGradient warningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [warningStart, warningEnd],
  );

  static const LinearGradient errorGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [errorStart, errorEnd],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFf8fafc), Color(0xFFe2e8f0)],
  );

  static const LinearGradient darkBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1e293b), Color(0xFF0f172a)],
  );

  // ==================== SHADOWS ====================

  static List<BoxShadow> lightShadow = [
    BoxShadow(
      color: gray900.withValues(alpha: 0.05),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> mediumShadow = [
    BoxShadow(
      color: gray900.withValues(alpha: 0.1),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> heavyShadow = [
    BoxShadow(
      color: gray900.withValues(alpha: 0.15),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> glowShadow = [
    BoxShadow(
      color: primaryColor.withValues(alpha: 0.3),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
  ];

  // ==================== SPACING ====================

  static const double spacing1 = 4.0;
  static const double spacing2 = 8.0;
  static const double spacing3 = 12.0;
  static const double spacing4 = 16.0;
  static const double spacing5 = 20.0;
  static const double spacing6 = 24.0;
  static const double spacing8 = 32.0;
  static const double spacing10 = 40.0;
  static const double spacing12 = 48.0;
  static const double spacing16 = 64.0;
  static const double spacing20 = 80.0;

  // ==================== BORDER RADIUS ====================

  static const double radiusXS = 4.0;
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 20.0;
  static const double radius2XL = 24.0;
  static const double radiusFull = 999.0;

  // Alias properties for backward compatibility
  static const double radiusSmall = radiusSM;
  static const double radiusMedium = radiusMD;
  static const double radiusLarge = radiusLG;
  static const double radiusXLarge = radiusXL;

  // ==================== ICON SIZES ====================

  static const double iconXS = 12.0;
  static const double iconSM = 16.0;
  static const double iconMD = 20.0;
  static const double iconLG = 24.0;
  static const double iconXL = 32.0;
  static const double icon2XL = 40.0;
  static const double icon3XL = 48.0;

  // Alias properties for backward compatibility
  static const double iconSmall = iconSM;
  static const double iconMedium = iconMD;
  static const double iconLarge = iconLG;

  // ==================== STATUS COLORS ====================

  // Direct color access for backward compatibility
  static const Color errorColor = errorStart;
  static const Color warningColor = warningStart;
  static const Color successColor = successStart;
  static const Color infoColor = infoStart;

  // Finance specific colors
  static const Color incomeColor = successStart;
  static const Color expenseColor = errorStart;
  static const Color savingsColor = Color(0xFF10b981);
  static const Color investmentColor = Color(0xFF8b5cf6);

  // UI colors
  static const Color surfaceColor = white;
  static const Color secondaryColor = Color(0xFFf093fb);
  static const Color textPrimary = gray900;
  static const Color textSecondary = gray700;
  static const Color textMuted = gray500;

  // Additional missing colors
  static const Color backgroundColor = gray50;
  static const Color primarySurface = white;
  static const Color accentOrange = Color(0xFFff8500);

  // Currency text sizes
  static const double currencySmall = 12.0;
  static const double currencyMedium = 16.0;
  static const double currencyLarge = 20.0;

  // Shadow shortcuts
  static List<BoxShadow> get softShadow => lightShadow;

  // ==================== ADDITIONAL GRADIENTS ====================

  static const LinearGradient incomeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF56ab2f), Color(0xFFa8e6cf)],
  );

  static const LinearGradient expenseGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFff6b6b), Color(0xFFff8e8e)],
  );

  static const LinearGradient savingsGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10b981), Color(0xFF34d399)],
  );

  // Card gradient
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [white, gray50],
  );

  // ==================== DECORATIONS ====================

  // White card decoration
  static BoxDecoration get whiteCardDecoration => BoxDecoration(
    color: white,
    borderRadius: BorderRadius.circular(radiusLG),
    boxShadow: lightShadow,
  );

  // ==================== TYPOGRAPHY ====================

  static TextStyle get displayLarge => GoogleFonts.inter(
    fontSize: 48,
    fontWeight: FontWeight.w800,
    height: 1.1,
    letterSpacing: -0.02,
  );

  static TextStyle get displayMedium => GoogleFonts.inter(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.01,
  );

  static TextStyle get displaySmall =>
      GoogleFonts.inter(fontSize: 30, fontWeight: FontWeight.w600, height: 1.2);

  static TextStyle get headlineLarge =>
      GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600, height: 1.3);

  static TextStyle get headlineMedium =>
      GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, height: 1.3);

  static TextStyle get headlineSmall =>
      GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w500, height: 1.4);

  static TextStyle get titleLarge =>
      GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, height: 1.4);

  static TextStyle get titleMedium =>
      GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, height: 1.4);

  static TextStyle get titleSmall =>
      GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, height: 1.4);

  static TextStyle get bodyLarge =>
      GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5);

  static TextStyle get bodyMedium =>
      GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5);

  static TextStyle get bodySmall =>
      GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, height: 1.4);

  static TextStyle get labelLarge =>
      GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, height: 1.4);

  static TextStyle get labelMedium =>
      GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, height: 1.4);

  static TextStyle get labelSmall =>
      GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, height: 1.4);

  // ==================== THEME DATA ====================

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: Color(0xFFf093fb),
      surface: white,
      surfaceContainerHighest: gray50, // Replacing background
      error: errorStart,
      onPrimary: white,
      onSecondary: white,
      onSurface: gray900,
      onSurfaceVariant: gray900, // Replacing onBackground
      onError: white,
    ),
    textTheme: TextTheme(
      displayLarge: displayLarge.copyWith(color: gray900),
      displayMedium: displayMedium.copyWith(color: gray900),
      displaySmall: displaySmall.copyWith(color: gray900),
      headlineLarge: headlineLarge.copyWith(color: gray900),
      headlineMedium: headlineMedium.copyWith(color: gray900),
      headlineSmall: headlineSmall.copyWith(color: gray900),
      titleLarge: titleLarge.copyWith(color: gray900),
      titleMedium: titleMedium.copyWith(color: gray700),
      titleSmall: titleSmall.copyWith(color: gray600),
      bodyLarge: bodyLarge.copyWith(color: gray800),
      bodyMedium: bodyMedium.copyWith(color: gray700),
      bodySmall: bodySmall.copyWith(color: gray600),
      labelLarge: labelLarge.copyWith(color: gray700),
      labelMedium: labelMedium.copyWith(color: gray600),
      labelSmall: labelSmall.copyWith(color: gray500),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: headlineMedium.copyWith(color: white),
      iconTheme: const IconThemeData(color: white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: white,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLG),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: spacing6,
          vertical: spacing4,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusXL),
      ),
      margin: EdgeInsets.zero,
    ),
    dividerTheme: DividerThemeData(
      color: gray200,
      thickness: 1,
      space: spacing2,
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: Color(0xFFf093fb),
      surface: gray800,
      surfaceContainerHighest: gray900, // Replacing background
      error: errorStart,
      onPrimary: white,
      onSecondary: white,
      onSurface: white,
      onSurfaceVariant: white, // Replacing onBackground
      onError: white,
    ),
    textTheme: TextTheme(
      displayLarge: displayLarge.copyWith(color: white),
      displayMedium: displayMedium.copyWith(color: white),
      displaySmall: displaySmall.copyWith(color: white),
      headlineLarge: headlineLarge.copyWith(color: white),
      headlineMedium: headlineMedium.copyWith(color: white),
      headlineSmall: headlineSmall.copyWith(color: white),
      titleLarge: titleLarge.copyWith(color: white),
      titleMedium: titleMedium.copyWith(color: gray300),
      titleSmall: titleSmall.copyWith(color: gray400),
      bodyLarge: bodyLarge.copyWith(color: gray200),
      bodyMedium: bodyMedium.copyWith(color: gray300),
      bodySmall: bodySmall.copyWith(color: gray400),
      labelLarge: labelLarge.copyWith(color: gray300),
      labelMedium: labelMedium.copyWith(color: gray400),
      labelSmall: labelSmall.copyWith(color: gray500),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: headlineMedium.copyWith(color: white),
      iconTheme: const IconThemeData(color: white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: white,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLG),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: spacing6,
          vertical: spacing4,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: gray800,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusXL),
      ),
      margin: EdgeInsets.zero,
    ),
    dividerTheme: DividerThemeData(
      color: gray700,
      thickness: 1,
      space: spacing2,
    ),
  );

  // ==================== UTILITY METHODS ====================

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 768;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 768 && width < 1024;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  static double getResponsivePadding(BuildContext context) {
    if (isMobile(context)) return spacing4;
    if (isTablet(context)) return spacing6;
    return spacing8;
  }

  static double getResponsiveRadius(BuildContext context) {
    if (isMobile(context)) return radiusMD;
    if (isTablet(context)) return radiusLG;
    return radiusXL;
  }

  // ==================== GLASS MORPHISM HELPER ====================

  static BoxDecoration glassMorphism({
    Color? color,
    double borderRadius = radiusXL,
    bool hasBorder = true,
  }) {
    return BoxDecoration(
      color: color ?? glassWhite,
      borderRadius: BorderRadius.circular(borderRadius),
      border: hasBorder
          ? Border.all(color: white.withValues(alpha: 0.2), width: 1)
          : null,
      boxShadow: [
        BoxShadow(
          color: gray900.withValues(alpha: 0.1),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  // ==================== ANIMATION CURVES ====================

  static const Curve bounceInCurve = Curves.elasticOut;
  static const Curve smoothCurve = Curves.easeInOutCubic;
  static const Curve quickCurve = Curves.easeOutQuart;

  // ==================== ANIMATION DURATIONS ====================

  static const Duration quickDuration = Duration(milliseconds: 200);
  static const Duration normalDuration = Duration(milliseconds: 300);
  static const Duration slowDuration = Duration(milliseconds: 500);
  static const Duration extraSlowDuration = Duration(milliseconds: 800);
}
