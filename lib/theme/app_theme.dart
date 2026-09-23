import 'package:flutter/material.dart';

// ── Global Design Tokens ───────────────────────────────────────────────────
// Based on Google Stitch prototype reference
// Typeface: Plus Jakarta Sans (fallback: Manrope)
// Grid: 4px base unit
// Background: #F9F8FE

class MediTrackColors {
  // Primary
  static const navy = Color(0xFF00618F);       // brand navy — buttons, icons, labels
  static const navyDark = Color(0xFF004E72);   // pressed/deeper navy
  static const navyLight = Color(0xFF136692);  // secondary navy uses

  // Backgrounds
  static const pageBg = Color(0xFFF9F8FE);     // page background — pale lavender-white
  static const cardBg = Color(0xFFFFFFFF);     // card surface
  static const lavenderChip = Color(0xFFEAEDFF); // chip/badge fills
  static const lavenderLight = Color(0xFFE2E6FF); // accent circle bg (morning sun)
  static const paleBlue = Color(0xFFDEEFFF);   // halo circle behind bottle illustration
  static const paleBlueBadge = Color(0xFFE2E6FF); // step number circle bg

  // Text
  static const textPrimary = Color(0xFF0A0A14);  // headlines, body primary
  static const textSecondary = Color(0xFF3C3C44); // body secondary
  static const textMuted = Color(0xFF5A5A62);     // labels, captions

  // Semantic
  static const emerald = Color(0xFF0C7A50);    // connected dot, positive indicator
  static const mint = Color(0xFF7FDBCA);       // taken/success (kept for state cards)
  static const mintDark = Color(0xFF4DB8A4);
  static const coral = Color(0xFFFF6B6B);      // missed/error
  static const coralLight = Color(0xFFFFABAB);
  static const amber = Color(0xFF7A5400);      // sun icon — muted burnt-gold
  static const green = Color(0xFF345B56);      // past-day dot

  // Day strip
  static const dayDotPast = Color(0xFF345B56);      // past days — dark muted green
  static const dayDotFuture = Color(0xFFE0E0F5);    // future days — near-invisible

  // Misc
  static const white = Color(0xFFFFFFFF);
  static const divider = Color(0xFFEEEEF5);
  static const grayLight = Color(0xFFE5E5EA);
  static const grayMedium = Color(0xFFAEAEB2);

  // ── Backward-compatible aliases (old names used across screen files) ──────
  static const navy2 = navy;
  static const navyLight2 = navyLight;
  static const surface = pageBg;          // old: MediTrackColors.surface
  static const lavender = lavenderChip;   // old: MediTrackColors.lavender
  static const lavenderDeep = Color(0xFFE2E6FF); // old: MediTrackColors.lavenderDeep
  static const gray = textMuted;          // old: MediTrackColors.gray
  static const darkGray = textSecondary;  // old: MediTrackColors.darkGray
  static const navy3 = Color(0xFF1A2A4E); // keep old navy shade for screens that hardcoded it
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
  static const card = 20.0;
  static const button = 16.0;       // primary button — rounded rect, NOT pill
  static const chip = 999.0;        // fully-rounded chips
  static const pill = 999.0;        // alias for chip
  static const dayCard = 14.0;
  static const stepBadge = 999.0;
  static const small = 8.0;
  static const sm = Radius.circular(8.0);
  static const md = Radius.circular(16.0);
  static const lg = Radius.circular(24.0);
}

class MediTrackTheme {
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        fontFamily: 'PlusJakartaSans',
        colorScheme: ColorScheme.fromSeed(
          seedColor: MediTrackColors.navy,
          brightness: Brightness.light,
          primary: MediTrackColors.navy,
          surface: MediTrackColors.pageBg,
        ),
        scaffoldBackgroundColor: MediTrackColors.pageBg,
        appBarTheme: const AppBarTheme(
          backgroundColor: MediTrackColors.pageBg,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: IconThemeData(color: MediTrackColors.textPrimary),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: MediTrackColors.textPrimary,
            letterSpacing: -0.3,
          ),
          headlineLarge: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: MediTrackColors.textPrimary,
          ),
          headlineMedium: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: MediTrackColors.textPrimary,
          ),
          headlineSmall: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: MediTrackColors.textPrimary,
          ),
          bodyLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: MediTrackColors.textSecondary,
            height: 1.5,
          ),
          bodyMedium: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: MediTrackColors.textMuted,
          ),
          labelLarge: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: MediTrackColors.white,
          ),
          labelSmall: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: MediTrackColors.navy,
            letterSpacing: 0.88,
          ),
        ),
      );
}

/// Standard card shadow — barely-there elevation
List<BoxShadow> get cardShadow => [
      BoxShadow(
        color: const Color(0xFF000000).withValues(alpha: 0.06),
        blurRadius: 12,
        offset: const Offset(0, 2),
        spreadRadius: 0,
      ),
    ];
