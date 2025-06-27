// lib/features/books/screens/read_book_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nover/src/utils/app_fonts.dart'; // Pastikan path ini benar
import 'package:nover/src/utils/ui_helpers.dart'; // Pastikan path ini benar
import 'package:nover/features/books/widgets/custom_detail_top_bar.dart'; // Pastikan path ini benar
import 'package:nover/features/books/widgets/custom_read_bottom_bar.dart'; // Pastikan path ini benar
import 'package:nover/features/books/widgets/reading_settings_bottom_sheet.dart'; // Pastikan path ini benar

const Duration _kBarAnimationDuration = Duration(milliseconds: 250);
const Curve _kBarAnimationCurve = Curves.easeOutCubic;
const double _kProgressIndicatorHeight = 3.0;

const double _kCustomReadScreenTopBarContentHeight = kToolbarHeight + 16.0;

class ReadNovelScreen extends StatefulWidget {
  final String chapterIntroLabelText;
  final String chapterTitleText;
  final String chapterBodyText;

  const ReadNovelScreen({
    super.key,
    required this.chapterIntroLabelText,
    required this.chapterTitleText,
    required this.chapterBodyText,
  });

  @override
  State<ReadNovelScreen> createState() => _ReadNovelScreenState();
}

class _ReadNovelScreenState extends State<ReadNovelScreen> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _showTitleInAppBarContent = false;
  bool _isBarsVisible = true;
  double _currentProgress = 0.0;
  final GlobalKey _chapterTitleKey = GlobalKey();

  double _currentBrightness = 1.0;
  String _currentFontFamily = 'Lora';
  late ReadingTheme _currentReadingTheme;
  double _currentFontSize = 17.0;
  TextAlign _currentTextAlign = TextAlign.left;
  late ReadScrollMode _currentScrollMode;

  late Color _currentScreenBackgroundColor;
  late Color _currentBodyTextColor;
  late Color _currentTopBarBackgroundColor;
  late Color _currentTopBarIconColor;

  bool _isInitialThemeSetupDone = false;
  static const double _hideBarsScrollThreshold = 10.0;

  @override
  void initState() {
    super.initState();
    _currentScrollMode = ReadScrollMode.scroll;
    _goFullscreen();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialThemeSetupDone) {
      final Brightness appBrightness = Theme.of(context).brightness;
      _currentReadingTheme = (appBrightness == Brightness.dark)
          ? ReadingTheme.dark
          : ReadingTheme.light;
      _applyReadingTheme(_currentReadingTheme);
      _isInitialThemeSetupDone = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _onScroll();
        }
      });
    }
  }

  @override
  void dispose() {
    _restoreSystemUI();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _goFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _restoreSystemUI() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  void setStateIfMounted(VoidCallback f) {
    if (mounted) setState(f);
  }

  void _applyReadingTheme(ReadingTheme theme, {bool triggerSetState = true}) {
    Color newScreenBg, newBodyText, newTopBarBg, newTopBarIcon;
    switch (theme) {
      case ReadingTheme.light:
        newScreenBg = const Color(0xFFFCFCFC);
        newBodyText = Colors.black.withOpacity(0.85);
        newTopBarBg = newScreenBg.withOpacity(0.95);
        newTopBarIcon = Colors.black87;
        break;
      case ReadingTheme.sepia:
        newScreenBg = const Color(0xFFFBF0D9);
        newBodyText = const Color(0xFF5B4636).withOpacity(0.9);
        newTopBarBg = newScreenBg.withOpacity(0.95);
        newTopBarIcon = const Color(0xFF5B4636);
        break;
      case ReadingTheme.grey:
        newScreenBg = const Color(0xFFDCDCDC);
        newBodyText = Colors.black.withOpacity(0.80);
        newTopBarBg = newScreenBg.withOpacity(0.95);
        newTopBarIcon = Colors.black87;
        break;
      case ReadingTheme.dark:
        newScreenBg = const Color(0xFF1E1E1E);
        newBodyText = Colors.white.withOpacity(0.85);
        newTopBarBg = newScreenBg.withOpacity(0.95);
        newTopBarIcon = Colors.white.withOpacity(0.85);
        break;
    }

    if (triggerSetState) {
      setStateIfMounted(() {
        _currentReadingTheme = theme;
        _currentScreenBackgroundColor = newScreenBg;
        _currentBodyTextColor = newBodyText;
        _currentTopBarBackgroundColor = newTopBarBg;
        _currentTopBarIconColor = newTopBarIcon;
      });
    } else {
      _currentReadingTheme = theme;
      _currentScreenBackgroundColor = newScreenBg;
      _currentBodyTextColor = newBodyText;
      _currentTopBarBackgroundColor = newTopBarBg;
      _currentTopBarIconColor = newTopBarIcon;
    }
  }

  void _onScroll() {
    if (!mounted || !_scrollController.hasClients || _scrollController.position.extentTotal == 0) {
      if (widget.chapterBodyText.isNotEmpty) {
        setStateIfMounted(() => _currentProgress = 1.0);
      } else {
        setStateIfMounted(() => _currentProgress = 0.0);
      }
      _checkTitleVisibilityInAppBar();
      return;
    }

    if (_scrollController.offset > _hideBarsScrollThreshold && _isBarsVisible) {
      setStateIfMounted(() => _isBarsVisible = false);
    } else if (_scrollController.offset <= _hideBarsScrollThreshold && !_isBarsVisible) {
      setStateIfMounted(() => _isBarsVisible = true);
    }

    _checkTitleVisibilityInAppBar();

    double progress = _scrollController.offset / _scrollController.position.maxScrollExtent;
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent && !_scrollController.position.outOfRange) {
      progress = 1.0;
    }
    setStateIfMounted(() => _currentProgress = progress.clamp(0.0, 1.0));
  }

  void _checkTitleVisibilityInAppBar() {
    if (!mounted) return;
    final chapterTitleContext = _chapterTitleKey.currentContext;
    if (chapterTitleContext != null) {
      final RenderBox? renderBox = chapterTitleContext.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final titlePositionGlobal = renderBox.localToGlobal(Offset.zero);
        final double safeAreaTop = MediaQuery.of(context).padding.top;
        final double appBarContentBottomY = safeAreaTop + _kCustomReadScreenTopBarContentHeight;

        bool shouldShowTitle = (titlePositionGlobal.dy + renderBox.size.height) < appBarContentBottomY;
        if (shouldShowTitle != _showTitleInAppBarContent) {
          setStateIfMounted(() => _showTitleInAppBarContent = shouldShowTitle);
        }
      }
    }
  }

  void _toggleBarsVisibility() {
    if (_scrollController.hasClients && _scrollController.offset <= _scrollController.position.minScrollExtent && _isBarsVisible) {
      return;
    }
    setStateIfMounted(() => _isBarsVisible = !_isBarsVisible);
  }

  void _showReadingSettingsBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bottomSheetContext) {
        return ReadingSettingsBottomSheet(
          initialBrightness: _currentBrightness,
          initialFontSize: _currentFontSize,
          initialFontFamily: _currentFontFamily,
          initialReadingTheme: _currentReadingTheme,
          initialTextAlign: _currentTextAlign,
          initialScrollMode: _currentScrollMode,
          onBrightnessChanged: (val) => setStateIfMounted(() => _currentBrightness = val),
          onFontSizeChanged: (val) => setStateIfMounted(() => _currentFontSize = val),
          onFontFamilyChanged: (val) => setStateIfMounted(() => _currentFontFamily = val),
          onReadingThemeChanged: (val) {
            _applyReadingTheme(val);
          },
          onTextAlignChanged: (val) => setStateIfMounted(() => _currentTextAlign = val),
          onScrollModeChanged: (val) {
            setStateIfMounted(() => _currentScrollMode = val);
            if (val == ReadScrollMode.swipe) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mode Geser belum diimplementasikan.')));
            }
          },
        );
      },
    ).whenComplete(() {
      _goFullscreen();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData appTheme = Theme.of(context);
    final double topSafeArea = MediaQuery.of(context).padding.top;
    final double bottomSafeArea = MediaQuery.of(context).padding.bottom;

    if (!_isInitialThemeSetupDone) {
      final Brightness fallbackBrightness = Theme.of(context).brightness;
      _currentReadingTheme = (fallbackBrightness == Brightness.dark) ? ReadingTheme.dark : ReadingTheme.light;
      _applyReadingTheme(_currentReadingTheme, triggerSetState: false);
    }

    final TextStyle chapterTitleOnPageStyle = GoogleFonts.montserrat(
      fontSize: responsiveFontSize(context, _currentFontSize + 9),
      fontWeight: FontWeight.bold, color: _currentBodyTextColor,
    );
    final TextStyle chapterIntroStyle = AppFonts.titleSmall(color: _currentBodyTextColor.withOpacity(0.75)).copyWith(
      fontSize: responsiveFontSize(context, _currentFontSize - 2),
    );
    final TextStyle novelBodyStyle = GoogleFonts.getFont(
      _currentFontFamily, fontSize: responsiveFontSize(context, _currentFontSize),
      color: _currentBodyTextColor, height: 1.7, fontWeight: FontWeight.normal,
    );

    // Padding atas default untuk konten ketika semua bar terlihat
    final double defaultTopPaddingForContent = topSafeArea +
        _kCustomReadScreenTopBarContentHeight +
        _kProgressIndicatorHeight +
        responsiveFontSize(context, 16); // Spasi tambahan setelah progress bar

    Widget readingContent;
    if (_currentScrollMode == ReadScrollMode.scroll) {
      readingContent = SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.only(
          left: responsiveFontSize(context, 20),
          right: responsiveFontSize(context, 20),
          top: defaultTopPaddingForContent, // Gunakan padding yang sudah memperhitungkan semua elemen top bar
          bottom: (_isBarsVisible ? (CustomReadBottomBar.kBottomBarHeight + bottomSafeArea) : 0) + responsiveFontSize(context, 15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.chapterIntroLabelText.isNotEmpty && widget.chapterIntroLabelText != widget.chapterTitleText)
              Padding(
                padding: EdgeInsets.only(bottom: responsiveFontSize(context, 6)),
                child: Text(widget.chapterIntroLabelText, style: chapterIntroStyle),
              ),
            Text(widget.chapterTitleText, key: _chapterTitleKey, style: chapterTitleOnPageStyle),
            SizedBox(height: responsiveFontSize(context, 24)),
            Text(widget.chapterBodyText, style: novelBodyStyle, textAlign: _currentTextAlign),
          ],
        ),
      );
    } else {
      readingContent = Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(
          left: responsiveFontSize(context, 20),
          right: responsiveFontSize(context, 20),
          top: defaultTopPaddingForContent, // Gunakan padding yang sama
          bottom: (_isBarsVisible ? CustomReadBottomBar.kBottomBarHeight + bottomSafeArea : 0) + responsiveFontSize(context, 15),
        ),
        child: Text("Mode Geser (Swipe) belum diimplementasikan.", textAlign: TextAlign.center, style: novelBodyStyle),
      );
    }

    return Scaffold(
      backgroundColor: _currentScreenBackgroundColor,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleBarsVisibility,
                behavior: HitTestBehavior.opaque,
                child: readingContent,
              ),
            ),
            AnimatedPositioned(
              duration: _kBarAnimationDuration,
              curve: _kBarAnimationCurve,
              // --- PERUBAHAN KUNCI UNTUK ANIMASI TOP BAR ---
              // Saat bar disembunyikan (_isBarsVisible = false), geser Container ke atas
              // sejauh tinggi konten CustomDetailTopBar (_kCustomReadScreenTopBarContentHeight).
              // Ini akan membuat CustomDetailTopBar (beserta area status barnya) keluar layar,
              // tetapi LinearProgressIndicator (yang ada di bawahnya dalam Column) akan
              // muncul pada posisi topSafeArea.
              top: _isBarsVisible ? 0 : -_kCustomReadScreenTopBarContentHeight,
              // --- AKHIR PERUBAHAN KUNCI ---
              left: 0,
              right: 0,
              child: Container(
                color: _currentTopBarBackgroundColor, // Warna latar belakang untuk keseluruhan top bar area
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomDetailTopBar(
                      backgroundColor: Colors.transparent, // Biarkan Container induk yang memberi warna
                      iconColor: _currentTopBarIconColor,
                      onBackPressed: () => Navigator.of(context).pop(),
                      onSharePressed: () { print('Share tapped'); },
                      topPadding: topSafeArea, // Untuk padding status bar internal di CustomDetailTopBar
                      height: _kCustomReadScreenTopBarContentHeight, // Tinggi konten CustomDetailTopBar
                      bookTitle: widget.chapterTitleText,
                      chapterText: widget.chapterIntroLabelText,
                      showTitleAuthor: _showTitleInAppBarContent,
                    ),
                    SizedBox(
                      height: _kProgressIndicatorHeight,
                      width: double.infinity,
                      child: LinearProgressIndicator(
                        value: _currentProgress,
                        backgroundColor: _currentTopBarIconColor.withOpacity(0.12),
                        valueColor: AlwaysStoppedAnimation<Color>(appTheme.colorScheme.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedPositioned(
              duration: _kBarAnimationDuration,
              curve: _kBarAnimationCurve,
              bottom: _isBarsVisible ? 0 : -(CustomReadBottomBar.kBottomBarHeight + bottomSafeArea),
              left: 0,
              right: 0,
              child: CustomReadBottomBar(
                iconColor: _currentTopBarIconColor,
                backgroundColor: _currentTopBarBackgroundColor,
                onTableOfContentsPressed: () { print('Daftar Isi Ditekan'); },
                onCommentsPressed: () { print('Komentar Ditekan'); },
                onSettingsPressed: _showReadingSettingsBottomSheet,
              ),
            ),
          ],
        ),
      ),
    );
  }
}