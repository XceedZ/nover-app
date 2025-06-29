import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Kunci untuk SharedPreferences (bisa juga didefinisikan di main.dart atau file config)
const String THEME_PREF_KEY = 'app_theme_mode';

class ThemeProvider extends ValueNotifier<ThemeMode> {
  ThemeProvider(ThemeMode initialMode) : super(initialMode);

  Future<void> _saveThemePreference(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(THEME_PREF_KEY, mode.toString());
    print("Theme preference saved: $mode");
  }

  void toggleTheme() {
    value = value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    print("Theme changed to: $value");
    _saveThemePreference(value); // Simpan preferensi tema
  }

  void setThemeMode(ThemeMode mode) {
    if (value != mode) {
      value = mode;
      print("Theme set to: $value");
      _saveThemePreference(value); // Simpan preferensi tema
    }
  }
}

// Definisikan tema terang dan gelap Anda di sini atau di file terpisah
// (Kode tema Anda tetap sama seperti yang Anda berikan sebelumnya)
ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    primary: Colors.black,
    onPrimary: Colors.white,
    secondary: Colors.grey.shade200,
    onSecondary: Colors.white,
    background: Colors.white,
    surface: Colors.white,
    onBackground: Colors.black,
    onSurface: Colors.black,
    error: Colors.red,
    onError: Colors.white,
    // Warna tambahan yang mungkin berguna
    primaryContainer: Colors.grey.shade100,
    onPrimaryContainer: Colors.black,
    secondaryContainer: Colors.grey.shade300,
    onSecondaryContainer: Colors.black,
    surfaceVariant: Colors.grey.shade200, // Untuk kartu, dll.
    onSurfaceVariant: Colors.black, // Teks di atas surfaceVariant
    outline: Colors.grey.shade400, // Untuk border
  ),
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    surfaceTintColor: Colors.white,
    elevation: 0.5,
    titleTextStyle: GoogleFonts.montserrat(
        color: Colors.black, fontWeight: FontWeight.w600, fontSize: 18),
  ),
  cardColor: Colors.white, // Warna default untuk Card
  dividerColor: Colors.grey.shade300, // Warna default untuk Divider
  // textTheme: AppFonts.getCustomTextTheme(GoogleFonts.montserratTextTheme(ThemeData.light().textTheme)),
  // fontFamily: GoogleFonts.montserrat().fontFamily,
);

ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    primary: Colors.amber,
    onPrimary: Colors.black,
    secondary: Colors.grey.shade800, // Sedikit lebih terang dari 900 untuk kontras
    onSecondary: Colors.white,
    background: const Color(0xFF121212),
    surface: const Color(0xFF1E1E1E),
    onBackground: Colors.white.withOpacity(0.87),
    onSurface: Colors.white.withOpacity(0.87),
    error: Colors.red.shade600, // Sedikit lebih terang untuk tema gelap
    onError: Colors.black,
    // Warna tambahan yang mungkin berguna
    primaryContainer: Colors.amber.shade900.withOpacity(0.5),
    onPrimaryContainer: Colors.amber.shade100,
    secondaryContainer: Colors.grey.shade700,
    onSecondaryContainer: Colors.white.withOpacity(0.87),
    surfaceVariant: const Color(0xFF2C2C2C), // Untuk kartu, dll. di tema gelap
    onSurfaceVariant: Colors.white.withOpacity(0.87), // Teks di atas surfaceVariant
    outline: Colors.grey.shade700, // Untuk border di tema gelap
  ),
  scaffoldBackgroundColor: const Color(0xFF121212),
  appBarTheme: AppBarTheme(
    backgroundColor: const Color(0xFF1E1E1E), // Sesuaikan agar konsisten dengan surface
    foregroundColor: Colors.white.withOpacity(0.87),
    surfaceTintColor: const Color(0xFF1E1E1E),
    elevation: 0.5,
    titleTextStyle: GoogleFonts.montserrat(
        color: Colors.white.withOpacity(0.87), fontWeight: FontWeight.w600, fontSize: 18),
  ),
  cardColor: const Color(0xFF1E1E1E), // Warna default untuk Card di tema gelap
  dividerColor: Colors.grey.shade800, // Warna default untuk Divider di tema gelap
  cupertinoOverrideTheme: CupertinoThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.amber.shade700, // Sesuaikan dengan primary color Anda
    scaffoldBackgroundColor: const Color(0xFF121212),
    textTheme: CupertinoTextThemeData(
      primaryColor: Colors.white.withOpacity(0.87),
      // Anda bisa menyesuaikan lebih lanjut jika perlu
    ),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
      if (states.contains(MaterialState.selected)) {
        return Colors.amber; // Warna thumb saat aktif
      }
      return Colors.grey.shade500; // Warna thumb saat tidak aktif
    }),
    trackColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
      if (states.contains(MaterialState.selected)) {
        return Colors.amber.withOpacity(0.5); // Warna track saat aktif
      }
      return Colors.grey.shade800; // Warna track saat tidak aktif
    }),
    trackOutlineColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
      if (states.contains(MaterialState.selected)) {
        return Colors.amber.withOpacity(0.2);
      }
      return Colors.grey.shade700;
    }),
  ),
  // textTheme: AppFonts.getCustomTextTheme(GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme)),
  // fontFamily: GoogleFonts.montserrat().fontFamily,
);