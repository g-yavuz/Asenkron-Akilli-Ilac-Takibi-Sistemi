import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF4A90E2);
  static const Color primaryLight = Color(0xFFEBF3FD);
  static const Color success = Color(0xFF4CAF82);
  static const Color successLight = Color(0xFFE8F7F0);
  static const Color warning = Color(0xFFFF9F43);
  static const Color warningLight = Color(0xFFFFF3E5);
  static const Color critical = Color(0xFFFF5C5C);
  static const Color criticalLight = Color(0xFFFFEEEE);
  static const Color background = Color(0xFFF8FAFD);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1F36);
  static const Color textSecondary = Color(0xFF8F95B2);
  static const Color divider = Color(0xFFF0F2F8);
  static const Color navBackground = Color(0xFFFFFFFF);

  static ThemeData get theme => ThemeData(
        fontFamily: 'SF Pro Display',
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: background,
        appBarTheme: const AppBarTheme(
          backgroundColor: background,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
          iconTheme: IconThemeData(color: textPrimary),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: navBackground,
          selectedItemColor: primary,
          unselectedItemColor: textSecondary,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w400,
          ),
        ),
      );
}

class AppShadow {
  static List<BoxShadow> get card => [
        BoxShadow(
          color: const Color(0xFF4A90E2).withOpacity(0.06),
          blurRadius: 20,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get soft => [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];
}
