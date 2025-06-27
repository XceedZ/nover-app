import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nover/src/utils/ui_helpers.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:remixicon/remixicon.dart';
import 'package:nover/src/utils/app_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 1. Impor SharedPreferences
import 'package:nover/main.dart'; // 2. Impor main.dart untuk LANGUAGE_PREF_KEY

// LANGUAGE_PREF_KEY sudah didefinisikan di main.dart dan diimpor.

class LanguageInfo {
  final String code;
  final String nameKey;
  final String flagAssetPath;

  LanguageInfo({
    required this.code,
    required this.nameKey,
    required this.flagAssetPath,
  });

  String getTranslatedName(BuildContext context) {
    return translate(nameKey);
  }
}

class LanguageSelectionBottomSheet extends StatelessWidget {
  final String currentLanguageCode;
  final Function(String) onLanguageSelected;

  const LanguageSelectionBottomSheet({
    super.key,
    required this.currentLanguageCode,
    required this.onLanguageSelected,
  });

  // 3. Fungsi untuk menyimpan preferensi bahasa
  Future<void> _saveLanguagePreference(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(LANGUAGE_PREF_KEY, languageCode);
    print('Language preference saved from BottomSheet: $languageCode');
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    final Color sheetBackgroundColor = theme.colorScheme.surface;
    final Color onSheetColor = theme.colorScheme.onSurface;
    final Color dividerColor = theme.dividerColor;
    final Color iconColor = onSheetColor.withOpacity(0.7);
    final Color primaryColor = theme.colorScheme.primary;

    final List<LanguageInfo> supportedLanguages = [
      LanguageInfo(
          code: 'en',
          nameKey: 'settings.languageOptions.enUs',
          flagAssetPath: 'assets/flags/us.png'),
      LanguageInfo(
          code: 'id',
          nameKey: 'settings.languageOptions.id',
          flagAssetPath: 'assets/flags/id.png'),
    ];

    return FractionallySizedBox(
      heightFactor: 0.55,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
        child: Container(
          color: sheetBackgroundColor,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                    responsiveFontSize(context, 16.0),
                    responsiveFontSize(context, 16.0),
                    responsiveFontSize(context, 8.0),
                    responsiveFontSize(context, 12.0)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      translate('settings.language'),
                      style: AppFonts.titleLarge(color: onSheetColor).copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: responsiveFontSize(context, 18)),
                    ),
                    IconButton(
                      icon: Icon(Remix.close_line,
                          color: iconColor,
                          size: responsiveFontSize(context, 24.0)),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              Divider(color: dividerColor, height: 1),
              Expanded(
                child: ListView.separated(
                  itemCount: supportedLanguages.length,
                  padding: EdgeInsets.symmetric(
                      vertical: responsiveFontSize(context, 8)),
                  itemBuilder: (BuildContext listContext, int index) {
                    final lang = supportedLanguages[index];
                    final bool isSelected = lang.code == currentLanguageCode;
                    return ListTile(
                      leading: Image.asset(
                        lang.flagAssetPath,
                        width: responsiveFontSize(context, 28),
                        height: responsiveFontSize(context, 28),
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Remix.earth_line,
                              size: responsiveFontSize(context, 28),
                              color: iconColor);
                        },
                      ),
                      title: Text(
                        lang.getTranslatedName(context),
                        style: GoogleFonts.montserrat(
                          fontSize: responsiveFontSize(context, 15),
                          color: isSelected ? primaryColor : onSheetColor,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Remix.check_line,
                          color: primaryColor,
                          size: responsiveFontSize(context, 22))
                          : null,
                      onTap: () async { // 4. Jadikan onTap async
                        if (lang.code != currentLanguageCode) {
                          // Panggil changeLocale dari flutter_translate
                          changeLocale(context, lang.code);
                          // Simpan preferensi bahasa
                          await _saveLanguagePreference(lang.code);
                          // Panggil callback ke parent widget (SettingsScreen)
                          // agar parent bisa update UI-nya jika perlu
                          onLanguageSelected(lang.code);
                        }
                        Navigator.pop(context);
                      },
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: responsiveFontSize(context, 20),
                          vertical: responsiveFontSize(context, 6)),
                    );
                  },
                  separatorBuilder: (context, index) => Divider(
                      color: dividerColor.withOpacity(0.5),
                      height: 0.5,
                      indent: responsiveFontSize(context, 20),
                      endIndent: responsiveFontSize(context, 20)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}