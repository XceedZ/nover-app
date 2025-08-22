// lib/features/posts/screens/detail_my_book_screen.dart
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:nover/src/models/book.dart';
import 'package:nover/src/models/book_detail.dart';
import 'package:nover/src/models/chapter.dart';
import 'package:nover/src/repositories/book_repository.dart';
import 'package:nover/src/utils/app_fonts.dart';
import 'package:nover/src/utils/date_convert.dart';
import 'package:nover/src/utils/translation.dart';
import 'package:nover/src/widgets/book_stats_row_widget.dart';
import 'package:nover/src/widgets/custom_chips.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:remixicon/remixicon.dart';
import 'package:nover/src/widgets/custom_menu.dart';
import 'package:nover/src/widgets/custom_snackbar.dart';
import 'package:nover/features/posts/screens/create_chapter_screen.dart';
import 'package:nover/features/posts/widgets/all_chapters_bottom_sheet.dart';

class DetailMyBookScreen extends StatefulWidget {
  final int bookId;

  const DetailMyBookScreen({
    super.key,
    required this.bookId,
  });

  @override
  State<DetailMyBookScreen> createState() => _DetailMyBookScreenState();
}

class _DetailMyBookScreenState extends State<DetailMyBookScreen> {
  final BookRepository _bookRepository = BookRepository();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _menuButtonKey = GlobalKey();

  late Future<BookDetail> _bookDetailFuture;
  Book? _currentBookState;

  bool _isDescriptionExpanded = false;
  String? _loadingAction;
  Color _dynamicBackgroundColor = Colors.grey.shade800;

  @override
  void initState() {
    super.initState();
    _loadBookDetails();
    _scrollController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  void _loadBookDetails() {
    _bookDetailFuture = _bookRepository.getMyBookDetail(widget.bookId);
    _bookDetailFuture.then((bookDetail) {
      if (mounted) {
        setState(() {
          _currentBookState = bookDetail.bookInfo;
        });
        _updateBackgroundColor();
      }
    }).catchError((error) {
      if (mounted) {
        AppSnackbar.showError(context, message: error.toString());
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleStatusUpdate(String action) async {
    if (_loadingAction != null || _currentBookState == null) return;

    setState(() => _loadingAction = action);

    String newStatus;
    switch (action) {
      case 'publish': newStatus = 'P'; break;
      case 'unpublish': newStatus = 'D'; break;
      case 'hold': newStatus = 'H'; break;
      case 'complete': newStatus = 'C'; break;
      default:
        setState(() => _loadingAction = null);
        return;
    }

    try {
      await _bookRepository.updateBookStatus(widget.bookId, action);

      if (mounted) {
        setState(() {
          _currentBookState = _currentBookState!.copyWith(status: newStatus);
        });
        AppSnackbar.showSuccess(context, message: tl('statusUpdatedSuccess'));
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, message: e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _loadingAction = null);
      }
    }
  }

  // --- PERUBAHAN: Menghapus `Navigator.pop(context)` ---
  // CustomPopupMenu yang baru akan menangani penutupan secara otomatis.
  void _showCustomMenu(Book book) {
    List<CustomMenuItem> menuItems = [
      CustomMenuItem(title: tl('settings'), icon: Remix.settings_3_line, onTap: () {}),
    ];

    switch (book.status) {
      case 'P':
        menuItems.add(CustomMenuItem(title: tl('unpublish'), icon: Remix.forbid_2_line, isDanger: true, onTap: () => _handleStatusUpdate('unpublish')));
        break;
      case 'D':
        menuItems.add(CustomMenuItem(title: tl('publishNow'), icon: Remix.global_line, onTap: () => _handleStatusUpdate('publish')));
        break;
      case 'H':
        menuItems.add(CustomMenuItem(title: tl('publishNow'), icon: Remix.global_line, onTap: () => _handleStatusUpdate('publish')));
        break;
    }

    if (book.status == 'D' || book.status == 'H') {
      menuItems.add(CustomMenuItem(title: tl('delete'), icon: Remix.delete_bin_line, isDanger: true, onTap: (){
        // TODO: Tampilkan dialog konfirmasi sebelum hapus
      }));
    }

    CustomPopupMenu.show(context: context, buttonKey: _menuButtonKey, items: menuItems);
  }

  Future<void> _updateBackgroundColor() async {
    if (!mounted || _currentBookState == null || _currentBookState!.coverImageUrl.isEmpty) return;

    try {
      final file = await DefaultCacheManager().getSingleFile(_currentBookState!.coverImageUrl);
      final bytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes, targetWidth: 100);
      final frameInfo = await codec.getNextFrame();

      final generator = await PaletteGenerator.fromImage(frameInfo.image);
      if (mounted) {
        setState(() {
          _dynamicBackgroundColor = generator.dominantColor?.color ?? Colors.grey.shade800;
        });
      }
    } catch (e) {
      print("Error in _updateBackgroundColor: $e");
    }
  }

  bool _isColorDark(Color color) => color.computeLuminance() < 0.5;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<BookDetail>(
      future: _bookDetailFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && _currentBookState == null) {
          return _buildLoadingScreen();
        }
        if (snapshot.hasError && _currentBookState == null) {
          return Scaffold(appBar: AppBar(title: Text(tl('error'))), body: Center(child: Text(snapshot.error.toString())));
        }

        final book = _currentBookState ?? snapshot.data?.bookInfo;
        final chapters = snapshot.data?.chapters ?? [];

        if (book == null) {
          return Scaffold(body: Center(child: Text(tl('error.loadFailed'))));
        }

        return _buildMainScaffold(theme, book, chapters);
      },
    );
  }

  Widget _buildMainScaffold(ThemeData theme, Book book, List<Chapter> chapters) {
    final colorScheme = theme.colorScheme;
    final double scrollOffset = _scrollController.hasClients ? _scrollController.offset : 0.0;
    final double animationProgress = ((scrollOffset - 180.0) / (250.0 - 180.0)).clamp(0.0, 1.0);
    final Color animatedAppBarColor = Color.lerp(Colors.transparent, theme.scaffoldBackgroundColor, animationProgress)!;
    final Color animatedIconColor = Color.lerp(_isColorDark(_dynamicBackgroundColor) ? Colors.white : Colors.black, colorScheme.onSurface, animationProgress)!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: animatedAppBarColor,
        leading: IconButton(icon: Icon(Remix.arrow_left_s_line, color: animatedIconColor), onPressed: () => Navigator.of(context).pop()),
        title: Opacity(
          opacity: animationProgress,
          child: Text(book.title, style: AppFonts.appBarTitle(color: colorScheme.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        actions: [
          IconButton(key: _menuButtonKey, icon: Icon(Remix.more_2_fill, color: animatedIconColor), onPressed: () => _showCustomMenu(book)),
        ],
      ),
      floatingActionButton: OpenContainer<bool>(
        transitionType: ContainerTransitionType.fadeThrough,
        openBuilder: (context, _) => CreateChapterScreen(bookId: widget.bookId, bookTitle: book.title),
        onClosed: (result) {
          if (result == true) {
            setState(() => _loadBookDetails());
          }
        },
        closedElevation: 6.0,
        closedShape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16.0))),
        closedColor: colorScheme.primary,
        closedBuilder: (context, openContainer) => FloatingActionButton(onPressed: openContainer, backgroundColor: colorScheme.primary, foregroundColor: colorScheme.onPrimary, tooltip: tl('addChapter'), heroTag: null, child: const Icon(Remix.add_line)),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: 80.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(theme, colorScheme, book),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: StatsRowContainer(
                children: [
                  StatItem(value: chapters.length.toString(), label: tl('chapters')),
                  const StatDivider(),
                  StatItem(value: book.totalViews.toString(), label: tl('views')),
                  const StatDivider(),
                  StatItem(value: book.ratingAverage.toStringAsFixed(1), label: tl('rating')),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildStatusCard(context, theme, book),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildDescriptionCard(context, theme, book),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildChaptersCard(context, theme, chapters),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: LoadingAnimationWidget.staggeredDotsWave(
          color: theme.colorScheme.primary,
          size: 50,
        ),
      ),
    );
  }

  Widget _buildHeaderCard(ThemeData theme, ColorScheme colorScheme, Book book) {
    final Color headerTextColor = _isColorDark(_dynamicBackgroundColor) ? Colors.white : Colors.black87;
    return Container(
      decoration: BoxDecoration(color: _dynamicBackgroundColor, borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30))),
      padding: const EdgeInsets.fromLTRB(16, 80, 16, 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Hero(
            tag: 'book-cover-${book.bookId}',
            child: Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))]),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: book.coverImageUrl,
                  width: 110,
                  height: 160,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Container(color: colorScheme.surfaceVariant, child: const Icon(Icons.image_not_supported)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SizedBox(
              height: 160,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book.title, style: AppFonts.titleLarge(color: headerTextColor)?.copyWith(fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 2, color: Colors.black.withOpacity(0.3))]), maxLines: 3, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  DynamicGenreChips(genreString: book.genres ?? "", backgroundColor: headerTextColor.withOpacity(0.15), textColor: headerTextColor),
                  const Spacer(),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: FloatingActionButton(
                      mini: true,
                      onPressed: () {},
                      backgroundColor: headerTextColor.withOpacity(0.2),
                      foregroundColor: headerTextColor,
                      elevation: 0,
                      heroTag: 'editBookFab',
                      child: const Icon(Remix.pencil_line, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, ThemeData theme, Book book) {
    final colorScheme = theme.colorScheme;
    IconData icon;
    Color iconColor;
    String title;
    String message;
    List<Widget> actionButtons = [];

    switch (book.status) {
      case 'D':
        icon = Remix.edit_box_line;
        iconColor = colorScheme.primary;
        title = tl('draft');
        message = tl('statusCardDraftMessage');
        actionButtons.add(Expanded(child: _buildActionButton(title: tl('publishNow'), icon: Remix.global_line, action: 'publish', isPrimary: true)));
        break;
      case 'P':
        icon = Remix.global_line;
        iconColor = Colors.blue.shade600;
        title = tl('published');
        message = tl('statusCardPublishedMessage');
        actionButtons.addAll([
          Expanded(child: _buildActionButton(title: tl('complete'), icon: Remix.checkbox_circle_line, action: 'complete', isPrimary: true)),
          const SizedBox(width: 12),
          Expanded(child: _buildActionButton(title: tl('hold'), icon: Remix.pause_circle_line, action: 'hold', isPrimary: false)),
        ]);
        break;
      case 'H':
        icon = Remix.pause_circle_line;
        iconColor = Colors.orange.shade600;
        title = tl('onHold');
        message = tl('statusCardOnHoldMessage');
        actionButtons.add(Expanded(child: _buildActionButton(title: tl('publishNow'), icon: Remix.global_line, action: 'publish', isPrimary: true)));
        break;
      case 'C':
        icon = Remix.checkbox_circle_line;
        iconColor = Colors.green.shade600;
        title = tl('completed');
        message = tl('statusCardCompletedMessage');
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: theme.shadowColor.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 16),
          Text(tl('bookStatusLabel'), style: AppFonts.titleSmall(color: colorScheme.onSurface.withOpacity(0.6))?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text(title.toUpperCase(), style: AppFonts.titleLarge(color: colorScheme.onSurface)?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(message, style: AppFonts.titleMedium(color: colorScheme.onSurface.withOpacity(0.7))?.copyWith(height: 1.5)),
          if (actionButtons.isNotEmpty) ...[
            const SizedBox(height: 20),
            Row(children: actionButtons),
          ]
        ],
      ),
    );
  }

  Widget _buildActionButton({required String title, required IconData icon, required String action, bool isPrimary = true}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isLoading = _loadingAction == action; // Cek apakah tombol ini yang sedang loading

    final style = isPrimary
        ? ElevatedButton.styleFrom(backgroundColor: colorScheme.primary, foregroundColor: colorScheme.onPrimary, disabledBackgroundColor: colorScheme.primary.withOpacity(0.5), disabledForegroundColor: colorScheme.onPrimary.withOpacity(0.7))
        : TextButton.styleFrom(backgroundColor: colorScheme.onSurface.withOpacity(0.1), foregroundColor: colorScheme.onSurface, disabledBackgroundColor: colorScheme.onSurface.withOpacity(0.05), disabledForegroundColor: colorScheme.onSurface.withOpacity(0.3));

    return ElevatedButton.icon(
      onPressed: _loadingAction != null ? null : () => _handleStatusUpdate(action),
      icon: isLoading ? Container() : Icon(icon, size: 18),
      label: isLoading
          ? SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: isPrimary ? colorScheme.onPrimary : colorScheme.primary))
          : Text(title.toUpperCase()),
      style: style.copyWith(
        padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 12)),
        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        textStyle: MaterialStateProperty.all(AppFonts.titleSmall()?.copyWith(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildDescriptionCard(BuildContext context, ThemeData theme, Book book) {
    final colorScheme = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: theme.shadowColor.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tl('description'), style: AppFonts.titleLarge(color: colorScheme.onSurface)?.copyWith(fontWeight: FontWeight.bold)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Divider(height: 1, thickness: 0.6, color: theme.dividerColor.withOpacity(0.5)),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Text(
              book.description,
              maxLines: _isDescriptionExpanded ? null : 5,
              overflow: _isDescriptionExpanded ? null : TextOverflow.ellipsis,
              style: AppFonts.titleMedium(color: colorScheme.onSurface.withOpacity(0.8))?.copyWith(fontWeight: FontWeight.normal, height: 1.6),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                _isDescriptionExpanded = !_isDescriptionExpanded;
              });
            },
            child: Text(
              _isDescriptionExpanded ? tl('showLess') : tl('readMore'),
              style: AppFonts.titleSmall(color: colorScheme.primary)?.copyWith(fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildChaptersCard(BuildContext context, ThemeData theme, List<Chapter> chapters) {
    final colorScheme = theme.colorScheme;
    const int maxVisibleChapters = 5;
    final bool showMoreButton = chapters.length > maxVisibleChapters;
    final visibleChapters = showMoreButton ? chapters.sublist(0, maxVisibleChapters) : chapters;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 12, 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: theme.shadowColor.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(tl('chapters'), style: AppFonts.titleLarge(color: colorScheme.onSurface)?.copyWith(fontWeight: FontWeight.bold)),
              IconButton(onPressed: (){}, icon: Icon(Remix.sort_asc, color: colorScheme.onSurface.withOpacity(0.7)), tooltip: 'Urutkan Bab'),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 8.0, right: 8.0),
            child: Divider(height: 1, thickness: 0.5, color: theme.dividerColor.withOpacity(0.6)),
          ),
          if (chapters.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Center(child: Text(tl('noChaptersYet'), style: AppFonts.titleMedium(color: colorScheme.onSurface.withOpacity(0.6)))),
            )
          else
            ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: visibleChapters.length,
              itemBuilder: (context, index) {
                return _ChapterListItem(chapter: visibleChapters[index]);
              },
              separatorBuilder: (context, index) => Divider(height: 1, thickness: 0.5, color: theme.dividerColor.withOpacity(0.2)),
            ),

          if (showMoreButton) ...[
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => AllChaptersBottomSheet(allChapters: chapters),
                  );
                },
                child: Text(tl('viewAllChapters'), style: AppFonts.titleMedium(color: colorScheme.primary)?.copyWith(fontWeight: FontWeight.bold)),
              ),
            )
          ]
        ],
      ),
    );
  }
}

class _ChapterListItem extends StatefulWidget {
  final Chapter chapter;
  const _ChapterListItem({required this.chapter});

  @override
  State<_ChapterListItem> createState() => _ChapterListItemState();
}

class _ChapterListItemState extends State<_ChapterListItem> {
  final GlobalKey _menuKey = GlobalKey();

  void _showChapterMenu() {
    CustomPopupMenu.show(
        context: context,
        buttonKey: _menuKey,
        items: [
          CustomMenuItem(title: tl('edit'), icon: Remix.edit_2_line, onTap: () {}),
          CustomMenuItem(title: tl('remove'), icon: Remix.delete_bin_line, isDanger: true, onTap: () {}),
        ]
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return ListTile(
      onTap: () {},
      contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
      leading: CircleAvatar(
        radius: 14,
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? colorScheme.secondaryContainer
            : colorScheme.primary,
        child: Text(
          '${widget.chapter.chapterOrder}',
          style: AppFonts.titleSmall(
            color: Theme.of(context).brightness == Brightness.light
                ? colorScheme.onSecondaryContainer
                : colorScheme.onPrimary,
          )?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(
        widget.chapter.title,
        style: AppFonts.titleMedium(color: colorScheme.onSurface)?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Wrap(
          spacing: 12,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              DateFormatter.formatApiDate(widget.chapter.createDatetime),
              style: AppFonts.titleSmall(color: colorScheme.onSurface.withOpacity(0.6)),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Remix.eye_line, size: 14, color: colorScheme.onSurface.withOpacity(0.6)),
                const SizedBox(width: 4),
                Text(widget.chapter.totalViews.toString(), style: AppFonts.titleSmall(color: colorScheme.onSurface.withOpacity(0.6))),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Remix.chat_3_line, size: 14, color: colorScheme.onSurface.withOpacity(0.6)),
                const SizedBox(width: 4),
                Text("0", style: AppFonts.titleSmall(color: colorScheme.onSurface.withOpacity(0.6))),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Remix.copper_coin_line, size: 14, color: Colors.orange.shade700),
                const SizedBox(width: 4),
                Text(widget.chapter.coinCost.toString(), style: AppFonts.titleSmall(color: Colors.orange.shade800)?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
      trailing: IconButton(
        key: _menuKey,
        onPressed: _showChapterMenu,
        icon: Icon(Remix.more_2_fill, color: colorScheme.onSurface.withOpacity(0.6), size: 20),
        tooltip: 'Opsi Bab',
      ),
    );
  }
}
