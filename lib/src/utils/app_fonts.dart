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

  // --- GAYA FONT MONTSERRAT ---

  /// TextStyle konsisten untuk judul AppBar.
  static TextStyle appBarTitle({Color? color}) => GoogleFonts.montserrat(
    fontSize: 18,
    fontWeight: FontWeight.w600, // Semi-bold
    color: color,
  );

  /// Ukuran terbesar untuk judul utama halaman (display).
  static TextStyle displayLargeM({Color? color}) => GoogleFonts.montserrat(fontSize: 40, fontWeight: FontWeight.w700, color: color);

  /// Ukuran besar untuk judul (headline).
  static TextStyle headlineLargeM({Color? color}) => GoogleFonts.montserrat(fontSize: 32, fontWeight: FontWeight.w700, color: color);
  static TextStyle headlineMediumM({Color? color}) => GoogleFonts.montserrat(fontSize: 28, fontWeight: FontWeight.w700, color: color);
  static TextStyle headlineSmallM({Color? color}) => GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.w700, color: color);

  /// Ukuran standar untuk judul (title).
  static TextStyle titleLarge({Color? color}) => GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w600, color: color); // Semi-bold
  static TextStyle titleMedium({Color? color}) => GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.15, color: color); // Medium
  static TextStyle titleSmall({Color? color}) => GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1, color: color); // Medium

  /// Ukuran untuk teks isi (body).
  static TextStyle bodyLarge({Color? color}) => GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5, color: color); // Regular
  static TextStyle bodyMedium({Color? color}) => GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25, color: color); // Regular
  static TextStyle bodySmall({Color? color}) => GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4, color: color); // Regular

  /// BARU: Ukuran khusus untuk label kecil atau "tag".
  static TextStyle labelSmall({Color? color}) => GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5, color: color); // Medium
  static TextStyle labelTiny({Color? color}) => GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5, color: color); // Semi-bold


  // --- GAYA FONT NCS (CUSTOM) ---

  static TextStyle displayLarge({Color? color}) => headerStyle.copyWith(fontSize: 57, letterSpacing: -0.25, color: color);
  static TextStyle displayMedium({Color? color}) => headerStyle.copyWith(fontSize: 45, letterSpacing: 0.0, color: color);
  static TextStyle displaySmall({Color? color}) => headerStyle.copyWith(fontSize: 36, letterSpacing: 0.0, color: color);

  static TextStyle headlineLarge({Color? color}) => headerStyle.copyWith(fontSize: 32, letterSpacing: 0.0, color: color);
  static TextStyle headlineMedium({Color? color}) => headerStyle.copyWith(fontSize: 28, letterSpacing: 0.0, color: color);
  static TextStyle headlineSmall({Color? color}) => headerStyle.copyWith(fontSize: 24, letterSpacing: 0.0, color: color);

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
      bodyLarge: bodyLarge(color: baseMontserratTextTheme.bodyLarge?.color),
      bodyMedium: bodyMedium(color: baseMontserratTextTheme.bodyMedium?.color),
      bodySmall: bodySmall(color: baseMontserratTextTheme.bodySmall?.color),
      labelSmall: labelSmall(color: baseMontserratTextTheme.labelSmall?.color),
    );
  }
}
