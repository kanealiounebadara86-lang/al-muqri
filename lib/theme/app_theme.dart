import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Thème "bois" — mélange orange / jaune chaud, inspiré des tons bois
/// (façon pupitre en bois clair). Remplace l'ancienne palette grise.
class AppTheme {
  // ── Couleurs principales ─────────────────────────────────────────────
  static const Color primary = Color(0xFF8B4513); // Brun-orange (bois foncé)
  static const Color primaryLight = Color(0xFFB5651D);
  static const Color accent = Color(0xFFE8A33D); // Jaune-orange doré
  static const Color background = Color(0xFFFDF6E3); // Crème / bois très clair
  static const Color surface = Color(0xFFFFFCF5);
  static const Color surfaceVariant =
      Color(0xFFF5E6C8); // Jaune pâle (bois clair)
  static const Color primarySurface = Color(0xFFF5E6C8);
  static const Color border = Color(0xFFE6C99B); // Beige doré

  static const Color textPrimary = Color(0xFF4A2E12); // Brun foncé
  static const Color textSecondary = Color(0xFFA0703A); // Brun-orange clair
  static const Color textArabic = Color(0xFF3D2B1F);

  // ── Police arabe ──────────────────────────────────────────────────────
  static TextStyle arabicTextStyle({double fontSize = 26, Color? color}) =>
      TextStyle(
          fontFamily: 'Amiri',
          fontSize: fontSize,
          color: color ?? textArabic,
          height: 2.0);

  // ── ThemeData global ──────────────────────────────────────────────────
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
          primary: primary,
          secondary: accent,
          surface: surface,
        ),
        textTheme: GoogleFonts.poppinsTextTheme().copyWith(
          headlineSmall: GoogleFonts.poppins(
              fontSize: 18, fontWeight: FontWeight.w700, color: textPrimary),
          bodyMedium: GoogleFonts.poppins(fontSize: 14, color: textPrimary),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: background,
          foregroundColor: textPrimary,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
              fontSize: 17, fontWeight: FontWeight.w700, color: textPrimary),
        ),
        cardTheme: CardThemeData(
          color: surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: border)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primary,
            side: const BorderSide(color: border),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: primary),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: primary,
          inactiveTrackColor: border,
          thumbColor: primary,
          overlayColor: primary.withValues(alpha: 0.1),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.selected)
                  ? primary
                  : Colors.grey.shade400),
          trackColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.selected)
                  ? primary.withValues(alpha: 0.3)
                  : Colors.grey.shade200),
        ),
        dividerTheme: const DividerThemeData(color: border, thickness: 1),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: surface,
          indicatorColor: surfaceVariant,
          elevation: 0,
          labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: states.contains(WidgetState.selected)
                  ? primary
                  : textSecondary)),
        ),
      );
}

/// Style de texte arabe rapide (compat ancien code)
class ArabicTextStyle {
  static TextStyle of({double fontSize = 26, Color? color}) =>
      AppTheme.arabicTextStyle(fontSize: fontSize, color: color);
}
