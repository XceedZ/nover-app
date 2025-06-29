// lib/utils/app_fonts.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Nama family font ini harus cocok dengan yang didefinisikan di pubspec.yaml
const String _NCSFontFamily = 'NCS';

class AppFonts {
  // Konstruktor privat untuk mencegah instansiasi
  AppFonts._();

  /// TextStyle dasar untuk "header" menggunakan font Universo-Black.otf.
  static TextStyle get headerStyle {
    return const TextStyle(
      fontFamily: _NCSFontFamily,
      fontWeight: FontWeight.w900,
      color: Colors.black,
    );
  }

  /// TextStyle dasar untuk "title" menggunakan font Montserrat dari Google Fonts.
  static TextStyle get titleStyle {
    return GoogleFonts.montserrat(
      fontWeight: FontWeight.w600,
      color: Colors.black,
    );
  }

  // --- BARU: Metode khusus untuk judul AppBar ---
  /// TextStyle konsisten untuk judul AppBar (bold, ukuran dasar 18).
  /// Ukuran font sebaiknya di-override menggunakan `responsiveFontSize` di UI.
  static TextStyle appBarTitle({Color? color}) => GoogleFonts.montserrat(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: color,
  );
  // ------------------------------------------------

  /// TextStyle untuk displayLarge menggunakan Universo.
  static TextStyle displayLarge({Color? color}) => headerStyle.copyWith(fontSize: 57, letterSpacing: -0.25, color: color);
  /// TextStyle untuk displayMedium menggunakan Universo.
  static TextStyle displayMedium({Color? color}) => headerStyle.copyWith(fontSize: 45, letterSpacing: 0.0, color: color);
  /// TextStyle untuk displaySmall menggunakan Universo.
  static TextStyle displaySmall({Color? color}) => headerStyle.copyWith(fontSize: 36, letterSpacing: 0.0, color: color);

  /// TextStyle untuk headlineLarge menggunakan Universo.
  static TextStyle headlineLarge({Color? color}) => headerStyle.copyWith(fontSize: 32, letterSpacing: 0.0, color: color);
  /// TextStyle untuk headlineMedium menggunakan Universo.
  static TextStyle headlineMedium({Color? color}) => headerStyle.copyWith(fontSize: 28, letterSpacing: 0.0, color: color);
  /// TextStyle untuk headlineSmall menggunakan Universo.
  static TextStyle headlineSmall({Color? color}) => headerStyle.copyWith(fontSize: 24, letterSpacing: 0.0, color: color);

  /// TextStyle untuk titleLarge menggunakan Montserrat.
  static TextStyle titleLarge({Color? color}) => GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w500, letterSpacing: 0.0, color: color);
  /// TextStyle untuk titleMedium menggunakan Montserrat.
  static TextStyle titleMedium({Color? color}) => GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.15, color: color);
  /// TextStyle untuk titleSmall menggunakan Montserrat.
  static TextStyle titleSmall({Color? color}) => GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1, color: color);

  /// Menghasilkan TextTheme kustom.
  static TextTheme getCustomTextTheme(TextTheme baseMontserratTextTheme) {
    return baseMontserratTextTheme.copyWith(
      displayLarge: displayLarge(color: baseMontserratTextTheme.displayLarge?.color),
      displayMedium: displayMedium(color: baseMontserratTextTheme.displayMedium?.color),
      displaySmall: displaySmall(color: baseMontserratTextTheme.displaySmall?.color),
      headlineLarge: headlineLarge(color: baseMontserratTextTheme.headlineLarge?.color),
      headlineMedium: headlineMedium(color: baseMontserratTextTheme.headlineMedium?.color),
      headlineSmall: headlineSmall(color: baseMontserratTextTheme.headlineSmall?.color),
      titleLarge: titleLarge(color: baseMontserratTextTheme.titleLarge?.color),
      titleMedium: titleMedium(color: baseMontserratTextTheme.titleMedium?.color),
      titleSmall: titleSmall(color: baseMontserratTextTheme.titleSmall?.color),
    );
  }
}
