// lib/features/settings/screens/settings_screen.dart
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nover/src/utils/app_fonts.dart';
import 'package:nover/src/utils/ui_helpers.dart';
import 'package:remixicon/remixicon.dart';
import 'package:path_provider/path_provider.dart';
import 'package:snackify/snackify.dart';
import 'package:snackify/enums/snack_enums.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:nover/features/settings/widgets/language_selection_bottom_sheet.dart';
import 'package:nover/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nover/src/repositories/auth_repository.dart'; // <-- TAMBAHKAN INI
import 'package:nover/features/auth/screens/welcome_screen.dart'; // <-- TAMBAHKAN INI

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _cacheSizeString = "";
  String? _currentLanguageCode;

  // Variabel untuk mode performa rendah tidak lagi dikelola sebagai state lokal di sini,
  // melainkan melalui lowPerformanceModeProvider global.

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        var delegate = LocalizedApp.of(context).delegate;
        setState(() {
          _currentLanguageCode = delegate.currentLocale.languageCode;
          _cacheSizeString = translate('settings.calculating_cache');
        });
        _calculateCacheSize();
      }
    });
  }

  Future<void> _calculateCacheSize() async {
    if (!mounted) return;
    final calculatingText = mounted ? translate('settings.calculating_cache') : "Calculating...";
    final errorText = mounted ? translate('settings.cache_error') : "Error";

    if (_cacheSizeString.isEmpty || _cacheSizeString == calculatingText || _cacheSizeString == "0 B" || _cacheSizeString == errorText) {
      if (mounted) {
        setState(() {
          _cacheSizeString = calculatingText;
        });
      }
    }
    int totalSize = 0;
    try {
      totalSize += PaintingBinding.instance.imageCache.currentSizeBytes;
      final tempDir = await getTemporaryDirectory();
      if (await tempDir.exists()) {
        final files = tempDir.listSync(recursive: true, followLinks: false);
        for (var fileEntity in files) {
          if (fileEntity is File) {
            try { totalSize += await fileEntity.length(); } catch (e) { /* ignore */ }
          }
        }
      }
    } catch (e) {
      print("Error calculating cache size: $e");
      if (mounted) {
        setState(() => _cacheSizeString = errorText);
      }
      return;
    }
    if (mounted) {
      setState(() {
        _cacheSizeString = _formatBytes(totalSize, 2);
      });
    }
  }

  Future<void> _handleLogout() async {
    // 1. Buat instance dari AuthRepository
    final AuthRepository authRepository = AuthRepository();

    // 2. Panggil fungsi logout dari repository
    // Ini akan memanggil API (jika ada) dan menghapus token dari secure storage
    await authRepository.logout();

    // 3. Update state global, beri tahu aplikasi bahwa tidak ada lagi pengguna yang login
    authNotifier.value = null;

    // 4. Navigasi ke WelcomeScreen dan hapus semua halaman sebelumnya dari tumpukan
    // Ini mencegah pengguna menekan tombol "kembali" untuk masuk lagi ke halaman yang dilindungi
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
            (route) => false,
      );
    }
  }

  String _formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = (bytes.abs().toString().length - 1) ~/ 3;
    if (i >= suffixes.length) i = suffixes.length - 1;
    num divisor = 1;
    for(int k=0; k<i; k++) { divisor *= 1000; }
    return '${(bytes / divisor).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  Future<void> _clearAppCache() async {
    if (!mounted) return;

    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();

    try {
      final tempDir = await getTemporaryDirectory();
      if (await tempDir.exists()) {
        final entities = tempDir.listSync(recursive: false);
        for (var entity in entities) {
          try {
            if (entity is File) {
              await entity.delete();
            }
          } catch (e) {
            print("Error deleting entity ${entity.path}: $e");
          }
        }
      }
    } catch (e) {
      print("Error accessing/clearing temp dir: $e");
    }

    await _calculateCacheSize();

    if (mounted) {
      Snackify.show(
        context: context,
        type: SnackType.success,
        title: Text(
          translate('settings.languageOptions.success'),
          style: GoogleFonts.montserrat(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        subtitle: Text(
          translate('settings.languageOptions.cacheCleared'),
          style: GoogleFonts.montserrat(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        position: SnackPosition.top,
        backgroundGradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary,
          ],
        ),
        duration: const Duration(seconds: 3),
      );
    }
  }

  void _showLanguageSelectionBottomSheet() {
    final String langCodeForBottomSheet = _currentLanguageCode ?? 'en';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext bc) {
        return LanguageSelectionBottomSheet(
          currentLanguageCode: langCodeForBottomSheet,
          onLanguageSelected: (String newLangCode) {
            if (mounted && newLangCode != _currentLanguageCode) {
              changeLocale(context, newLangCode);
              setState(() {
                _currentLanguageCode = newLangCode;
                _cacheSizeString = translate('settings.languageOptions.calculatingCache');
                _calculateCacheSize();
              });
            }
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    bool currentIsDarkMode = themeProvider.value == ThemeMode.dark;
    // Ambil nilai saat ini dari provider global
    bool currentLowPerformanceMode = lowPerformanceModeProvider.value;

    Color onSurfaceColor = theme.colorScheme.onSurface;
    Color subtleTextColor = Colors.grey.shade600;
    Color settingsGroupBackgroundColor = theme.cardColor;
    List<BoxShadow> cardBoxShadow = [
      BoxShadow(
        color: theme.shadowColor.withOpacity(0.05),
        spreadRadius: 1,
        blurRadius: 6,
        offset: const Offset(0, 3),
      ),
    ];
    double cardBorderRadius = responsiveFontSize(context, 16);
    Color defaultSettingsIconColor = onSurfaceColor.withOpacity(0.8);

    String displayCacheSize = _cacheSizeString;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.cardColor,
        elevation: 0.5,
        surfaceTintColor: theme.appBarTheme.surfaceTintColor ?? theme.cardColor,
        leading: IconButton(
          icon: Icon(Remix.arrow_left_s_line, color: onSurfaceColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          translate('settings.title'),
          style: (AppFonts.titleLarge(color: onSurfaceColor) ?? TextStyle(color: onSurfaceColor, fontSize: 20))
              .copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(
            vertical: responsiveFontSize(context, 20),
            horizontal: responsiveFontSize(context, 16)
        ),
        children: [
          _buildSettingsGroupContainer(
              context: context,
              backgroundColor: settingsGroupBackgroundColor,
              borderRadius: cardBorderRadius,
              boxShadow: cardBoxShadow,
              children: [
                _buildSettingsItem(
                  context,
                  icon: Remix.shield_keyhole_line,
                  titleKey: 'settings.accountSecurity',
                  onTap: () { print('Account Security Tapped'); },
                  iconColor: defaultSettingsIconColor,
                ),
                _buildSettingsItem(
                  context,
                  icon: Remix.notification_3_line,
                  titleKey: 'settings.notifications',
                  iconColor: defaultSettingsIconColor,
                  trailing: CupertinoSwitch(
                    value: _notificationsEnabled,
                    activeColor: theme.colorScheme.primary,
                    onChanged: (bool value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                  ),
                  isLastItemInGroup: true,
                ),
              ]
          ),
          SizedBox(height: responsiveFontSize(context, 20)),

          _buildSettingsGroupContainer(
              context: context,
              backgroundColor: settingsGroupBackgroundColor,
              borderRadius: cardBorderRadius,
              boxShadow: cardBoxShadow,
              children: [
                _buildSettingsItem(
                    context,
                    icon: Remix.translate_2,
                    titleKey: 'settings.language',
                    onTap: _showLanguageSelectionBottomSheet,
                    iconColor: defaultSettingsIconColor,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _currentLanguageCode == 'en' ? 'English' : 'Indonesia',
                          style: GoogleFonts.montserrat(fontSize: responsiveFontSize(context, 13), color: subtleTextColor),
                        ),
                        SizedBox(width: responsiveFontSize(context, 4)),
                        Icon(Remix.arrow_right_s_line, color: subtleTextColor, size: responsiveFontSize(context, 20)),
                      ],
                    )
                ),
                _buildSettingsItem(
                  context,
                  icon: Remix.moon_fill,
                  titleKey: 'settings.languageOptions.darkMode',
                  iconColor: defaultSettingsIconColor,
                  onTap: () {
                    themeProvider.toggleTheme();
                    // setState diperlukan jika Anda ingin UI SettingsScreen langsung update tanpa ValueListenableBuilder di root MyApp
                    // Namun, jika MyApp sudah menangani rebuild, ini mungkin tidak perlu. Untuk konsistensi:
                    setState(() {});
                  },
                  trailing: CupertinoSwitch(
                    value: currentIsDarkMode,
                    activeColor: theme.colorScheme.primary,
                    onChanged: (bool value) {
                      themeProvider.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                      // setState(() {}); // Dikelola oleh ValueListenableBuilder di MyApp jika ada, atau panggil setState jika ingin perubahan segera
                    },
                  ),
                ),
                // BARIS BARU UNTUK MODE PERFORMA RENDAH
                _buildSettingsItem(
                  context,
                  icon: Remix.dashboard_2_line, // Ikon untuk performa
                  titleKey: 'label.lowPerformanceMode', // Kunci terjemahan baru
                  iconColor: defaultSettingsIconColor,
                  onTap: () async { // Jadikan onTap async
                    final newValue = !lowPerformanceModeProvider.value;
                    lowPerformanceModeProvider.value = newValue;
                    // Simpan ke SharedPreferences
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool(LOW_PERFORMANCE_MODE_PREF_KEY, newValue);
                    if (mounted) setState(() {}); // Rebuild UI untuk update switch
                  },
                  trailing: CupertinoSwitch(
                    value: currentLowPerformanceMode,
                    activeColor: theme.colorScheme.primary,
                    onChanged: (bool value) async { // Jadikan onChanged async
                      lowPerformanceModeProvider.value = value;
                      // Simpan ke SharedPreferences
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool(LOW_PERFORMANCE_MODE_PREF_KEY, value);
                      // setState di sini mungkin tidak perlu jika ValueListenableBuilder digunakan
                      // di level atas untuk me-rebuild SettingsScreen ketika lowPerformanceModeProvider berubah.
                      // Namun, untuk memastikan switch langsung update, setState() aman digunakan.
                      if (mounted) setState(() {});
                    },
                  ),
                ),
                _buildSettingsItem(
                  context,
                  icon: Remix.delete_bin_6_line,
                  titleKey: 'settings.languageOptions.clearCache',
                  onTap: _clearAppCache,
                  iconColor: Colors.red.shade600,
                  trailing: SizedBox(
                    width: responsiveFontSize(context, 80),
                    child: Text(
                      displayCacheSize,
                      textAlign: TextAlign.end,
                      style: GoogleFonts.montserrat(fontSize: responsiveFontSize(context, 13), color: subtleTextColor),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  isLastItemInGroup: true, // Sekarang item ini menjadi yang terakhir di grup
                ),
              ]
          ),
          SizedBox(height: responsiveFontSize(context, 20)),

          _buildSettingsGroupContainer(
              context: context,
              backgroundColor: settingsGroupBackgroundColor,
              borderRadius: cardBorderRadius,
              boxShadow: cardBoxShadow,
              children: [
                _buildSettingsItem(
                  context,
                  icon: Remix.file_shield_2_line,
                  titleKey: 'settings.languageOptions.privacyPolicy',
                  iconColor: defaultSettingsIconColor,
                  onTap: () { print('Privacy Policy Tapped'); },
                ),
                _buildSettingsItem(
                  context,
                  icon: Remix.information_line,
                  titleKey: 'settings.languageOptions.aboutUs',
                  iconColor: defaultSettingsIconColor,
                  onTap: () { print('About Us Tapped'); },
                  isLastItemInGroup: true,
                ),
              ]
          ),
          SizedBox(height: responsiveFontSize(context, 30)),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: responsiveFontSize(context, 16.0)),
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.08),
                padding: EdgeInsets.symmetric(vertical: responsiveFontSize(context, 15)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(cardBorderRadius),
                ),
              ),
              onPressed: _handleLogout,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Remix.logout_circle_r_line, color: Colors.red.shade700, size: responsiveFontSize(context, 20)),
                  SizedBox(width: responsiveFontSize(context, 8)),
                  Text(
                    translate('settings.languageOptions.logOut'),
                    style: GoogleFonts.montserrat(
                      fontSize: responsiveFontSize(context, 15),
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: responsiveFontSize(context, 20)),
        ],
      ),
    );
  }

  Widget _buildSettingsGroupContainer({
    required BuildContext context,
    required List<Widget> children,
    required Color backgroundColor,
    required double borderRadius,
    required List<BoxShadow> boxShadow,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: boxShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
      BuildContext context, {
        required IconData icon,
        required String titleKey,
        Widget? trailing,
        VoidCallback? onTap,
        Color? iconColor,
        bool isLastItemInGroup = false,
      }) {
    ThemeData theme = Theme.of(context);
    Color finalIconColor = iconColor ?? theme.colorScheme.onSurface.withOpacity(0.8);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: responsiveFontSize(context, 16),
              vertical: responsiveFontSize(context, 15)
          ),
          decoration: BoxDecoration(
            border: isLastItemInGroup
                ? null
                : Border(bottom: BorderSide(color: theme.dividerColor.withOpacity(0.5), width: 0.6)), // Menggunakan theme.dividerColor
          ),
          child: Row(
            children: [
              Icon(icon, size: responsiveFontSize(context, 22), color: finalIconColor),
              SizedBox(width: responsiveFontSize(context, 16)),
              Expanded(
                child: Text(
                    translate(titleKey),
                    style: AppFonts.titleMedium(color: theme.colorScheme.onSurface).copyWith(
                      fontSize: responsiveFontSize(context, 14.5),
                    )
                ),
              ),
              if (trailing != null)
                trailing
              else if (onTap != null) // Hanya tampilkan panah jika ada onTap dan tidak ada trailing
                Icon(Remix.arrow_right_s_line, color: Colors.grey.shade400, size: responsiveFontSize(context, 22)),
            ],
          ),
        ),
      ),
    );
  }
}