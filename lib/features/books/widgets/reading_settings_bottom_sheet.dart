// lib/features/books/widgets/reading_settings_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:nover/src/utils/app_fonts.dart'; // Sesuaikan path jika perlu
import 'package:nover/src/utils/ui_helpers.dart'; // Sesuaikan path jika perlu
import 'package:remixicon/remixicon.dart';
import 'package:google_fonts/google_fonts.dart';

// Enum untuk tema baca (SUMBER UTAMA ENUM)
enum ReadingTheme { light, sepia, grey, dark }
// Enum untuk mode scroll (SUMBER UTAMA ENUM)
enum ReadScrollMode { scroll, swipe }
// Flutter sudah punya TextAlign, jadi tidak perlu enum baru.

class ReadingSettingsBottomSheet extends StatefulWidget {
  // Nilai awal
  final double initialBrightness;
  final double initialFontSize;
  final String initialFontFamily;
  final ReadingTheme initialReadingTheme; // Menggunakan enum dari file ini
  final TextAlign initialTextAlign;
  final ReadScrollMode initialScrollMode; // Menggunakan enum dari file ini

  // Callback perubahan
  final ValueChanged<double> onBrightnessChanged;
  final ValueChanged<double> onFontSizeChanged;
  final ValueChanged<String> onFontFamilyChanged; // String nama font family
  final ValueChanged<ReadingTheme> onReadingThemeChanged; // Menggunakan enum dari file ini
  final ValueChanged<TextAlign> onTextAlignChanged;
  final ValueChanged<ReadScrollMode> onScrollModeChanged; // Menggunakan enum dari file ini

  final List<String> availableFontFamilies;
  final Map<String, String> fontFamilyDisplayNames;

  const ReadingSettingsBottomSheet({
    super.key,
    required this.initialBrightness,
    required this.initialFontSize,
    required this.initialFontFamily,
    required this.initialReadingTheme,
    required this.initialTextAlign,
    required this.initialScrollMode,
    required this.onBrightnessChanged,
    required this.onFontSizeChanged,
    required this.onFontFamilyChanged,
    required this.onReadingThemeChanged,
    required this.onTextAlignChanged,
    required this.onScrollModeChanged,
    this.availableFontFamilies = const ['Lora', 'Montserrat', 'Roboto', 'Merriweather'],
    this.fontFamilyDisplayNames = const {
      'Lora': 'Lora',
      'Montserrat': 'Montserrat',
      'Roboto': 'Roboto',
      'Merriweather': 'Merriweather',
    },
  });

  @override
  State<ReadingSettingsBottomSheet> createState() => _ReadingSettingsBottomSheetState();
}

class _ReadingSettingsBottomSheetState extends State<ReadingSettingsBottomSheet> {
  late double _currentBrightness;
  late double _currentFontSize;
  late String _currentFontFamily;
  late ReadingTheme _currentReadingTheme; // Menggunakan enum dari file ini
  late TextAlign _currentTextAlign;
  late ReadScrollMode _currentScrollMode; // Menggunakan enum dari file ini

  final double _minFontSize = 12.0;
  final double _maxFontSize = 28.0;

  @override
  void initState() {
    super.initState();
    _currentBrightness = widget.initialBrightness;
    _currentFontSize = widget.initialFontSize;
    _currentFontFamily = widget.initialFontFamily;
    _currentReadingTheme = widget.initialReadingTheme;
    _currentTextAlign = widget.initialTextAlign;
    _currentScrollMode = widget.initialScrollMode;
  }

  Widget _buildSectionTitle(BuildContext context, String title, {Widget? trailing}) {
    final theme = Theme.of(context);
    final onSheetColor = theme.brightness == Brightness.dark ? Colors.white.withOpacity(0.9) : Colors.black87;

    return Padding(
      padding: EdgeInsets.only(
        top: responsiveFontSize(context, 18),
        bottom: responsiveFontSize(context, 10),
        left: responsiveFontSize(context, 16),
        right: responsiveFontSize(context, 16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppFonts.titleMedium(color: onSheetColor).copyWith(
              fontWeight: FontWeight.bold,
              fontSize: responsiveFontSize(context, 16),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sheetBackgroundColor = theme.brightness == Brightness.dark ? const Color(0xFF2C2C2E) : const Color(0xFFF0F0F0);
    final onSheetColor = theme.brightness == Brightness.dark ? Colors.white.withOpacity(0.9) : Colors.black.withOpacity(0.8);
    final onSheetVariantColor = theme.brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade700;
    final activeColor = theme.colorScheme.primary;
    final sliderInactiveColor = theme.brightness == Brightness.dark ? Colors.grey.shade700 : activeColor.withOpacity(0.25);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom > 0
            ? MediaQuery.of(context).padding.bottom
            : responsiveFontSize(context, 16),
        top: responsiveFontSize(context, 8),
      ),
      decoration: BoxDecoration(
        color: sheetBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Center(
              child: Container(
                width: responsiveFontSize(context, 36),
                height: responsiveFontSize(context, 4),
                margin: EdgeInsets.only(bottom: responsiveFontSize(context, 12)),
                decoration: BoxDecoration(
                  color: onSheetVariantColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(responsiveFontSize(context, 2)),
                ),
              ),
            ),
            _buildSectionTitle(
                context,
                'Pengaturan', // Ganti dengan translate() jika perlu
                trailing: IconButton(
                  icon: Icon(Remix.close_line, color: onSheetVariantColor, size: responsiveFontSize(context, 22)),
                  onPressed: () => Navigator.pop(context),
                  splashRadius: responsiveFontSize(context, 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )
            ),
            Divider(color: onSheetVariantColor.withOpacity(0.2), height: 1, indent: 16, endIndent: 16),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: responsiveFontSize(context, 16.0), vertical: responsiveFontSize(context, 8.0)),
              child: Row(
                children: [
                  Icon(Remix.sun_line, size: responsiveFontSize(context, 18), color: onSheetVariantColor),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        showValueIndicator: ShowValueIndicator.always,
                        valueIndicatorTextStyle: TextStyle(
                          color: sheetBackgroundColor,
                          fontSize: 10.0,
                          fontFamily: GoogleFonts.montserrat().fontFamily,
                        ),
                        valueIndicatorColor: activeColor,
                        thumbShape: _SliderThumbValueShape(value: (_currentBrightness * 100).round().toString()),
                      ),
                      child: Slider(
                        value: _currentBrightness,
                        min: 0.1, max: 1.0, divisions: 18,
                        activeColor: activeColor,
                        inactiveColor: sliderInactiveColor,
                        onChanged: (value) {
                          setState(() => _currentBrightness = value);
                          widget.onBrightnessChanged(value);
                        },
                      ),
                    ),
                  ),
                  Icon(Remix.sun_fill, size: responsiveFontSize(context, 22), color: onSheetVariantColor),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: responsiveFontSize(context, 16.0)),
              child: Row(
                children: <Widget>[
                  Text('A', style: TextStyle(fontSize: responsiveFontSize(context, 14), color: onSheetVariantColor, fontFamily: GoogleFonts.montserrat().fontFamily)),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        showValueIndicator: ShowValueIndicator.always,
                        valueIndicatorTextStyle: TextStyle(
                          color: sheetBackgroundColor,
                          fontSize: 10.0,
                          fontFamily: GoogleFonts.montserrat().fontFamily,
                        ),
                        valueIndicatorColor: activeColor,
                        thumbShape: _SliderThumbValueShape(value: _currentFontSize.round().toString()),
                      ),
                      child: Slider(
                        value: _currentFontSize,
                        min: _minFontSize, max: _maxFontSize,
                        divisions: ((_maxFontSize - _minFontSize) / 2).round(),
                        activeColor: activeColor,
                        inactiveColor: sliderInactiveColor,
                        onChanged: (value) {
                          double steppedValue = (value / 2).round() * 2.0;
                          steppedValue = steppedValue.clamp(_minFontSize, _maxFontSize);
                          setState(() => _currentFontSize = steppedValue);
                          widget.onFontSizeChanged(steppedValue);
                        },
                      ),
                    ),
                  ),
                  Text('A', style: TextStyle(fontSize: responsiveFontSize(context, 20), color: onSheetVariantColor, fontFamily: GoogleFonts.montserrat().fontFamily)),
                ],
              ),
            ),
            SizedBox(height: responsiveFontSize(context, 8)),

            Padding(
              padding: EdgeInsets.fromLTRB(responsiveFontSize(context, 16.0), responsiveFontSize(context, 8.0), responsiveFontSize(context, 16.0), responsiveFontSize(context,0)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Font',
                    style: AppFonts.titleSmall(color: onSheetColor).copyWith(fontSize: responsiveFontSize(context, 14), fontWeight: FontWeight.w500),
                  ),
                  InkWell(
                    onTap: () {
                      _showFontFamilyPicker(context, theme, onSheetColor, activeColor);
                    },
                    borderRadius: BorderRadius.circular(responsiveFontSize(context, 8)),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: responsiveFontSize(context, 4.0), vertical: responsiveFontSize(context, 4.0)),
                      child: Row(
                        children: [
                          Text(
                            widget.fontFamilyDisplayNames[_currentFontFamily] ?? _currentFontFamily,
                            style: AppFonts.titleSmall(color: onSheetVariantColor).copyWith(fontSize: responsiveFontSize(context, 14)),
                          ),
                          SizedBox(width: responsiveFontSize(context, 2)),
                          Icon(Remix.arrow_right_s_line, color: onSheetVariantColor, size: responsiveFontSize(context, 20)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: responsiveFontSize(context, 16.0),
                  right: responsiveFontSize(context, 10.0),
                  top: responsiveFontSize(context, 0)
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildAlignmentButton(context, TextAlign.left, Remix.align_left, onSheetVariantColor, activeColor, theme),
                  _buildAlignmentButton(context, TextAlign.center, Remix.align_center, onSheetVariantColor, activeColor, theme),
                  _buildAlignmentButton(context, TextAlign.right, Remix.align_right, onSheetVariantColor, activeColor, theme),
                  _buildAlignmentButton(context, TextAlign.justify, Remix.align_justify, onSheetVariantColor, activeColor, theme),
                ],
              ),
            ),
            SizedBox(height: responsiveFontSize(context, 12)),

            Padding(
              padding: EdgeInsets.fromLTRB(responsiveFontSize(context, 16.0), responsiveFontSize(context, 8.0), responsiveFontSize(context, 16.0), responsiveFontSize(context,12.0)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ReadingTheme.values.map((readingTheme) {
                  Color bgColor; Color circleFillColor; Color borderColor;
                  Widget? overlayIcon; bool isSelected = _currentReadingTheme == readingTheme;

                  switch (readingTheme) {
                    case ReadingTheme.light:
                      bgColor = const Color(0xFFFFFFFF); circleFillColor = bgColor;
                      borderColor = isSelected ? activeColor : Colors.grey.shade400; break;
                    case ReadingTheme.sepia:
                      bgColor = const Color(0xFFF5EFE5); circleFillColor = bgColor;
                      borderColor = isSelected ? activeColor : const Color(0xFFD3C0A2); break;
                    case ReadingTheme.grey:
                      bgColor = const Color(0xFFA9A9A9); circleFillColor = bgColor;
                      borderColor = isSelected ? activeColor : Colors.grey.shade600; break;
                    case ReadingTheme.dark:
                      bgColor = const Color(0xFF1E1E1E); circleFillColor = bgColor;
                      borderColor = isSelected ? activeColor : Colors.grey.shade500;
                      overlayIcon = Icon(Remix.moon_line, color: Colors.white70, size: responsiveFontSize(context, 13)); break;
                  }
                  bool isVipTheme = (readingTheme == ReadingTheme.dark); // Contoh

                  return GestureDetector(
                    onTap: () {
                      setState(() => _currentReadingTheme = readingTheme);
                      widget.onReadingThemeChanged(readingTheme);
                    },
                    child: Stack(
                      alignment: Alignment.center, clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: responsiveFontSize(context, 32), height: responsiveFontSize(context, 32),
                          decoration: BoxDecoration(
                            color: circleFillColor, shape: BoxShape.circle,
                            border: Border.all(color: borderColor, width: isSelected ? 2.0 : 1.0),
                            boxShadow: isSelected
                                ? [BoxShadow(color: activeColor.withOpacity(0.3), blurRadius: 4, spreadRadius: 0)]
                                : [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 2, spreadRadius: 0, offset: const Offset(0,1))],
                          ),
                          child: (isSelected && overlayIcon == null)
                              ? Icon(Remix.check_line, color: activeColor, size: responsiveFontSize(context, 18))
                              : overlayIcon,
                        ),
                        if (isVipTheme && theme.brightness == Brightness.light) // Contoh badge VIP
                          Positioned(
                            top: -responsiveFontSize(context, 3), right: -responsiveFontSize(context, 5),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: responsiveFontSize(context, 3.5), vertical: responsiveFontSize(context, 0.5)),
                              decoration: BoxDecoration(
                                  color: const Color(0xFFE9A500), borderRadius: BorderRadius.circular(responsiveFontSize(context, 5)),
                                  border: Border.all(color: sheetBackgroundColor, width: 0.5)
                              ),
                              child: Text('VIP', style: TextStyle(color: Colors.white, fontSize: responsiveFontSize(context, 6.5), fontWeight: FontWeight.bold)),
                            ),
                          )
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: responsiveFontSize(context, 16)),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: responsiveFontSize(context, 16.0)),
              child: Row(
                children: [
                  Expanded(child: _buildScrollModeButton(context, 'Scroll', ReadScrollMode.scroll, onSheetColor, activeColor, theme)),
                  SizedBox(width: responsiveFontSize(context, 10)),
                  Expanded(child: _buildScrollModeButton(context, 'Geser', ReadScrollMode.swipe, onSheetColor, activeColor, theme)),
                ],
              ),
            ),
            SizedBox(height: responsiveFontSize(context, 12)),
          ],
        ),
      ),
    );
  }

  void _showFontFamilyPicker(BuildContext context, ThemeData currentTheme, Color onSheetColor, Color activeColor) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: currentTheme.brightness == Brightness.dark ? const Color(0xFF2C2C2E) : const Color(0xFFF0F0F0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(responsiveFontSize(context, 16))),
          title: Text('Pilih Font', style: AppFonts.titleMedium(color: onSheetColor)),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.availableFontFamilies.length,
              itemBuilder: (BuildContext itemContext, int index) {
                final fontFamily = widget.availableFontFamilies[index];
                final displayName = widget.fontFamilyDisplayNames[fontFamily] ?? fontFamily;
                final isSelected = _currentFontFamily == fontFamily;
                return ListTile(
                  title: Text(
                    displayName,
                    style: GoogleFonts.getFont(fontFamily, color: isSelected ? activeColor : onSheetColor, fontSize: responsiveFontSize(context, 15)),
                  ),
                  trailing: isSelected ? Icon(Remix.check_line, color: activeColor) : null,
                  onTap: () {
                    setState(() => _currentFontFamily = fontFamily);
                    widget.onFontFamilyChanged(fontFamily);
                    Navigator.of(dialogContext).pop();
                  },
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Batal', style: TextStyle(color: activeColor)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildAlignmentButton(BuildContext context, TextAlign align, IconData icon, Color inactiveColor, Color activeColor, ThemeData theme) {
    bool isSelected = _currentTextAlign == align;
    return InkWell(
      onTap: () {
        setState(() => _currentTextAlign = align);
        widget.onTextAlignChanged(align);
      },
      customBorder: const CircleBorder(),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: responsiveFontSize(context, 2)),
        padding: EdgeInsets.all(responsiveFontSize(context, 7.0)),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.15) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: responsiveFontSize(context, 18),
          color: isSelected ? activeColor : inactiveColor,
        ),
      ),
    );
  }

  Widget _buildScrollModeButton(
      BuildContext context, String text, ReadScrollMode mode,
      Color defaultTextColor, Color activeColor, ThemeData theme) {
    bool isSelected = _currentScrollMode == mode;
    Color currentTextColor = isSelected
        ? (activeColor.computeLuminance() > 0.5 ? Colors.black : Colors.white)
        : defaultTextColor;
    if (isSelected && activeColor == theme.colorScheme.primary) {
      currentTextColor = theme.colorScheme.onPrimary;
    }

    return ElevatedButton(
      onPressed: () {
        setState(() => _currentScrollMode = mode);
        widget.onScrollModeChanged(mode);
      },
      style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? activeColor : theme.colorScheme.surfaceContainerLowest,
          foregroundColor: currentTextColor,
          side: BorderSide(
            color: isSelected ? activeColor : theme.dividerColor.withOpacity(0.3),
            width: 1.0,
          ),
          padding: EdgeInsets.symmetric(vertical: responsiveFontSize(context, 10)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(responsiveFontSize(context, 8))),
          elevation: isSelected ? 2 : 0,
          textStyle: TextStyle(
            fontSize: responsiveFontSize(context, 12.5),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontFamily: GoogleFonts.montserrat().fontFamily,
            color: currentTextColor,
          )
      ),
      child: Text(text),
    );
  }
}

class _SliderThumbValueShape extends SliderComponentShape {
  final String value;
  final double thumbRadius;
  final Color textColor;

  _SliderThumbValueShape({
    required this.value,
    this.thumbRadius = 10.0,
    this.textColor = Colors.white,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
      PaintingContext context,
      Offset center, {
        required Animation<double> activationAnimation,
        required Animation<double> enableAnimation,
        required bool isDiscrete,
        required TextPainter labelPainter,
        required RenderBox parentBox,
        required SliderThemeData sliderTheme,
        required TextDirection textDirection,
        required double value,
        required double textScaleFactor,
        required Size sizeWithOverflow,
      }) {
    final Canvas canvas = context.canvas;

    final Paint paint = Paint()
      ..color = sliderTheme.thumbColor ?? sliderTheme.activeTrackColor ?? Colors.blue
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, thumbRadius, paint);

    TextSpan span = TextSpan(
      style: sliderTheme.valueIndicatorTextStyle?.copyWith(color: textColor, fontSize: 10.0) ??
          TextStyle(
            fontSize: 10.0,
            color: textColor,
            fontWeight: FontWeight.bold,
            fontFamily: GoogleFonts.montserrat().fontFamily,
          ),
      text: this.value,
    );
    TextPainter tp = TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: textDirection);
    tp.layout();
    Offset textCenter = Offset(center.dx - (tp.width / 2), center.dy - (tp.height / 2));
    tp.paint(canvas, textCenter);
  }
}