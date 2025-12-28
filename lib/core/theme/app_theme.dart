import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Motivational Color Palette - "Egoistic" Design
  static const Color primaryPurple = Color(0xFF6C63FF);
  static const Color deepPurple = Color(0xFF4C43D4);
  static const Color luxuryGold = Color(0xFFFFD700);
  static const Color successGreen = Color(0xFF00C896);
  static const Color warningOrange = Color(0xFFFF6B6B);
  static const Color darkBackground = Color(0xFF0D1117);
  static const Color darkCard = Color(0xFF161B22);
  static const Color lightGrey = Color(0xFFF6F8FA);
  static const Color textLight = Color(0xFFE6EDF3);
  static const Color textDark = Color(0xFF24292F);

  // Gradient Definitions
  static const LinearGradient heroGradient = LinearGradient(
    colors: [primaryPurple, deepPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFB347)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [successGreen, Color(0xFF00A67C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Dark Theme (Primary)
  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        primarySwatch: MaterialColor(
          primaryPurple.value,
          _createMaterialColor(primaryPurple),
        ),
        scaffoldBackgroundColor: darkBackground,
        cardColor: darkCard,

        // Text Theme
        textTheme: GoogleFonts.poppinsTextTheme()
            .apply(bodyColor: textLight, displayColor: textLight)
            .copyWith(
              headlineLarge: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: textLight,
              ),
              headlineMedium: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: textLight,
              ),
              bodyLarge: GoogleFonts.poppins(fontSize: 16, color: textLight),
              bodyMedium: GoogleFonts.poppins(
                fontSize: 14,
                color: textLight.withOpacity(0.8),
              ),
            ),

        // App Bar Theme
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textLight,
          ),
          iconTheme: const IconThemeData(color: textLight),
        ),

        // Card Theme
        cardTheme: CardThemeData(
          color: darkCard,
          elevation: 8,
          shadowColor: primaryPurple.withOpacity(0.3),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),

        // Elevated Button Theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryPurple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Floating Action Button Theme
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: luxuryGold,
          foregroundColor: textDark,
          elevation: 12,
        ),

        // Input Decoration Theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: darkCard,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          hintStyle: GoogleFonts.poppins(color: textLight.withOpacity(0.6)),
        ),

        colorScheme: const ColorScheme.dark(
          primary: primaryPurple,
          secondary: luxuryGold,
          surface: darkCard,
          background: darkBackground,
          onPrimary: Colors.white,
          onSecondary: textDark,
          onSurface: textLight,
          onBackground: textLight,
        ),
      );

  // Light Theme
  static ThemeData get lightTheme => ThemeData(
        brightness: Brightness.light,
        primarySwatch: MaterialColor(
          primaryPurple.value,
          _createMaterialColor(primaryPurple),
        ),
        scaffoldBackgroundColor: lightGrey,
        cardColor: Colors.white,
        textTheme: GoogleFonts.poppinsTextTheme().apply(
          bodyColor: textDark,
          displayColor: textDark,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textDark,
          ),
          iconTheme: const IconThemeData(color: textDark),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 8,
          shadowColor: primaryPurple.withOpacity(0.1),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        colorScheme: const ColorScheme.light(
          primary: primaryPurple,
          secondary: luxuryGold,
          surface: Colors.white,
          background: lightGrey,
          onPrimary: Colors.white,
          onSecondary: textDark,
          onSurface: textDark,
          onBackground: textDark,
        ),
      );

  // Helper method to create Material Color
  static Map<int, Color> _createMaterialColor(Color color) {
    return {
      50: color.withOpacity(0.1),
      100: color.withOpacity(0.2),
      200: color.withOpacity(0.3),
      300: color.withOpacity(0.4),
      400: color.withOpacity(0.5),
      500: color,
      600: color.withOpacity(0.7),
      700: color.withOpacity(0.8),
      800: color.withOpacity(0.9),
      900: color.withOpacity(1.0),
    };
  }
}
