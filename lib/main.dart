import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:nover/features/home/screens/home_page.dart';
import 'package:nover/src/constants/app_constants.dart';
import 'package:nover/src/models/wallet.dart'; // ✨ 1. IMPORT BARU
import 'package:nover/src/repositories/auth_repository.dart';
import 'package:nover/src/repositories/wallet_repository.dart'; // ✨ 1. IMPORT BARU
import 'package:nover/src/services/navigation_service.dart';
import 'package:nover/src/theme/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- Global Notifiers ---
late ThemeProvider themeProvider;
late ValueNotifier<bool> lowPerformanceModeProvider;
late ValueNotifier<Map<String, dynamic>?> authNotifier;
late ValueNotifier<Wallet?> walletNotifier; // ✨ 2. DEKLARASI NOTIFIER BARU

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    await Supabase.initialize(
      url: const String.fromEnvironment('SUPABASE_URL'),
      anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
    );

    final prefs = await SharedPreferences.getInstance();

    final authRepository = AuthRepository();
    final initialUserData = await authRepository.getCurrentUser();
    authNotifier = ValueNotifier<Map<String, dynamic>?>(initialUserData);

    // ✨ 3. LOGIKA UNTUK MEMUAT DATA WALLET SAAT STARTUP
    walletNotifier = ValueNotifier<Wallet?>(null);
    if (initialUserData != null) {
      // Jika pengguna sudah login, langsung coba ambil data wallet-nya
      try {
        final walletRepository = WalletRepository();
        final initialWalletData = await walletRepository.getMyWallet();
        walletNotifier.value = initialWalletData;
      } catch (e) {
        developer.log(
            "Gagal memuat data wallet awal: $e",
            name: "main.dart"
        );
        // Biarkan app tetap berjalan meskipun wallet gagal dimuat
      }
    }

    const String fallbackLocale = 'en';
    const List<String> supportedLocales = ['en', 'id'];

    String savedLanguage = prefs.getString(AppConstants.languagePrefKey) ?? fallbackLocale;

    var delegate = await LocalizationDelegate.create(
      fallbackLocale: fallbackLocale,
      supportedLocales: supportedLocales,
      basePath: 'assets/i18n',
    );
    await delegate.changeLocale(Locale(savedLanguage));

    String? savedThemeModeString = prefs.getString(AppConstants.themePrefKey);
    ThemeMode initialThemeMode;
    if (savedThemeModeString == ThemeMode.dark.toString()) {
      initialThemeMode = ThemeMode.dark;
    } else {
      initialThemeMode = ThemeMode.light;
    }
    themeProvider = ThemeProvider(initialThemeMode);

    bool initialLowPerformanceMode = prefs.getBool(AppConstants.lowPerformanceModePrefKey) ?? false;
    lowPerformanceModeProvider = ValueNotifier<bool>(initialLowPerformanceMode);

    runApp(LocalizedApp(delegate, const MyApp()));
  } catch (error, stackTrace) {
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
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: currentMode,
          home: const MyHomePage(),
        );
      },
    );
  }
}

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
