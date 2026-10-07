import 'package:flutter/material.dart';

class AppTheme {
  // 4-Tone Violet Palette (#2E073F, #7A1CAC, #AD49E1, #EBD3F8)
  static const Color darkPlum = Color(0xFF2E073F);      // Tone 1: Midnight Plum (#2E073F)
  static const Color royalPurple = Color(0xFF7A1CAC);  // Tone 2: Royal Purple (#7A1CAC)
  static const Color orchidPurple = Color(0xFFAD49E1); // Tone 3: Orchid Purple (#AD49E1)
  static const Color softLilac = Color(0xFFEBD3F8);    // Tone 4: Soft Lilac (#EBD3F8)

  // Dark Mode Specialized Shades (Derived harmoniously from Tone 1)
  static const Color darkBackground = Color(0xFF14021E); // Deep midnight purple-black
  static const Color darkSurface = Color(0xFF260533);    // Midnight Plum card/dialog surface
  static const Color darkSurfaceElevated = Color(0xFF350A47); // Elevated surface for inputs/chips
  static const Color darkBorder = Color(0xFF4C1066);     // Refined purple border

  // Semantic UI Roles
  static const Color primaryColor = royalPurple;       // Main Brand & Action Color (#7A1CAC)
  static const Color primaryLight = softLilac;         // Light Surface & Chips Tint (#EBD3F8)
  static const Color secondaryColor = orchidPurple;    // Accents & Gradients (#AD49E1)
  static const Color accentColor = orchidPurple;       // Highlights (#AD49E1)
  static const Color darkAccent = darkPlum;            // Deep Dark Plum (#2E073F)

  // Light Mode Colors
  static const Color backgroundColor = Color(0xFFFAF7FD);
  static const Color surfaceColor = Colors.white;
  static const Color textPrimary = darkPlum;           // Deep Midnight Plum Text (#2E073F)
  static const Color textSecondary = Color(0xFF6B587B);// Plum-gray secondary text

  // Status colors
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color dangerColor = Color(0xFFEF4444);

  // Dynamic Theme Helpers
  static Color textPrimaryOf(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFF7EFFF)
        : darkPlum;
  }

  static Color textSecondaryOf(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFC7B1DC)
        : const Color(0xFF6B587B);
  }

  static Color surfaceOf(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSurface
        : surfaceColor;
  }

  static Color primaryLightOf(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSurfaceElevated
        : softLilac;
  }

  static Color borderOf(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBorder
        : Colors.grey.shade200;
  }

  /// Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: backgroundColor,
      cardColor: surfaceColor,
      dividerColor: Colors.grey.shade200,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: darkPlum),
        titleTextStyle: TextStyle(
          color: darkPlum,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: dangerColor),
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: softLilac,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primaryColor);
          }
          return const IconThemeData(color: Color(0xFF756382));
        }),
      ),
    );
  }

  /// Dark Theme (Midnight Plum & Violet)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: orchidPurple,
        onPrimary: Colors.white,
        secondary: royalPurple,
        onSecondary: Colors.white,
        surface: darkSurface,
        onSurface: Color(0xFFF7EFFF),
        outline: darkBorder,
      ),
      scaffoldBackgroundColor: darkBackground,
      cardColor: darkSurface,
      dividerColor: darkBorder,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Color(0xFFF7EFFF)),
        titleTextStyle: TextStyle(
          color: Color(0xFFF7EFFF),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: royalPurple,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceElevated,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: const TextStyle(color: Color(0xFFC7B1DC)),
        hintStyle: const TextStyle(color: Color(0xFF886E9D)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: orchidPurple, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: dangerColor),
        ),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: darkBorder, width: 0.8),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkBackground,
        indicatorColor: darkSurfaceElevated,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: orchidPurple);
          }
          return const IconThemeData(color: Color(0xFF9881A8));
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(color: Color(0xFFF7EFFF), fontWeight: FontWeight.bold, fontSize: 12);
          }
          return const TextStyle(color: Color(0xFF9881A8), fontSize: 12);
        }),
      ),
    );
  }
}
