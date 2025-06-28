// lib/main.dart
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:nover/features/auth/screens/welcome_screen.dart';
import 'package:nover/features/home/screens/home_page.dart';
import 'package:nover/src/repositories/auth_repository.dart';
import 'package:nover/src/services/navigation_service.dart'; // Import untuk kunci navigasi
import 'package:nover/src/theme/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- Global Notifiers ---
late ThemeProvider themeProvider;
late ValueNotifier<bool> lowPerformanceModeProvider;
late ValueNotifier<Map<String, dynamic>?> authNotifier;

// SharedPreferences Keys
const String THEME_PREF_KEY = 'app_theme_mode';
const String LANGUAGE_PREF_KEY = 'app_language_code';
const String LOW_PERFORMANCE_MODE_PREF_KEY = 'app_low_performance_mode';

void main() async {
  try {
    // 1. Pastikan semua binding siap sebelum menjalankan kode async
    WidgetsFlutterBinding.ensureInitialized();

    // 2. Konfigurasi env sekarang ditangani oleh argumen build.

    final prefs = await SharedPreferences.getInstance();

    // 3. Inisialisasi Auth State Terpusat
    final authRepository = AuthRepository();
    final initialUserData = await authRepository.getCurrentUser();
    authNotifier = ValueNotifier<Map<String, dynamic>?>(initialUserData);

    // 4. Inisialisasi Bahasa
    const String fallbackLocale = 'en';
    const List<String> supportedLocales = ['en', 'id'];
    String savedLanguage = prefs.getString(LANGUAGE_PREF_KEY) ?? fallbackLocale;
    var delegate = await LocalizationDelegate.create(
      fallbackLocale: fallbackLocale,
      supportedLocales: supportedLocales,
      basePath: 'assets/i18n',
    );
    await delegate.changeLocale(Locale(savedLanguage));

    // 5. Inisialisasi Tema
    String? savedThemeModeString = prefs.getString(THEME_PREF_KEY);
    ThemeMode initialThemeMode;
    if (savedThemeModeString == ThemeMode.dark.toString()) {
      initialThemeMode = ThemeMode.dark;
    } else if (savedThemeModeString == ThemeMode.light.toString()) {
      initialThemeMode = ThemeMode.light;
    } else {
      initialThemeMode = ThemeMode.light;
    }
    themeProvider = ThemeProvider(initialThemeMode);

    // 6. Inisialisasi Mode Performa Rendah
    bool initialLowPerformanceMode = prefs.getBool(LOW_PERFORMANCE_MODE_PREF_KEY) ?? false;
    lowPerformanceModeProvider = ValueNotifier<bool>(initialLowPerformanceMode);

    // Jika semua inisialisasi berhasil, jalankan aplikasi utama
    runApp(LocalizedApp(delegate, const MyApp()));
  } catch (error, stackTrace) {
    // Jika terjadi error FATAL selama inisialisasi, catat dan tampilkan layar error.
    developer.log(
        "=== FATAL ERROR DURING APP INITIALIZATION ===",
        error: error,
        stackTrace: stackTrace,
        name: "main.dart"
    );
    runApp(ErrorApp(error: error));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    var localizationDelegate = LocalizedApp.of(context).delegate;

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeProvider,
      builder: (context, currentMode, child) {
        return MaterialApp(
          // UBAH: Menambahkan kunci navigasi global
          navigatorKey: NavigationService.navigatorKey,
          key: ValueKey(localizationDelegate.currentLocale.toString()),
          title: 'Nover App',
          debugShowCheckedModeBanner: false,
          localizationsDelegates: [
            localizationDelegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: localizationDelegate.supportedLocales,
          locale: localizationDelegate.currentLocale,
          theme: lightTheme, // Pastikan Anda memiliki variabel lightTheme
          darkTheme: darkTheme, // Pastikan Anda memiliki variabel darkTheme
          themeMode: currentMode,
          // Aplikasi selalu dimulai dari MyHomePage
          home: const MyHomePage(),
        );
      },
    );
  }
}

/// Widget sederhana untuk menampilkan error startup.
class ErrorApp extends StatelessWidget {
  final Object error;
  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Application failed to start.\nPlease report this error.\n\nError: $error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
