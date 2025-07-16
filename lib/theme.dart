import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // ===== VIETCOMBANK BRAND COLORS =====
  // Primary Green (Màu xanh lá chủ đạo của VCB)
  static const Color vcbPrimaryGreen = Color(0xFF007549);
  static const Color vcbDarkGreen = Color(0xFF005A37);
  static const Color vcbLightGreen = Color(0xFF4CAF50);
  static const Color vcbGreenAccent = Color(0xFF81C784);
  
  // Secondary Colors (Màu phụ)
  static const Color vcbBlue = Color(0xFF1976D2);
  static const Color vcbLightBlue = Color(0xFF42A5F5);
  static const Color vcbOrange = Color(0xFFFF6F00);
  static const Color vcbGold = Color(0xFFFFC107);
  
  // Neutral Colors (Màu trung tính)
  static const Color vcbWhite = Color(0xFFFFFFFF);
  static const Color vcbGrey50 = Color(0xFFFAFAFA);
  static const Color vcbGrey100 = Color(0xFFF5F5F5);
  static const Color vcbGrey200 = Color(0xFFEEEEEE);
  static const Color vcbGrey300 = Color(0xFFE0E0E0);
  static const Color vcbGrey400 = Color(0xFFBDBDBD);
  static const Color vcbGrey500 = Color(0xFF9E9E9E);
  static const Color vcbGrey600 = Color(0xFF757575);
  static const Color vcbGrey700 = Color(0xFF616161);
  static const Color vcbGrey800 = Color(0xFF424242);
  static const Color vcbGrey900 = Color(0xFF212121);
  static const Color vcbBlack = Color(0xFF000000);
  
  // Status Colors (Màu trạng thái)
  static const Color vcbSuccess = Color(0xFF4CAF50);
  static const Color vcbWarning = Color(0xFFFF9800);
  static const Color vcbError = Color(0xFFF44336);
  static const Color vcbInfo = Color(0xFF2196F3);
  
  // Background Colors
  static const Color vcbBackground = vcbGrey50;
  static const Color vcbSurface = vcbWhite;
  static const Color vcbCardBackground = vcbWhite;
  
  // Text Colors
  static const Color vcbTextPrimary = vcbGrey900;
  static const Color vcbTextSecondary = vcbGrey700;
  static const Color vcbTextHint = vcbGrey500;
  static const Color vcbTextDisabled = vcbGrey400;
  static const Color vcbTextOnPrimary = vcbWhite;
  
  // Divider Color
  static const Color vcbDivider = vcbGrey300;
  
  // ===== GRADIENTS =====
  static const LinearGradient vcbPrimaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [vcbPrimaryGreen, vcbDarkGreen],
  );
  
  static const LinearGradient vcbAccentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [vcbLightGreen, vcbPrimaryGreen],
  );
  
  static const LinearGradient vcbCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [vcbWhite, vcbGrey50],
  );
  
  // ===== SHADOWS =====
  static List<BoxShadow> vcbShadowSmall = [
    BoxShadow(
      color: vcbBlack.withOpacity(0.05),
      offset: const Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
  ];
  
  static List<BoxShadow> vcbShadowMedium = [
    BoxShadow(
      color: vcbBlack.withOpacity(0.08),
      offset: const Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];
  
  static List<BoxShadow> vcbShadowLarge = [
    BoxShadow(
      color: vcbBlack.withOpacity(0.12),
      offset: const Offset(0, 4),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];
  
  // ===== ANIMATION DURATIONS =====
  static const Duration fastDuration = Duration(milliseconds: 150);
  static const Duration normalDuration = Duration(milliseconds: 300);
  static const Duration slowDuration = Duration(milliseconds: 500);
  
  // ===== ANIMATION CURVES =====
  static const Curve smoothCurve = Curves.easeInOutCubic;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve sharpCurve = Curves.easeOutExpo;
  
  // ===== BORDER RADIUS =====
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;
  static const double radiusCircular = 999.0;
  
  // ===== SPACING =====
  static const double spaceXSmall = 4.0;
  static const double spaceSmall = 8.0;
  static const double spaceMedium = 16.0;
  static const double spaceLarge = 24.0;
  static const double spaceXLarge = 32.0;
  static const double spaceXXLarge = 48.0;
  
  // ===== ELEVATION =====
  static const double elevationSmall = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationLarge = 8.0;
  
  // ===== TEXT STYLES WITH BEVIETNAM PRO FONT =====
  static const String fontFamily = 'BeVietnamPro';
  
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: vcbTextPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );
  
  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: vcbTextPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );
  
  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: vcbTextPrimary,
    letterSpacing: -0.3,
    height: 1.3,
  );
  
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: vcbTextPrimary,
    letterSpacing: -0.2,
    height: 1.3,
  );
  
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: vcbTextPrimary,
    letterSpacing: -0.1,
    height: 1.4,
  );
  
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: vcbTextPrimary,
    height: 1.4,
  );
  
  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: vcbTextPrimary,
    height: 1.5,
  );
  
  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: vcbTextPrimary,
    height: 1.5,
  );
  
  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: vcbTextPrimary,
    letterSpacing: 0.1,
    height: 1.5,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: vcbTextSecondary,
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: vcbTextSecondary,
    height: 1.5,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: vcbTextSecondary,
    letterSpacing: 0.1,
    height: 1.5,
  );
  
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: vcbTextPrimary,
    letterSpacing: 0.1,
    height: 1.4,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: vcbTextPrimary,
    letterSpacing: 0.3,
    height: 1.4,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: vcbTextPrimary,
    letterSpacing: 0.3,
    height: 1.4,
  );
  
  // ===== BUTTON STYLES =====
  static final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    foregroundColor: vcbWhite,
    backgroundColor: vcbPrimaryGreen,
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
    ),
    textStyle: titleMedium.copyWith(color: vcbWhite),
  );
  
  static final ButtonStyle secondaryButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: vcbPrimaryGreen,
    side: const BorderSide(color: vcbPrimaryGreen, width: 1.5),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
    ),
    textStyle: titleMedium,
  );
  
  static final ButtonStyle textButtonStyle = TextButton.styleFrom(
    foregroundColor: vcbPrimaryGreen,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    textStyle: titleMedium,
  );
  
  // ===== INPUT DECORATION =====
  static InputDecoration inputDecoration({
    String? labelText,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      labelStyle: bodyMedium.copyWith(color: vcbTextSecondary),
      hintStyle: bodyMedium.copyWith(color: vcbTextHint),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: vcbGrey100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: vcbPrimaryGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: vcbError, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: vcbError, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
  
  // ===== CARD DECORATION =====
  static BoxDecoration cardDecoration({
    Color? color,
    List<BoxShadow>? boxShadow,
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      color: color ?? vcbCardBackground,
      borderRadius: borderRadius ?? BorderRadius.circular(radiusMedium),
      boxShadow: boxShadow ?? vcbShadowMedium,
    );
  }
  
  // ===== THEME DATA =====
  static final ThemeData lightTheme = ThemeData(
    fontFamily: fontFamily,
    primaryColor: vcbPrimaryGreen,
    scaffoldBackgroundColor: vcbBackground,
    colorScheme: const ColorScheme.light(
      primary: vcbPrimaryGreen,
      secondary: vcbLightGreen,
      surface: vcbSurface,
      error: vcbError,
      onPrimary: vcbWhite,
      onSecondary: vcbWhite,
      onSurface: vcbTextPrimary,
      onError: vcbWhite,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: vcbWhite,
      foregroundColor: vcbTextPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: headlineSmall,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(style: primaryButtonStyle),
    outlinedButtonTheme: OutlinedButtonThemeData(style: secondaryButtonStyle),
    textButtonTheme: TextButtonThemeData(style: textButtonStyle),
    dividerTheme: const DividerThemeData(
      color: vcbDivider,
      thickness: 1,
      space: 0,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: vcbWhite,
      selectedItemColor: vcbPrimaryGreen,
      unselectedItemColor: vcbGrey600,
      selectedLabelStyle: labelMedium,
      unselectedLabelStyle: labelMedium,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    textTheme: const TextTheme(
      displayLarge: displayLarge,
      displayMedium: displayMedium,
      displaySmall: displaySmall,
      headlineLarge: headlineLarge,
      headlineMedium: headlineMedium,
      headlineSmall: headlineSmall,
      titleLarge: titleLarge,
      titleMedium: titleMedium,
      titleSmall: titleSmall,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
      labelLarge: labelLarge,
      labelMedium: labelMedium,
      labelSmall: labelSmall,
    ),
  );
  
  static final ThemeData darkTheme = ThemeData(
    fontFamily: fontFamily,
    primaryColor: vcbLightGreen,
    scaffoldBackgroundColor: vcbGrey900,
    colorScheme: ColorScheme.dark(
      primary: vcbLightGreen,
      secondary: vcbGreenAccent,
      surface: vcbGrey800,
      error: vcbError,
      onPrimary: vcbBlack,
      onSecondary: vcbBlack,
      onSurface: vcbWhite,
      onError: vcbWhite,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: vcbGrey900,
      foregroundColor: vcbWhite,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: headlineSmall.copyWith(color: vcbWhite),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: primaryButtonStyle.copyWith(
        backgroundColor: WidgetStateProperty.all(vcbLightGreen),
        foregroundColor: WidgetStateProperty.all(vcbBlack),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: secondaryButtonStyle.copyWith(
        foregroundColor: WidgetStateProperty.all(vcbLightGreen),
        side: WidgetStateProperty.all(
          const BorderSide(color: vcbLightGreen, width: 1.5),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: textButtonStyle.copyWith(
        foregroundColor: WidgetStateProperty.all(vcbLightGreen),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: vcbGrey700,
      thickness: 1,
      space: 0,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: vcbGrey900,
      selectedItemColor: vcbLightGreen,
      unselectedItemColor: vcbGrey500,
      selectedLabelStyle: labelMedium,
      unselectedLabelStyle: labelMedium,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    textTheme: TextTheme(
      displayLarge: displayLarge.copyWith(color: vcbWhite),
      displayMedium: displayMedium.copyWith(color: vcbWhite),
      displaySmall: displaySmall.copyWith(color: vcbWhite),
      headlineLarge: headlineLarge.copyWith(color: vcbWhite),
      headlineMedium: headlineMedium.copyWith(color: vcbWhite),
      headlineSmall: headlineSmall.copyWith(color: vcbWhite),
      titleLarge: titleLarge.copyWith(color: vcbWhite),
      titleMedium: titleMedium.copyWith(color: vcbWhite),
      titleSmall: titleSmall.copyWith(color: vcbWhite),
      bodyLarge: bodyLarge.copyWith(color: vcbGrey300),
      bodyMedium: bodyMedium.copyWith(color: vcbGrey300),
      bodySmall: bodySmall.copyWith(color: vcbGrey300),
      labelLarge: labelLarge.copyWith(color: vcbWhite),
      labelMedium: labelMedium.copyWith(color: vcbWhite),
      labelSmall: labelSmall.copyWith(color: vcbWhite),
    ),
  );
  
  // ===== LEGACY COMPATIBILITY =====
  static const Color primaryColor = vcbPrimaryGreen;
  static const Color white = vcbWhite;
  static const Color black = vcbBlack;
  static const Color primaryStart = vcbPrimaryGreen;
  static const Color primaryEnd = vcbDarkGreen;
  static const Color accentStart = vcbLightGreen;
  static const Color accentEnd = vcbGreenAccent;
  
  // Legacy animation curves
  static const Curve bounceInCurve = bounceCurve;
}
