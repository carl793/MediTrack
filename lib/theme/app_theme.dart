import 'package:flutter/material.dart';

class MediTrackColors {
  static const navy = Color(0xFF1A2A4E);
  static const navyLight = Color(0xFF2A3F6F);
  static const mint = Color(0xFF7FDBCA);
  static const mintLight = Color(0xFFB2EDE4);
  static const mintDark = Color(0xFF4DB8A4);
  static const coral = Color(0xFFFF6B6B);
  static const coralLight = Color(0xFFFFABAB);
  static const lavender = Color(0xFFF5F3FA);
  static const lavenderDeep = Color(0xFFEAE6F8);
  static const white = Color(0xFFFFFFFF);
  static const offWhite = Color(0xFFF8F9FA);
  static const gray = Color(0xFF8E8E93);
  static const grayLight = Color(0xFFE5E5EA);
  static const grayMedium = Color(0xFFAEAEB2);
  static const darkGray = Color(0xFF3A3A3C);
  static const surface = Color(0xFFFAFAFC);
  static const amber = Color(0xFFFFCC00);
}

class MediTrackTheme {
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: MediTrackColors.navy,
          brightness: Brightness.light,
          primary: MediTrackColors.navy,
          secondary: MediTrackColors.mint,
          surface: MediTrackColors.surface,
          error: MediTrackColors.coral,
        ),
        scaffoldBackgroundColor: MediTrackColors.surface,
        fontFamily: 'SF Pro Display',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: IconThemeData(color: MediTrackColors.navy),
          titleTextStyle: TextStyle(
            color: MediTrackColors.navy,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: MediTrackColors.mint,
            foregroundColor: MediTrackColors.navy,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: MediTrackColors.navy,
            letterSpacing: -0.8,
          ),
          displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: MediTrackColors.navy,
            letterSpacing: -0.5,
          ),
          headlineLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: MediTrackColors.navy,
            letterSpacing: -0.4,
          ),
          headlineMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: MediTrackColors.navy,
            letterSpacing: -0.3,
          ),
          headlineSmall: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: MediTrackColors.navy,
            letterSpacing: -0.2,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: MediTrackColors.darkGray,
            letterSpacing: -0.1,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: MediTrackColors.darkGray,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: MediTrackColors.gray,
          ),
          labelLarge: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: MediTrackColors.navy,
            letterSpacing: 0.5,
          ),
          labelMedium: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: MediTrackColors.gray,
            letterSpacing: 0.8,
          ),
          labelSmall: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: MediTrackColors.gray,
            letterSpacing: 1.0,
          ),
        ),
      );
}

class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

class AppRadius {
  static const sm = Radius.circular(8.0);
  static const md = Radius.circular(16.0);
  static const lg = Radius.circular(24.0);
  static const xl = Radius.circular(32.0);
  static const pill = Radius.circular(999.0);
}
