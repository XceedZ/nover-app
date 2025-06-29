// lib/features/settings/widgets/language_selection_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:nover/src/constants/app_constants.dart'; // <-- 1. IMPORT BARU
import 'package:nover/src/utils/app_fonts.dart';
import 'package:nover/src/utils/translation.dart';
import 'package:remixicon/remixicon.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    return tl(nameKey);
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

  Future<void> _saveLanguagePreference(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    // UBAH: Menggunakan konstanta dari AppConstants untuk konsistensi
    await prefs.setString(AppConstants.languagePrefKey, languageCode);
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

    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.4,
      decoration: BoxDecoration(
        color: sheetBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 8, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tl('settings.language'),
                  style: AppFonts.appBarTitle(color: onSheetColor),
                ),
                IconButton(
                  icon: Icon(Remix.close_line, color: iconColor, size: 24.0),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          Divider(color: dividerColor, height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: supportedLanguages.length,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemBuilder: (BuildContext listContext, int index) {
                final lang = supportedLanguages[index];
                final bool isSelected = lang.code == currentLanguageCode;

                return InkWell(
                  onTap: () async {
                    if (lang.code != currentLanguageCode) {
                      changeLocale(context, lang.code);
                      await _saveLanguagePreference(lang.code);
                      onLanguageSelected(lang.code);
                    }
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    child: Row(
                      children: [
                        Image.asset(
                          lang.flagAssetPath,
                          width: 28,
                          height: 28,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Remix.earth_line, size: 28, color: iconColor);
                          },
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            lang.getTranslatedName(listContext),
                            style: AppFonts.titleMedium(
                              color: isSelected ? primaryColor : onSheetColor,
                            )?.copyWith(fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500),
                          ),
                        ),
                        if (isSelected)
                          Icon(Remix.check_line, color: primaryColor, size: 22)
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
