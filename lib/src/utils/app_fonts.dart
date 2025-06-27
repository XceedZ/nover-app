// lib/utils/app_fonts.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Nama family font ini harus cocok dengan yang didefinisikan di pubspec.yaml
const String _NCSFontFamily = 'NCS';

class AppFonts {
  // Konstruktor privat untuk mencegah instansiasi
  AppFonts._();

  /// TextStyle dasar untuk "header" menggunakan font Universo-Black.otf.
  /// Ukuran dan warna default dapat disesuaikan atau di-override saat penggunaan.
  static TextStyle get headerStyle {
    return const TextStyle(
      fontFamily: _NCSFontFamily,
      fontWeight: FontWeight.w900, // Sesuai dengan bobot "Black" (900) di pubspec
      color: Colors.black, // Warna default, bisa diubah
      // fontSize: 28.0, // Contoh ukuran default, bisa diatur sesuai kebutuhan
    );
  }

  /// TextStyle dasar untuk "title" menggunakan font Montserrat dari Google Fonts.
  /// Ukuran dan warna default dapat disesuaikan atau di-override saat penggunaan.
  static TextStyle get titleStyle {
    return GoogleFonts.montserrat( // Diubah dari Inter ke Montserrat
      fontWeight: FontWeight.w600, // Umumnya semi-bold untuk judul
      color: Colors.black, // Warna default, bisa diubah
      // fontSize: 20.0, // Contoh ukuran default, bisa diatur sesuai kebutuhan
    );
  }

  // --- Metode praktis untuk TextTheme Material Design 3 ---
  // Anda dapat menyesuaikan ukuran font ini agar sesuai dengan spesifikasi Desain Material
  // atau preferensi aplikasi Anda.

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

  // Untuk title menggunakan Montserrat (sebelumnya Inter)
  // Metode GoogleFonts.montserrat() sudah sangat fleksibel.

  /// TextStyle untuk titleLarge menggunakan Montserrat. (Cocok untuk AppBar titles)
  static TextStyle titleLarge({Color? color}) => GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w500, letterSpacing: 0.0, color: color); // Diubah ke Montserrat
  /// TextStyle untuk titleMedium menggunakan Montserrat.
  static TextStyle titleMedium({Color? color}) => GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.15, color: color); // Diubah ke Montserrat
  /// TextStyle untuk titleSmall menggunakan Montserrat.
  static TextStyle titleSmall({Color? color}) => GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1, color: color); // Diubah ke Montserrat

  // Body, Label, dll., akan menggunakan Montserrat dari tema dasar.

  /// Menghasilkan TextTheme kustom di mana elemen display dan headline menggunakan Universo,
  /// dan sisanya (yang sudah diatur ke Montserrat oleh baseTheme) tetap Montserrat.
  static TextTheme getCustomTextTheme(TextTheme baseMontserratTextTheme) { // Parameter diubah namanya untuk kejelasan
    return baseMontserratTextTheme.copyWith(
      displayLarge: displayLarge(color: baseMontserratTextTheme.displayLarge?.color),
      displayMedium: displayMedium(color: baseMontserratTextTheme.displayMedium?.color),
      displaySmall: displaySmall(color: baseMontserratTextTheme.displaySmall?.color),
      headlineLarge: headlineLarge(color: baseMontserratTextTheme.headlineLarge?.color),
      headlineMedium: headlineMedium(color: baseMontserratTextTheme.headlineMedium?.color),
      headlineSmall: headlineSmall(color: baseMontserratTextTheme.headlineSmall?.color),
      // titleLarge, titleMedium, titleSmall sudah Montserrat dari baseMontserratTextTheme.
      // Jika ingin override dengan gaya Montserrat spesifik dari atas:
      titleLarge: titleLarge(color: baseMontserratTextTheme.titleLarge?.color),
      titleMedium: titleMedium(color: baseMontserratTextTheme.titleMedium?.color),
      titleSmall: titleSmall(color: baseMontserratTextTheme.titleSmall?.color),
      // Body dan label styles juga akan tetap Montserrat dari baseMontserratTextTheme.
    );
  }
}