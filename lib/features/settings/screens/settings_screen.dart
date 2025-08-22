// lib/features/settings/screens/settings_screen.dart
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nover/src/utils/app_fonts.dart';
import 'package:nover/src/utils/ui_helpers.dart';
import 'package:remixicon/remixicon.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:nover/features/settings/widgets/language_selection_bottom_sheet.dart';
import 'package:nover/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nover/src/repositories/auth_repository.dart';
import 'package:nover/features/auth/screens/welcome_screen.dart';
import 'package:nover/src/constants/app_constants.dart';
import 'package:nover/src/widgets/custom_snackbar.dart'; // <-- IMPORT BARU
import 'package:nover/src/utils/translation.dart'; // <-- IMPORT BARU untuk tl()

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _cacheSizeString = "";
  String? _currentLanguageCode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        var delegate = LocalizedApp.of(context).delegate;
        setState(() {
          _currentLanguageCode = delegate.currentLocale.languageCode;
          _cacheSizeString = tl('settings.calculating_cache');
        });
        _calculateCacheSize();
      }
    });
  }

  Future<void> _calculateCacheSize() async {
    if (!mounted) return;
    final calculatingText = mounted ? tl('settings.calculating_cache') : "Calculating...";
    final errorText = mounted ? tl('settings.cache_error') : "Error";

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
    final AuthRepository authRepository = AuthRepository();
    await authRepository.logout();
    authNotifier.value = null;

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
      // UBAH: Menggunakan AppSnackbar yang sudah dibuat
      AppSnackbar.showSuccess(
        context,
        title: tl('settings.languageOptions.success'),
        message: tl('settings.languageOptions.cacheCleared'),
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
                _cacheSizeString = tl('settings.calculating_cache');
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
    bool currentLowPerformanceMode = lowPerformanceModeProvider.value;

    Color onSurfaceColor = theme.colorScheme.onSurface;
    Color subtleTextColor = theme.textTheme.bodySmall?.color ?? Colors.grey.shade600;
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
          tl('settings.title'),
          // UBAH: Menggunakan style yang benar
          style: AppFonts.appBarTitle(color: onSurfaceColor),
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
                          // UBAH: Menggunakan style yang benar
                          style: AppFonts.titleSmall(color: subtleTextColor),
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
                  },
                  trailing: CupertinoSwitch(
                    value: currentIsDarkMode,
                    activeColor: theme.colorScheme.primary,
                    onChanged: (bool value) {
                      themeProvider.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                    },
                  ),
                ),
                _buildSettingsItem(
                  context,
                  icon: Remix.dashboard_2_line,
                  titleKey: 'label.lowPerformanceMode',
                  iconColor: defaultSettingsIconColor,
                  onTap: () async {
                    final newValue = !lowPerformanceModeProvider.value;
                    lowPerformanceModeProvider.value = newValue;
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool(AppConstants.lowPerformanceModePrefKey, newValue);
                  },
                  trailing: CupertinoSwitch(
                    value: currentLowPerformanceMode,
                    activeColor: theme.colorScheme.primary,
                    onChanged: (bool value) async {
                      lowPerformanceModeProvider.value = value;
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool(AppConstants.lowPerformanceModePrefKey, value);
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
                      // UBAH: Menggunakan style yang benar
                      style: AppFonts.titleSmall(color: subtleTextColor),
                      overflow: TextOverflow.ellipsis,
                    ),
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
                backgroundColor: theme.colorScheme.error.withOpacity(0.1),
                padding: EdgeInsets.symmetric(vertical: responsiveFontSize(context, 15)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(cardBorderRadius),
                ),
              ),
              onPressed: _handleLogout,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Remix.logout_circle_r_line, color: theme.colorScheme.error, size: responsiveFontSize(context, 20)),
                  SizedBox(width: responsiveFontSize(context, 8)),
                  Text(
                    tl('settings.languageOptions.logOut'),
                    // UBAH: Menggunakan style yang benar
                    style: AppFonts.titleMedium(color: theme.colorScheme.error)?.copyWith(fontWeight: FontWeight.w600),
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
                : Border(bottom: BorderSide(color: theme.dividerColor.withOpacity(0.5), width: 0.6)),
          ),
          child: Row(
            children: [
              Icon(icon, size: responsiveFontSize(context, 22), color: finalIconColor),
              SizedBox(width: responsiveFontSize(context, 16)),
              Expanded(
                child: Text(
                  tl(titleKey),
                  // UBAH: Menggunakan style yang benar
                  style: AppFonts.titleMedium(color: theme.colorScheme.onSurface),
                ),
              ),
              if (trailing != null)
                trailing
              else if (onTap != null)
                Icon(Remix.arrow_right_s_line, color: Colors.grey.shade400, size: responsiveFontSize(context, 22)),
            ],
          ),
        ),
      ),
    );
  }
}
