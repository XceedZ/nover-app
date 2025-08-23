// lib/features/books/screens/book_detail_screen.dart
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:nover/src/utils/app_fonts.dart';
import 'package:nover/src/models/book.dart';
import 'package:nover/src/models/chapter.dart';
import 'package:nover/src/models/book_detail.dart';
import 'package:nover/src/repositories/book_repository.dart';
import 'package:nover/src/widgets/book_stats_row_widget.dart';
import 'package:nover/src/widgets/custom_chips.dart';
import 'package:nover/src/utils/date_convert.dart';
import 'package:nover/src/utils/ui_helpers.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:remixicon/remixicon.dart';
import 'package:nover/features/books/widgets/custom_detail_top_bar.dart';
import 'package:nover/features/books/widgets/chapters_bottom_sheet.dart';
import 'package:nover/features/books/screens/read_chapter_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:nover/main.dart';
import 'package:nover/src/utils/translation.dart';
import 'package:nover/features/author/screens/author_profile_screen.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:nover/features/books/screens/comments_screen.dart';
import 'package:animations/animations.dart';

class BookDetailScreen extends StatefulWidget {
  final int bookId;
  final Book? initialBookData;

  const BookDetailScreen({
    super.key,
    required this.bookId,
    this.initialBookData,
  });

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  final BookRepository _bookRepository = BookRepository();
  Book? _currentBook;
  AuthorInfo? _authorInfo;
  List<Chapter> _chapters = [];
  List<Review> _reviews = [];
  List<Book> _recommendedBooks = [];

  bool _isLoading = false;

  final ScrollController _scrollController = ScrollController();
  Color _dynamicHeaderColor = const Color(0xFF778899);
  Color _currentTopBarBackgroundColor = const Color(0xFF778899);
  Color _currentTopBarIconColor = Colors.white;

  double _topColoredHeaderActualHeight = 0;
  double _fixedTopBarActualHeight = 0;
  double _sliverBookCoverHeightValue = 0.0;

  bool _heightsCalculated = false;
  bool _isSynopsisExpanded = false;
  bool _isBookmarked = false;
  bool _showTopBarTitleAndAuthor = false;
  final GlobalKey _mainTitleKey = GlobalKey();

  static const double detailImageClipRadius = 10.0;
  static const double detailShadowContainerRadius = 12.0;

  @override
  void initState() {
    super.initState();
    _currentBook = widget.initialBookData;
    _loadBookDetails();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final screenHeight = MediaQuery.of(context).size.height;
        final statusBarPadding = MediaQuery.of(context).padding.top;
        _topColoredHeaderActualHeight = (screenHeight * 0.24).clamp(100.0, 250.0);
        _sliverBookCoverHeightValue = (screenHeight * 0.29).clamp(150.0, 300.0);
        _fixedTopBarActualHeight = kToolbarHeight + statusBarPadding;
        _heightsCalculated = true;

        if (_currentBook != null) {
          _updateHeaderColor(_currentBook!.coverImageUrl);
        } else {
          _scrollListener();
        }
      }
    });
    _scrollController.addListener(_scrollListener);
  }

  Future<void> _loadBookDetails() async {
    if(mounted) setState(() => _isLoading = true);

    try {
      final detail = await _bookRepository.getBookDetail(widget.bookId);
      if (mounted) {
        setState(() {
          _currentBook = detail.bookInfo;
          _authorInfo = detail.author;
          _chapters = detail.chapters;
          _reviews = detail.reviews;
          _recommendedBooks = [];
          _isLoading = false;
        });
        _updateHeaderColor(detail.bookInfo.coverImageUrl);
      }
    } catch (e) {
      print("Failed to load book details: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateHeaderColor(String imageUrl) async {
    if (!mounted || imageUrl.isEmpty) {
      if (mounted) _scrollListener();
      return;
    }
    try {
      final file = await DefaultCacheManager().getSingleFile(imageUrl);
      final bytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes, targetWidth: 100, targetHeight: 150);
      final frameInfo = await codec.getNextFrame();
      final image = frameInfo.image;
      final generator = await PaletteGenerator.fromImage(image, maximumColorCount: 20);

      if (mounted) {
        setState(() {
          _dynamicHeaderColor = generator.dominantColor?.color ?? const Color(0xFF778899);
        });
        _scrollListener();
      }
    } catch (e) {
      print("Error generating palette: $e");
      if (mounted) _scrollListener();
    }
  }

  bool _isColorDark(Color color) => color.computeLuminance() < 0.45;

  void _scrollListener() {
    if (!mounted) return;
    Color newBarBgColor;
    Color newIconColor;

    if (!_heightsCalculated || _fixedTopBarActualHeight == 0) {
      newBarBgColor = _dynamicHeaderColor;
      newIconColor = _isColorDark(_dynamicHeaderColor) ? Colors.white : Colors.black87;
    } else {
      final scrollOffset = _scrollController.hasClients ? _scrollController.offset : 0.0;
      final transitionOffsetColor = _topColoredHeaderActualHeight - _fixedTopBarActualHeight;

      if (scrollOffset <= transitionOffsetColor) {
        newBarBgColor = _dynamicHeaderColor;
        newIconColor = _isColorDark(_dynamicHeaderColor) ? Colors.white : Colors.black87;
      } else {
        final currentTheme = Theme.of(context);
        newBarBgColor = currentTheme.colorScheme.background;
        newIconColor = currentTheme.colorScheme.onBackground;
      }
    }

    if (newBarBgColor != _currentTopBarBackgroundColor || newIconColor != _currentTopBarIconColor) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _currentTopBarBackgroundColor = newBarBgColor;
            _currentTopBarIconColor = newIconColor;
          });
        }
      });
    }

    bool shouldShowTitleInTopBar = false;
    if (_heightsCalculated && _mainTitleKey.currentContext != null) {
      final RenderBox? titleRenderBox = _mainTitleKey.currentContext!.findRenderObject() as RenderBox?;
      if (titleRenderBox != null && titleRenderBox.hasSize) {
        final titleBottomOffsetToGlobal = titleRenderBox.localToGlobal(Offset(0, titleRenderBox.size.height)).dy;
        if (titleBottomOffsetToGlobal < _fixedTopBarActualHeight) {
          shouldShowTitleInTopBar = true;
        }
      }
    } else if (_heightsCalculated) {
      final scrollOffset = _scrollController.hasClients ? _scrollController.offset : 0.0;
      if (scrollOffset > (_topColoredHeaderActualHeight + (_sliverBookCoverHeightValue * 0.2) - _fixedTopBarActualHeight )) {
        shouldShowTitleInTopBar = true;
      }
    }

    if (shouldShowTitleInTopBar != _showTopBarTitleAndAuthor) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() { _showTopBarTitleAndAuthor = shouldShowTitleInTopBar; });
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _showChaptersBottomSheet(Book book, AuthorInfo author, List<Chapter> chapters) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChaptersBottomSheet(
        book: book,
        authorPenName: author.penName ?? author.fullName,
        chapters: chapters,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentBook == null) {
      return Scaffold(
        body: Center(
          child: LoadingAnimationWidget.staggeredDotsWave(
              color: Theme.of(context).colorScheme.primary, size: 50),
        ),
      );
    }
    return _buildUI(context, _currentBook!, _authorInfo, _chapters, _reviews, isLoading: _isLoading);
  }

  Widget _buildUI(BuildContext context, Book book, AuthorInfo? author, List<Chapter> chapters, List<Review> reviews, {bool isLoading = false}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;
    final statusBarPadding = MediaQuery.of(context).padding.top;
    final topBarHeight = kToolbarHeight + statusBarPadding;

    final double localSliverColoredHeaderHeight = _heightsCalculated ? _topColoredHeaderActualHeight : (screenHeight * 0.24).clamp(100.0, 250.0);
    final double localSliverBookCoverHeight = _sliverBookCoverHeightValue > 0 ? _sliverBookCoverHeightValue : (screenHeight * 0.29).clamp(150.0, 300.0);
    final double localSliverBookCoverWidth = localSliverBookCoverHeight * (2.0 / 3.0);
    final double sliverBookCoverOverlap = localSliverBookCoverHeight * 0.35;
    final double sliver1CombinedHeight = localSliverColoredHeaderHeight + (localSliverBookCoverHeight - sliverBookCoverOverlap);

    final bool skipHeroAnimations = lowPerformanceModeProvider.value;

    Widget bookCoverImage = ClipRRect(
      borderRadius: BorderRadius.circular(detailImageClipRadius),
      child: CachedNetworkImage(
        imageUrl: book.coverImageUrl,
        fit: BoxFit.cover,
        errorWidget: (context, url, error) => const Icon(Icons.image_not_supported, color: Colors.white70),
      ),
    );

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      bottomNavigationBar: _buildBottomActionButtons(context, chapters),
      floatingActionButton: OpenContainer(
        transitionDuration: const Duration(milliseconds: 400),
        closedShape: const CircleBorder(),
        closedColor: colorScheme.primary,
        closedElevation: 6.0,
        openBuilder: (context, _) => CommentsScreen(bookId: book.bookId),
        closedBuilder: (context, openContainer) {
          return FloatingActionButton(
            onPressed: openContainer,
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            tooltip: 'Lihat Komentar',
            child: const Icon(Remix.chat_3_line),
          );
        },
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomScrollView(
              controller: _scrollController,
              slivers: <Widget>[
                SliverToBoxAdapter(child: SizedBox(height: topBarHeight)),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: sliver1CombinedHeight,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.topCenter,
                      children: [
                        Positioned(
                          top: 0, left: 0, right: 0,
                          child: Container(
                            height: localSliverColoredHeaderHeight,
                            decoration: BoxDecoration(
                              color: _dynamicHeaderColor,
                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
                            ),
                          ),
                        ),
                        Positioned(
                          top: localSliverColoredHeaderHeight - (localSliverBookCoverHeight * 0.75),
                          child: Container(
                            height: localSliverBookCoverHeight,
                            width: localSliverBookCoverWidth,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(detailShadowContainerRadius),
                              boxShadow: const [
                                BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.25), blurRadius: 15, offset: Offset(0, 8)),
                              ],
                            ),
                            child: skipHeroAnimations
                                ? bookCoverImage
                                : Hero(tag: 'bookCover_${book.bookId}', child: bookCoverImage),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    transform: Matrix4.translationValues(0, -sliverBookCoverOverlap, 0),
                    padding: EdgeInsets.only(
                      top: sliverBookCoverOverlap + responsiveFontSize(context, -20),
                      left: responsiveFontSize(context, 24),
                      right: responsiveFontSize(context, 24),
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.background,
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildInfoSection(context, book, author, chapters.length),
                        const SizedBox(height: 28),
                        _buildGenreAndSynopsisSection(context, book),
                        const SizedBox(height: 28),
                        if(author != null)
                          _buildChaptersCard(context, book, author, chapters),
                        const SizedBox(height: 28),
                        _buildRecommendationsSection(context, _recommendedBooks, skipHeroAnimations),
                        if (isLoading)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32.0),
                            child: Center(child: LoadingAnimationWidget.staggeredDotsWave(color: Theme.of(context).colorScheme.primary, size: 40)),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0, left: 0, right: 0,
            child: CustomDetailTopBar(
              backgroundColor: _currentTopBarBackgroundColor,
              iconColor: _currentTopBarIconColor,
              onBackPressed: () => Navigator.pop(context),
              onSharePressed: () {},
              topPadding: statusBarPadding,
              height: topBarHeight,
              bookTitle: book.title,
              bookAuthor: author?.penName ?? author?.fullName,
              showTitleAuthor: _showTopBarTitleAndAuthor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, Book book, AuthorInfo? author, int totalChapters) {
    final String authorDisplayName = author?.penName ?? author?.fullName ?? book.author ?? "";

    return Column(
      children: [
        Text(
          book.title,
          key: _mainTitleKey,
          textAlign: TextAlign.center,
          style: AppFonts.titleLarge(color: Theme.of(context).colorScheme.onBackground)?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        if(authorDisplayName.isNotEmpty)
          GestureDetector(
            onTap: () {
              if (author != null) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AuthorProfileScreen(
                  authorName: authorDisplayName,
                  authorImageUrl: author.avatarUrl ?? "",
                )));
              }
            },
            child: Text(
              'By $authorDisplayName',
              textAlign: TextAlign.center,
              style: AppFonts.titleMedium(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))?.copyWith(fontSize: 15),
            ),
          ),
        const SizedBox(height: 12),
        ChipStatus(status: book.status),
        const SizedBox(height: 24),
        StatsRowContainer(
          children: [
            StatItem(value: totalChapters.toString(), label: tl('label.chapters')),
            const StatDivider(),
            StatItem(value: book.totalViews.toString(), label: tl('label.views')),
            const StatDivider(),
            StatItem(value: book.ratingAverage.toStringAsFixed(1), label: tl('label.rating')),
          ],
        ),
      ],
    );
  }

  Widget _buildGenreAndSynopsisSection(BuildContext context, Book book) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: theme.shadowColor.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4)
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tl('label.synopsis'), style: AppFonts.titleLarge()?.copyWith(fontWeight: FontWeight.bold)),
          Divider(height: 24, thickness: 0.5, color: theme.dividerColor.withOpacity(0.5)),
          if (book.genres != null && book.genres!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GenreChips(genreString: book.genres),
            ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Text(
              book.description,
              maxLines: _isSynopsisExpanded ? null : 5,
              overflow: _isSynopsisExpanded ? null : TextOverflow.ellipsis,
              style: AppFonts.bodyMedium()?.copyWith(height: 1.6),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => setState(() => _isSynopsisExpanded = !_isSynopsisExpanded),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                _isSynopsisExpanded ? tl('label.showLess') : tl('label.readMore'),
                style: AppFonts.titleSmall(color: colorScheme.primary)?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChaptersCard(BuildContext context, Book book, AuthorInfo author, List<Chapter> chapters) {
    final theme = Theme.of(context);
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
                onPressed: () => _showChaptersBottomSheet(book, author, chapters),
                child: Text(tl('viewAllChapters'), style: AppFonts.titleMedium(color: colorScheme.primary)?.copyWith(fontWeight: FontWeight.bold)),
              ),
            )
          ]
        ],
      ),
    );
  }

  Widget _buildReviewsCard(BuildContext context, List<Review> reviews) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Comments (${reviews.length})',
                style: AppFonts.titleLarge(color: theme.textTheme.titleLarge?.color)
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (reviews.isNotEmpty)
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'View all',
                    style: AppFonts.titleSmall(color: colorScheme.primary)
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (reviews.isEmpty)
            Column(
              children: [
                Icon(Remix.chat_smile_2_line, size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text(
                  'Be the first to comment',
                  style: AppFonts.titleMedium(color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Say something...',
                    hintStyle: AppFonts.bodyMedium(color: Colors.grey[500]),
                    filled: true,
                    fillColor: theme.scaffoldBackgroundColor,
                    contentPadding: const EdgeInsets.only(left: 20, top: 14, bottom: 14, right: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: GestureDetector(
                        onTap: () {},
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: colorScheme.primary,
                          child: const Icon(Remix.arrow_up_line, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                return ListTile(
                  subtitle: Text(review.reviewText),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildBottomActionButtons(BuildContext context, List<Chapter> chapters) {
    ThemeData theme = Theme.of(context);

    Widget bookmarkButton = Container(
      height: responsiveFontSize(context, 52),
      width: responsiveFontSize(context, 52),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.primary, width: 1.5),
        borderRadius: BorderRadius.circular(responsiveFontSize(context, 12)),
        color: _isBookmarked ? theme.colorScheme.primary.withOpacity(0.1) : Colors.transparent,
      ),
      child: IconButton(
        icon: Icon(
          _isBookmarked ? Remix.bookmark_fill : Remix.bookmark_line,
          color: theme.colorScheme.primary,
          size: responsiveFontSize(context, 24),
        ),
        tooltip: tl(_isBookmarked ? 'label.bookmarkRemove' : 'label.bookmarkAdd'),
        onPressed: () => setState(() => _isBookmarked = !_isBookmarked),
        padding: EdgeInsets.zero,
        splashRadius: responsiveFontSize(context, 26),
      ),
    );

    final bool hasChapters = chapters.isNotEmpty;
    final Chapter? firstChapter = hasChapters ? chapters.first : null;

    Widget continueReadingButton = Expanded(
      child: ElevatedButton(
        onPressed: hasChapters ? () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ReadChapterScreen(
            chapterId: firstChapter!.chapterId,
            initialTitle: firstChapter.title,
          )));
        } : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          minimumSize: Size(0, responsiveFontSize(context, 52)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(responsiveFontSize(context, 12))),
          elevation: 4,
        ),
        child: Text(
          tl('label.continueReading'),
          style: AppFonts.titleMedium()?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );

    return Container(
      decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          border: Border(top: BorderSide(color: theme.dividerColor.withOpacity(0.5), width: 0.5))
      ),
      padding: EdgeInsets.fromLTRB(
          16, 12, 16,
          MediaQuery.of(context).padding.bottom > 0 ? MediaQuery.of(context).padding.bottom + 8 : 12
      ),
      child: Row(
        children: [
          bookmarkButton,
          const SizedBox(width: 12),
          continueReadingButton,
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection(BuildContext context, List<Book> recommendedBooks, bool skipHeroAnimations) {
    if (recommendedBooks.isEmpty) return const SizedBox.shrink();

    ThemeData theme = Theme.of(context);
    final double bookItemImageHeight = responsiveFontSize(context, 170);
    final double bookItemWidth = bookItemImageHeight * (2.0/3.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tl('label.recommendations'),
          style: AppFonts.titleLarge(color: theme.textTheme.titleLarge?.color)?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: bookItemImageHeight + responsiveFontSize(context, 60),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recommendedBooks.length,
            itemBuilder: (context, index) {
              final book = recommendedBooks[index];
              return Padding(
                padding: EdgeInsets.only(left: index == 0 ? 0 : 12),
                child: _RecommendedBookItem(book: book, width: bookItemWidth, imageHeight: bookItemImageHeight, skipHeroAnimation: skipHeroAnimations),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ChapterListItem extends StatelessWidget {
  final Chapter chapter;
  const _ChapterListItem({super.key, required this.chapter});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReadChapterScreen(
              chapterId: chapter.chapterId,
              initialTitle: chapter.title,
            ),
          ),
        );
      },
      contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
      leading: CircleAvatar(
        radius: 14,
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? colorScheme.secondaryContainer
            : colorScheme.primary,
        child: Text(
          '${chapter.chapterOrder}',
          style: AppFonts.titleSmall(
            color: Theme.of(context).brightness == Brightness.light
                ? colorScheme.onSecondaryContainer
                : colorScheme.onPrimary,
          )?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(
        chapter.title,
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
              DateFormatter.formatApiDate(chapter.createDatetime),
              style: AppFonts.titleSmall(color: colorScheme.onSurface.withOpacity(0.6)),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Remix.eye_line, size: 14, color: colorScheme.onSurface.withOpacity(0.6)),
                const SizedBox(width: 4),
                Text(chapter.totalViews.toString(), style: AppFonts.titleSmall(color: colorScheme.onSurface.withOpacity(0.6))),
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
            if (chapter.coinCost > 0)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Remix.lock_line, size: 14, color: Colors.orange.shade700),
                  const SizedBox(width: 4),
                  Text(
                    chapter.coinCost.toString(),
                    style: AppFonts.titleSmall(color: Colors.orange.shade800)?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _RecommendedBookItem extends StatelessWidget {
  final Book book;
  final double width;
  final double imageHeight;
  final bool skipHeroAnimation;

  const _RecommendedBookItem({
    super.key,
    required this.book,
    required this.width,
    required this.imageHeight,
    required this.skipHeroAnimation,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    Widget bookImageWidget = ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: CachedNetworkImage(
        imageUrl: book.coverImageUrl,
        height: imageHeight,
        width: width,
        fit: BoxFit.cover,
      ),
    );

    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BookDetailScreen(bookId: book.bookId, initialBookData: book)),
        );
      },
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            skipHeroAnimation
                ? bookImageWidget
                : Hero(tag: 'bookCover_${book.bookId}', child: bookImageWidget),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: Text(
                book.title,
                style: AppFonts.titleMedium()?.copyWith(fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if(book.author != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
                child: Text(
                  book.author!,
                  style: AppFonts.titleSmall(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }
}