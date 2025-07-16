import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Vietcombank brand colors
  static const Color vcbGreen = Color(0xFF008B3A);
  static const Color vcbDarkGreen = Color(0xFF006B2C);
  static const Color vcbLightGreen = Color(0xFF00A344);
  static const Color vcbGreenAccent = Color(0xFF66C266);
  
  // Supporting colors
  static const Color vcbGrey = Color(0xFF5A5A5A);
  static const Color vcbLightGrey = Color(0xFFF5F5F5);
  static const Color vcbWhite = Color(0xFFFFFFFF);
  static const Color vcbBlack = Color(0xFF1A1A1A);
  
  // Semantic colors
  static const Color vcbSuccess = Color(0xFF00A344);
  static const Color vcbWarning = Color(0xFFF39C12);
  static const Color vcbError = Color(0xFFE74C3C);
  static const Color vcbInfo = Color(0xFF3498DB);
  
  // Legacy color names for compatibility
  static const Color primaryColor = vcbGreen;
  static const Color white = vcbWhite;
  static const Color black = vcbBlack;
  
  // Additional gradient colors
  static const Color primaryStart = vcbGreen;
  static const Color primaryEnd = vcbDarkGreen;
  static const Color accentStart = vcbLightGreen;
  static const Color accentEnd = vcbGreenAccent;

  // Text styles with Roboto font (VCB style)
  static TextTheme _textTheme = TextTheme(
    displayLarge: GoogleFonts.roboto(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: vcbBlack,
      letterSpacing: -0.5,
    ),
    displayMedium: GoogleFonts.roboto(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: vcbBlack,
      letterSpacing: -0.5,
    ),
    displaySmall: GoogleFonts.roboto(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: vcbBlack,
    ),
    headlineLarge: GoogleFonts.roboto(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: vcbBlack,
    ),
    headlineMedium: GoogleFonts.roboto(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: vcbBlack,
    ),
    headlineSmall: GoogleFonts.roboto(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: vcbBlack,
    ),
    titleLarge: GoogleFonts.roboto(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: vcbBlack,
    ),
    titleMedium: GoogleFonts.roboto(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: vcbBlack,
    ),
    titleSmall: GoogleFonts.roboto(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: vcbBlack,
    ),
    bodyLarge: GoogleFonts.roboto(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: vcbGrey,
    ),
    bodyMedium: GoogleFonts.roboto(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: vcbGrey,
    ),
    bodySmall: GoogleFonts.roboto(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: vcbGrey,
    ),
    labelLarge: GoogleFonts.roboto(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: vcbBlack,
      letterSpacing: 0.5,
    ),
    labelMedium: GoogleFonts.roboto(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: vcbBlack,
      letterSpacing: 0.5,
    ),
    labelSmall: GoogleFonts.roboto(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: vcbGrey,
      letterSpacing: 0.5,
    ),
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: vcbGreen,
    scaffoldBackgroundColor: vcbLightGrey,
    
    colorScheme: const ColorScheme.light(
      primary: vcbGreen,
      primaryContainer: vcbLightGreen,
      secondary: vcbDarkGreen,
      secondaryContainer: vcbGreenAccent,
      surface: vcbWhite,
      background: vcbLightGrey,
      error: vcbError,
      onPrimary: vcbWhite,
      onSecondary: vcbWhite,
      onSurface: vcbBlack,
      onBackground: vcbBlack,
      onError: vcbWhite,
    ),
    
    textTheme: _textTheme,
    
    appBarTheme: AppBarTheme(
      backgroundColor: vcbWhite,
      foregroundColor: vcbBlack,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.roboto(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: vcbBlack,
      ),
      iconTheme: const IconThemeData(color: vcbBlack),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: vcbGreen,
        foregroundColor: vcbWhite,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: vcbGreen,
        side: const BorderSide(color: vcbGreen, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: vcbGreen,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: vcbWhite,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: vcbGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: vcbError),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: vcbError, width: 2),
      ),
      labelStyle: GoogleFonts.roboto(
        fontSize: 14,
        color: vcbGrey,
      ),
      hintStyle: GoogleFonts.roboto(
        fontSize: 14,
        color: vcbGrey.withOpacity(0.6),
      ),
    ),
    
    cardTheme: CardThemeData(
      elevation: 0,
      color: vcbWhite,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: vcbGrey.withOpacity(0.1)),
      ),
    ),
    
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: vcbWhite,
      selectedItemColor: vcbGreen,
      unselectedItemColor: vcbGrey,
      selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 12),
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    
    dividerTheme: DividerThemeData(
      color: vcbGrey.withOpacity(0.1),
      thickness: 1,
      space: 1,
    ),
    
    iconTheme: const IconThemeData(
      color: vcbGrey,
      size: 24,
    ),
    
    chipTheme: ChipThemeData(
      backgroundColor: vcbLightGrey,
      selectedColor: vcbGreen.withOpacity(0.1),
      disabledColor: vcbGrey.withOpacity(0.1),
      labelStyle: GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: vcbBlack,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: vcbGrey.withOpacity(0.2)),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: vcbGreen,
    scaffoldBackgroundColor: const Color(0xFF121212),
    
    colorScheme: ColorScheme.dark(
      primary: vcbGreen,
      primaryContainer: vcbDarkGreen,
      secondary: vcbLightGreen,
      secondaryContainer: vcbGreenAccent,
      surface: const Color(0xFF1E1E1E),
      background: const Color(0xFF121212),
      error: vcbError,
      onPrimary: vcbWhite,
      onSecondary: vcbBlack,
      onSurface: vcbWhite,
      onBackground: vcbWhite,
      onError: vcbWhite,
    ),
    
    textTheme: _textTheme.apply(
      bodyColor: vcbWhite,
      displayColor: vcbWhite,
    ),
    
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF1E1E1E),
      foregroundColor: vcbWhite,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.roboto(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: vcbWhite,
      ),
      iconTheme: const IconThemeData(color: vcbWhite),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: vcbGreen,
        foregroundColor: vcbWhite,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    cardTheme: CardThemeData(
      elevation: 0,
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: vcbWhite.withOpacity(0.1)),
      ),
    ),
    
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      selectedItemColor: vcbGreen,
      unselectedItemColor: vcbGrey,
      selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 12),
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );

  // Animation durations
  static const Duration fastDuration = Duration(milliseconds: 200);
  static const Duration normalDuration = Duration(milliseconds: 300);
  static const Duration slowDuration = Duration(milliseconds: 500);
  static const Duration extraSlowDuration = Duration(milliseconds: 800);
  
  // Animation curves
  static const Curve smoothCurve = Curves.easeInOutCubic;
  static const Curve bounceInCurve = Curves.elasticOut;
  static const Curve fastOutSlowInCurve = Curves.fastOutSlowIn;
  static const Curve quickCurve = Curves.easeOutQuart;
  
  // Spacing
  static const double spacing1 = 4.0;
  static const double spacing2 = 8.0;
  static const double spacing3 = 12.0;
  static const double spacing4 = 16.0;
  static const double spacing5 = 20.0;
  static const double spacing6 = 24.0;
  static const double spacing7 = 28.0;
  static const double spacing8 = 32.0;
  static const double spacing9 = 36.0;
  static const double spacing10 = 40.0;
  static const double spacing12 = 48.0;
  
  // Border radius
  static const double radiusXS = 4.0;
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 20.0;
  static const double radius2XL = 24.0;
  static const double radiusFull = 999.0;
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [vcbGreen, vcbDarkGreen],
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [vcbLightGreen, vcbGreen],
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [vcbLightGrey, Colors.white],
  );
  
  // Shadows
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: vcbBlack.withOpacity(0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: vcbBlack.withOpacity(0.12),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
  
  // Helper methods
  static BoxDecoration glassMorphism({
    Color? color,
    double? borderRadius,
    List<BoxShadow>? boxShadow,
  }) {
    return BoxDecoration(
      color: color ?? vcbWhite.withOpacity(0.9),
      borderRadius: BorderRadius.circular(borderRadius ?? radiusMD),
      boxShadow: boxShadow ?? cardShadow,
      border: Border.all(
        color: vcbWhite.withOpacity(0.2),
        width: 1,
      ),
    );
  }
  
  // Text styles shortcuts
  static TextStyle get displayLarge => _textTheme.displayLarge!;
  static TextStyle get displayMedium => _textTheme.displayMedium!;
  static TextStyle get displaySmall => _textTheme.displaySmall!;
  static TextStyle get headlineLarge => _textTheme.headlineLarge!;
  static TextStyle get headlineMedium => _textTheme.headlineMedium!;
  static TextStyle get headlineSmall => _textTheme.headlineSmall!;
  static TextStyle get titleLarge => _textTheme.titleLarge!;
  static TextStyle get titleMedium => _textTheme.titleMedium!;
  static TextStyle get titleSmall => _textTheme.titleSmall!;
  static TextStyle get bodyLarge => _textTheme.bodyLarge!;
  static TextStyle get bodyMedium => _textTheme.bodyMedium!;
  static TextStyle get bodySmall => _textTheme.bodySmall!;
  static TextStyle get labelLarge => _textTheme.labelLarge!;
  static TextStyle get labelMedium => _textTheme.labelMedium!;
  static TextStyle get labelSmall => _textTheme.labelSmall!;
}

// Extension for easy color access
extension ThemeColors on BuildContext {
  Color get primaryColor => Theme.of(this).primaryColor;
  Color get vcbGreen => AppTheme.vcbGreen;
  Color get vcbDarkGreen => AppTheme.vcbDarkGreen;
  Color get vcbLightGreen => AppTheme.vcbLightGreen;
  Color get vcbSuccess => AppTheme.vcbSuccess;
  Color get vcbWarning => AppTheme.vcbWarning;
  Color get vcbError => AppTheme.vcbError;
  Color get vcbInfo => AppTheme.vcbInfo;
}
