// lib/features/posts/screens/create_chapter_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:nover/features/books/screens/read_book_screen.dart';
import 'package:nover/src/repositories/book_repository.dart';
import 'package:nover/src/utils/app_fonts.dart';
import 'package:nover/src/utils/translation.dart';
import 'package:nover/src/widgets/custom_snackbar.dart';
import 'package:remixicon/remixicon.dart';

class CreateChapterScreen extends StatefulWidget {
  final int bookId;
  final String bookTitle;

  const CreateChapterScreen({
    super.key,
    required this.bookId,
    required this.bookTitle,
  });

  @override
  State<CreateChapterScreen> createState() => _CreateChapterScreenState();
}

class _CreateChapterScreenState extends State<CreateChapterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _bookRepository = BookRepository();
  bool _isLoading = false;

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _coinCostController = TextEditingController(text: '0');

  bool _isBarsVisible = true;
  final double _customAppBarHeight = 60.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _goFullscreen();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    _coinCostController.dispose();
    _restoreSystemUI();
    super.dispose();
  }

  void _goFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _restoreSystemUI() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  void _onScroll() {
    if (!mounted) return;
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (_isBarsVisible) setState(() => _isBarsVisible = false);
    }
    if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (!_isBarsVisible) setState(() => _isBarsVisible = true);
    }
  }

  void _toggleBarsVisibility() {
    setState(() => _isBarsVisible = !_isBarsVisible);
  }

  // UBAH: Navigasi dan logika publish dipisahkan
  void _navigateToPreview() {
    // Memastikan tidak ada proses build yang sedang berjalan saat navigasi
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (_) =>
            ReadNovelScreen(
              chapterIntroLabelText: widget.bookTitle,
              chapterTitleText: _titleController.text.isNotEmpty ? _titleController.text : tl('chapterTitle'),
              chapterBodyText: _contentController.text,
            )
        ));
      }
    });
  }

  Future<void> _publishChapter() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await _bookRepository.createChapter(
        bookId: widget.bookId,
        title: _titleController.text,
        content: _contentController.text,
        coinCost: int.tryParse(_coinCostController.text) ?? 0,
      );

      if (mounted) {
        AppSnackbar.showSuccess(context, message: tl('chapterCreatedSuccess'));
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, message: e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  InputDecoration _editorInputDecoration({required String hint, TextStyle? style}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: style ?? AppFonts.titleMedium(color: Theme.of(context).hintColor),
      border: InputBorder.none,
      focusedBorder: InputBorder.none,
      enabledBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      contentPadding: EdgeInsets.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final topSafeArea = MediaQuery.of(context).padding.top;
    final bottomSafeArea = MediaQuery.of(context).padding.bottom;

    final chapterTitleStyle = AppFonts.titleLarge(color: colorScheme.onSurface)?.copyWith(fontSize: 24, fontWeight: FontWeight.bold);
    final chapterTitleHintStyle = AppFonts.titleLarge(color: theme.hintColor)?.copyWith(fontSize: 24, fontWeight: FontWeight.bold);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Stack(
          children: [
            GestureDetector(
              onTap: _toggleBarsVisibility,
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.only(
                      top: topSafeArea + _customAppBarHeight + 16,
                      bottom: bottomSafeArea + 80,
                      left: 16,
                      right: 16,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: _titleController,
                              validator: (val) => val!.isEmpty ? tl('validationRequired') : null,
                              style: chapterTitleStyle,
                              decoration: _editorInputDecoration(
                                hint: tl('chapterTitle'),
                                style: chapterTitleHintStyle,
                              ),
                              textCapitalization: TextCapitalization.sentences,
                            ),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: _contentController,
                              validator: (val) => val!.isEmpty ? tl('validationRequired') : null,
                              style: AppFonts.titleMedium(color: colorScheme.onSurface)?.copyWith(height: 1.7),
                              decoration: _editorInputDecoration(hint: tl('contentHint')),
                              maxLines: null,
                              textCapitalization: TextCapitalization.sentences,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),

            // Top Bar
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              top: _isBarsVisible ? 0 : -(_customAppBarHeight + topSafeArea),
              left: 0,
              right: 0,
              child: Container(
                height: _customAppBarHeight + topSafeArea,
                padding: EdgeInsets.only(top: topSafeArea),
                decoration: BoxDecoration(
                  color: theme.appBarTheme.backgroundColor?.withOpacity(0.95) ?? theme.scaffoldBackgroundColor.withOpacity(0.95),
                  border: Border(bottom: BorderSide(color: theme.dividerColor, width: 0.5)),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Remix.arrow_left_s_line),
                      onPressed: () => Navigator.of(context).pop(),
                      color: colorScheme.onSurface,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Remix.eye_line, color: colorScheme.onSurface),
                      tooltip: 'Lihat Pratinjau',
                      onPressed: _navigateToPreview, // UBAH: Panggil fungsi navigasi
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0, left: 8.0),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _publishChapter,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: _isLoading
                            ? SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.onPrimary))
                            : Text(tl('publishChapter').toUpperCase(), style: AppFonts.titleSmall()?.copyWith(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Bar
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              bottom: _isBarsVisible ? 0 : -(kBottomNavigationBarHeight + bottomSafeArea),
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(16, 12, 16, bottomSafeArea + 12),
                decoration: BoxDecoration(
                  color: theme.appBarTheme.backgroundColor?.withOpacity(0.95) ?? theme.scaffoldBackgroundColor.withOpacity(0.95),
                  border: Border(top: BorderSide(color: theme.dividerColor, width: 0.5)),
                ),
                child: Row(
                  children: [
                    Icon(Remix.copper_coin_line, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(tl('coinCost'), style: AppFonts.titleSmall()),
                    const Spacer(),
                    SizedBox(
                      width: 80,
                      child: TextFormField(
                        controller: _coinCostController,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        style: AppFonts.titleMedium(color: colorScheme.onSurface)?.copyWith(fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                          isDense: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: theme.dividerColor)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
