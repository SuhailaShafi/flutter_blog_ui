import 'package:flutter/material.dart';

class AppTheme {
  // Color palette
  static const Color primary = Color(0xFF6C63FF);
  static const Color secondary = Color(0xFFFF6584);
  static const Color accent = Color(0xFF43CBFF);
  static const Color surface = Color(0xFFF8F9FF);
  static const Color cardBg = Colors.white;

  static const List<Color> primaryGradient = [
    Color(0xFF6C63FF),
    Color(0xFF9B59B6),
  ];

  static const List<Color> headerGradient = [
    Color(0xFF6C63FF),
    Color(0xFF43CBFF),
  ];

  static const List<Color> authGradient = [
    Color(0xFF6C63FF),
    Color(0xFF9B59B6),
    Color(0xFFFF6584),
  ];

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
          primary: primary,
          secondary: secondary,
          surface: surface,
        ),
        scaffoldBackgroundColor: surface,
        cardTheme: CardThemeData(
          color: cardBg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadowColor: primary.withValues(alpha: 0.1),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
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
            borderSide: const BorderSide(color: primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: secondary),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          labelStyle: TextStyle(color: Colors.grey.shade600),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: primary.withValues(alpha: 0.15),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                  color: primary, fontWeight: FontWeight.w600, fontSize: 12);
            }
            return TextStyle(color: Colors.grey.shade600, fontSize: 12);
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: primary);
            }
            return IconThemeData(color: Colors.grey.shade500);
          }),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
              fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
          headlineMedium: TextStyle(
              fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
          headlineSmall: TextStyle(
              fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
          titleLarge: TextStyle(
              fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E)),
          titleMedium: TextStyle(
              fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E)),
          bodyLarge: TextStyle(color: Color(0xFF2D2D44), height: 1.6),
          bodyMedium: TextStyle(color: Color(0xFF4A4A6A)),
          bodySmall: TextStyle(color: Color(0xFF6B6B8A)),
        ),
      );
}
