// lib/src/constants/app_constants.dart

/// Kunci-kunci yang digunakan untuk SharedPreferences di seluruh aplikasi.
class AppConstants {
  // Private constructor agar kelas ini tidak bisa di-instantiate.
  AppConstants._();

  static const String themePrefKey = 'app_theme_mode';
  static const String languagePrefKey = 'app_language_code';
  static const String lowPerformanceModePrefKey = 'app_low_performance_mode';
  static const String updateJsonUrl = 'https://drive.google.com/uc?export=download&id=1o2kNQ5S4zTydF58yS1LBvc95K73kwJkP';
}
