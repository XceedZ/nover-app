// lib/screens/book_detail_screen.dart
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nover/src/utils/app_fonts.dart'; // Pastikan path ini benar
import 'package:nover/features/home/screens/home_screen_content.dart' show Book; // Pastikan path ini benar
import 'package:nover/src/utils/ui_helpers.dart'; // Pastikan path ini benar
import 'package:palette_generator/palette_generator.dart';
import 'package:remixicon/remixicon.dart';
import 'package:nover/features/books/widgets/custom_detail_top_bar.dart'; // Pastikan path ini benar
import 'package:nover/features/books/widgets/chapters_bottom_sheet.dart'; // Pastikan path ini benar
import 'package:nover/features/books/screens/read_book_screen.dart'; // Pastikan path ini benar
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:shimmer/shimmer.dart';
import 'package:nover/main.dart'; // Untuk lowPerformanceModeProvider, pastikan path ini benar
import 'package:flutter_translate/flutter_translate.dart';
import 'package:nover/features/author/screens/author_profile_screen.dart'; // Sesuaikan path ini

class BookDetailScreen extends StatefulWidget {
  final Book book;
  const BookDetailScreen({super.key, required this.book});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  Color _dynamicHeaderColor = const Color(0xFF778899);
  Color _currentTopBarBackgroundColor = const Color(0xFF778899);
  Color _currentTopBarIconColor = Colors.white;

  final ScrollController _scrollController = ScrollController();
  double _topColoredHeaderActualHeight = 0;
  double _fixedTopBarActualHeight = 0;
  double _sliverBookCoverHeightValue = 0.0;

  bool _heightsCalculated = false;
  bool _isSynopsisExpanded = false;

  late List<ChapterInfo> _dummyChapters;
  late int _dummyTotalChapters;
  late List<Book> _recommendedBooks;

  bool _showTopBarTitleAndAuthor = false;
  final GlobalKey _mainTitleKey = GlobalKey();

  bool _isBookmarked = false;

  static const double detailImageClipRadius = 10.0;
  static const double detailShadowContainerRadius = 12.0;

  @override
  void initState() {
    super.initState();
    _dummyTotalChapters = widget.book.pages > 20 ? widget.book.pages : 120;
    _dummyChapters = List.generate(
      (_dummyTotalChapters > 100 ? 100 : _dummyTotalChapters > 0 ? _dummyTotalChapters : 20),
          (index) => ChapterInfo(
        title: 'Chapter ${index + 1}: The Adventure Unfolds Further',
        date: '0${(index % 9) + 1}/0${(index % 2)+8}/2024 ${(10 + index % 12).toString().padLeft(2, '0')}:${(10 + index % 40).toString().padLeft(2, '0')}',
      ),
    );
    _recommendedBooks = [
      Book(id: 201, title: "The Midnight Library", chapter: "", author: "Matt Haig", imageUrl: "https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1602190253i/52578297.jpg", rating: 4.7, pages: 304, language: "Eng", description: "Between life and death there is a library...", genres: ["Fiction", "Fantasy"]),
      Book(id: 202, title: "Where the Crawdads Sing", chapter: "", author: "Delia Owens", imageUrl: "https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1582135295i/36809135.jpg", rating: 4.8, pages: 368, language: "Eng", description: "A heartfelt story of a young girl growing up alone in the marshes of North Carolina.", genres: ["Fiction", "Mystery"]),
    ];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final screenHeight = MediaQuery.of(context).size.height;
        final statusBarPadding = MediaQuery.of(context).padding.top;
        _topColoredHeaderActualHeight = (screenHeight * 0.24).clamp(100.0, 250.0);
        _sliverBookCoverHeightValue = (screenHeight * 0.29).clamp(150.0, 300.0);
        _fixedTopBarActualHeight = kToolbarHeight + statusBarPadding; // Ini adalah topBarHeight
        _heightsCalculated = true;
        _updateHeaderColor();
      }
    });
    _scrollController.addListener(_scrollListener);
  }

  Future<Uint8List?> _getImageBytes(String imageUrl) async {
    try {
      final file = await DefaultCacheManager().getSingleFile(imageUrl);
      return await file.readAsBytes();
    } catch (e) {
      print("Error getting image bytes: $e");
      return null;
    }
  }

  Future<void> _updateHeaderColor() async {
    if (!mounted || widget.book.imageUrl.isEmpty) {
      if (mounted) _scrollListener();
      return;
    }
    try {
      final Uint8List? imageBytes = await _getImageBytes(widget.book.imageUrl);
      if (imageBytes != null && mounted) {
        final ui.Codec codec = await ui.instantiateImageCodec(
          imageBytes, targetWidth: 100, targetHeight: 150,
        );
        final ui.FrameInfo frameInfo = await codec.getNextFrame();
        final ui.Image image = frameInfo.image;
        final PaletteGenerator generator = await PaletteGenerator.fromImage(
          image, maximumColorCount: 100,
        );
        Color? potentialColor = generator.dominantColor?.color ??
            generator.vibrantColor?.color ??
            generator.mutedColor?.color;
        Color newGeneratedColor = potentialColor ?? _dynamicHeaderColor;
        if (mounted) {
          if (_dynamicHeaderColor != newGeneratedColor) {
            setState(() { _dynamicHeaderColor = newGeneratedColor; });
          }
          _scrollListener();
        }
      } else if (mounted) {
        _scrollListener();
      }
    } catch (e) {
      print("Error in _updateHeaderColor: $e");
      if (mounted) { _scrollListener(); }
    }
  }

  bool _isColorDark(Color color) {
    return color.computeLuminance() < 0.45;
  }

  void _scrollListener() {
    if (!mounted) return;
    Color newBarBgColor;
    Color newIconColor;
    // _fixedTopBarActualHeight adalah kToolbarHeight + statusBarPadding
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
          setState(() {
            _showTopBarTitleAndAuthor = shouldShowTitleInTopBar;
          });
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

  void _showChaptersBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (BuildContext bottomSheetContext) {
        return ChaptersBottomSheet(
          book: widget.book,
          chapters: _dummyChapters,
          totalChapters: _dummyTotalChapters,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final double statusBarPadding = MediaQuery.of(context).padding.top;
    final double topBarHeight = kToolbarHeight + statusBarPadding; // Ini adalah _fixedTopBarActualHeight

    final double localSliverColoredHeaderHeight = _heightsCalculated ? _topColoredHeaderActualHeight : (screenHeight * 0.24).clamp(100.0, 250.0);
    final double localSliverBookCoverHeight = _sliverBookCoverHeightValue > 0 ? _sliverBookCoverHeightValue : (screenHeight * 0.29).clamp(150.0, 300.0);
    final double localSliverBookCoverWidth = localSliverBookCoverHeight * (2.0 / 3.0);

    final double sliverBookCoverOverlap = localSliverBookCoverHeight * 0.35;
    final double sliver1CombinedHeight = localSliverColoredHeaderHeight + (localSliverBookCoverHeight - sliverBookCoverOverlap);

    final Color onSurfaceColor = Theme.of(context).colorScheme.onSurface;
    final Color onSurfaceSlightlyFadedColor = onSurfaceColor.withOpacity(0.7);
    final bool skipHeroAnimations = lowPerformanceModeProvider.value;

    // Kalkulasi untuk padding bawah CustomScrollView (tetap dipertahankan)
    final double bottomSafePadding = MediaQuery.of(context).padding.bottom;
    final double bottomButtonsContainerTopPadding = responsiveFontSize(context, 12.0);
    final double bottomButtonsContentMinHeight = responsiveFontSize(context, 52.0);
    final double bottomButtonsContainerBottomPadding = bottomSafePadding > 0
        ? bottomSafePadding
        : responsiveFontSize(context, 12.0);

    final double calculatedHeightOfBottomActionButtons = bottomButtonsContainerTopPadding +
        bottomButtonsContentMinHeight +
        bottomButtonsContainerBottomPadding;
    const double overflowBuffer = 6.0;
    final double totalBottomPaddingForScrollView = calculatedHeightOfBottomActionButtons + overflowBuffer;

    Widget bookCoverImage = ClipRRect(
      borderRadius: BorderRadius.circular(detailImageClipRadius),
      child: CachedNetworkImage(
        imageUrl: widget.book.imageUrl,
        fit: BoxFit.cover,
        height: localSliverBookCoverHeight,
        width: localSliverBookCoverWidth,
        memCacheHeight: (localSliverBookCoverHeight * devicePixelRatio).round(),
        memCacheWidth: (localSliverBookCoverWidth * devicePixelRatio).round(),
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(color: Colors.white),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[300],
          child: Icon(Remix.image_line, size: responsiveFontSize(context, 50), color: Colors.grey[500]),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(
                top: topBarHeight, // Padding atas untuk CustomScrollView agar mulai di bawah top bar
                bottom: totalBottomPaddingForScrollView, // Padding bawah yang sudah dikoreksi
              ),
              child: CustomScrollView(
                controller: _scrollController,
                slivers: <Widget>[
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
                                  BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.25),
                                    blurRadius: 15, offset: Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: skipHeroAnimations
                                  ? bookCoverImage
                                  : Hero(
                                tag: 'bookCover_${widget.book.id}',
                                createRectTween: (Rect? begin, Rect? end) {
                                  return RectTween(begin: begin, end: end);
                                },
                                child: bookCoverImage,
                              ),
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
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            widget.book.title,
                            key: _mainTitleKey,
                            textAlign: TextAlign.center,
                            style: AppFonts.headerStyle.copyWith(
                                fontSize: responsiveFontSize(context, 24),
                                color: onSurfaceColor
                            ),
                          ),
                          SizedBox(height: responsiveFontSize(context, 6)),
                          GestureDetector( // <--- TAMBAHKAN INI
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AuthorProfileScreen(
                                    authorName: widget.book.author,
                                    // Anda bisa menambahkan authorId jika ada untuk mengambil data spesifik penulis
                                    // authorId: widget.book.authorId,
                                    authorImageUrl: "https://i.pravatar.cc/150?u=${widget.book.author.replaceAll(' ', '')}", // Placeholder image
                                  ),
                                ),
                              );
                            },
                            child: Text( // <--- BUNGKUS TEXT PENULIS
                              'By ${widget.book.author}',
                              textAlign: TextAlign.center,
                              style: AppFonts.titleMedium(color: onSurfaceSlightlyFadedColor.withOpacity(0.8)).copyWith( // Sedikit lebih jelas untuk di-tap
                                  fontSize: responsiveFontSize(context, 15),
                                  decorationColor: onSurfaceSlightlyFadedColor.withOpacity(0.8)
                              ),
                            ),
                          ),
                          SizedBox(height: responsiveFontSize(context, 24)),
                          _buildStatsSection(context, widget.book),
                          SizedBox(height: responsiveFontSize(context, 28)),
                          _buildGenreAndSynopsisSection(context, widget.book),
                          SizedBox(height: responsiveFontSize(context, 28)),
                          _buildChaptersButton(context),
                          SizedBox(height: responsiveFontSize(context, 28)),
                          _buildReviewsSection(context),
                          SizedBox(height: responsiveFontSize(context, 28)),
                          _buildRecommendationsSection(context, skipHeroAnimations),
                          SizedBox(height: responsiveFontSize(context, 20)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomDetailTopBar(
              backgroundColor: _currentTopBarBackgroundColor,
              iconColor: _currentTopBarIconColor,
              onBackPressed: () => Navigator.pop(context),
              onSharePressed: () { /* Aksi share */ },
              topPadding: statusBarPadding,
              // --- PERUBAHAN KUNCI UNTUK TOP BAR ---
              // Jika CustomDetailTopBar Anda mengharapkan tinggi total (termasuk status bar padding),
              // gunakan topBarHeight. Jika ia mengharapkan tinggi konten utama saja (dan mengelola
              // statusBarPadding secara internal), maka kToolbarHeight yang benar.
              // Berdasarkan info bahwa V0 (yang menggunakan topBarHeight di sini) tidak error, kita coba ini.
              height: topBarHeight,
              // Jika CustomDetailTopBar Anda dirancang untuk height = kToolbarHeight dan topPadding
              // adalah untuk internal SizedBox status bar, maka baris di atas HARUSNYA kToolbarHeight.
              // Silakan uji kedua opsi ini (topBarHeight vs kToolbarHeight) untuk melihat mana yang
              // menghilangkan overflow 5.9px pada top bar Anda, tergantung implementasi CustomDetailTopBar.
              // --- AKHIR PERUBAHAN KUNCI ---
              bookTitle: widget.book.title,
              bookAuthor: widget.book.author,
              showTitleAuthor: _showTopBarTitleAndAuthor,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildBottomActionButtons(context),
          ),
        ],
      ),
    );
  }

  // ... (Sisa metode build seperti _buildChaptersButton, _buildGenreAndSynopsisSection, dll. tetap sama)
  // ... (Pastikan metode _buildBottomActionButtons juga ada dan benar sesuai struktur awal Anda)

  Widget _buildChaptersButton(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              translate('label.chapters'),
              style: AppFonts.titleLarge(color: theme.textTheme.titleLarge?.color).copyWith(
                fontSize: responsiveFontSize(context, 18),
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(50,30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap
              ),
              onPressed: _showChaptersBottomSheet,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    translate('label.viewAllChapters', args: {'count': _dummyTotalChapters}),
                    style: GoogleFonts.montserrat(
                      fontSize: responsiveFontSize(context, 13),
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: responsiveFontSize(context, 2)),
                  Icon(Remix.arrow_right_s_line, color: theme.colorScheme.primary, size: responsiveFontSize(context, 20)),
                ],
              ),
            )
          ],
        ),
        SizedBox(height: responsiveFontSize(context, 12)),
        if (_dummyChapters.isNotEmpty)
          InkWell(
            onTap: _showChaptersBottomSheet,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: responsiveFontSize(context,12), horizontal: responsiveFontSize(context, 10)),
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(responsiveFontSize(context, 8))
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _dummyChapters.first.title,
                      style: GoogleFonts.montserrat(
                        fontSize: responsiveFontSize(context, 13.5),
                        color: theme.textTheme.bodyMedium?.color,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Remix.list_unordered, color: Colors.grey[600], size: responsiveFontSize(context, 20))
                ],
              ),
            ),
          )
        else
          Text(translate('label.noChaptersAvailable'), style: GoogleFonts.montserrat(color: Colors.grey[600], fontSize: responsiveFontSize(context, 13))),
      ],
    );
  }

  Widget _buildGenreAndSynopsisSection(BuildContext context, Book book) {
    ThemeData theme = Theme.of(context);
    Color chipBackgroundColor = theme.colorScheme.primary.withOpacity(0.08);
    Color chipTextColor = theme.colorScheme.primary;
    final genres = book.genres ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          translate('label.synopsis'),
          style: AppFonts.titleLarge(color: Theme.of(context).colorScheme.onSurface).copyWith(
            fontSize: responsiveFontSize(context, 18),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: responsiveFontSize(context, 12)),
        if (genres.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(bottom: responsiveFontSize(context, 12)),
            child: Wrap(
              spacing: responsiveFontSize(context, 8),
              runSpacing: responsiveFontSize(context, 8),
              children: genres.map((genre) {
                return Chip(
                  label: Text(
                      genre,
                      style: AppFonts.titleSmall(color: chipTextColor).copyWith(
                        fontSize: responsiveFontSize(context, 11),
                      )
                  ),
                  backgroundColor: chipBackgroundColor,
                  padding: EdgeInsets.symmetric(horizontal: responsiveFontSize(context, 10), vertical: responsiveFontSize(context, 4)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(responsiveFontSize(context, 16)),
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                );
              }).toList(),
            ),
          )
        else
          Padding(
            padding: EdgeInsets.only(bottom: responsiveFontSize(context, 12)),
            child: Text(
                translate('label.noGenresAvailable'),
                style: GoogleFonts.montserrat(fontSize: responsiveFontSize(context, 12), color: Colors.grey[600])
            ),
          ),
        AnimatedCrossFade(
          firstChild: Text(
            book.description,
            textAlign: TextAlign.justify,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: responsiveFontSize(context, 14),
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.85),
              height: 1.6,
            ),
          ),
          secondChild: Text(
            book.description,
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontSize: responsiveFontSize(context, 14),
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.85),
              height: 1.6,
            ),
          ),
          crossFadeState: _isSynopsisExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
        SizedBox(height: responsiveFontSize(context, 4)),
        InkWell(
          onTap: () {
            setState(() {
              _isSynopsisExpanded = !_isSynopsisExpanded;
            });
          },
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: responsiveFontSize(context, 4)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  translate(_isSynopsisExpanded ? 'label.showLess' : 'label.readMore'),
                  style: GoogleFonts.montserrat(
                    fontSize: responsiveFontSize(context, 13),
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(
                  _isSynopsisExpanded ? Remix.arrow_up_s_line : Remix.arrow_down_s_line,
                  size: responsiveFontSize(context, 18),
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsSection(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              translate('label.reviews'),
              style: AppFonts.titleLarge(color: theme.textTheme.titleLarge?.color).copyWith(
                fontSize: responsiveFontSize(context, 18),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              translate('label.seeAll', args: {'count': 0}),
              style: GoogleFonts.montserrat(
                fontSize: responsiveFontSize(context, 13),
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: responsiveFontSize(context, 20)),
        Center(
          child: Column(
            children: [
              Icon(
                Remix.quill_pen_line,
                size: responsiveFontSize(context, 50),
                color: Colors.grey[400],
              ),
              SizedBox(height: responsiveFontSize(context, 12)),
              Text(
                translate('label.noReviewsYet'),
                style: GoogleFonts.montserrat(fontSize: responsiveFontSize(context, 14), color: Colors.grey[600]),
              ),
              SizedBox(height: responsiveFontSize(context, 8)),
              TextButton(
                onPressed: () { /* TODO: Implement write review action */ },
                child: Text(
                  translate('label.writeFirstReview'),
                  style: GoogleFonts.montserrat(
                    fontSize: responsiveFontSize(context, 14),
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection(BuildContext context, Book book) {
    final Color statsBackgroundColor = Theme.of(context).colorScheme.surface;
    final Color statValueColor = Theme.of(context).colorScheme.onSurface;
    final Color statLabelColor = Colors.grey.shade600;

    return Container(
      padding: EdgeInsets.symmetric(vertical: responsiveFontSize(context,16), horizontal: responsiveFontSize(context,10)),
      decoration: BoxDecoration(
        color: statsBackgroundColor,
        borderRadius: BorderRadius.circular(responsiveFontSize(context, 16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(context, book.pages.toString(), translate('label.chapters'), statValueColor, statLabelColor),
          _buildVerticalDivider(context),
          _buildStatItem(context, book.language, translate('label.language'), statValueColor, statLabelColor),
          _buildVerticalDivider(context),
          _buildStatItem(context, book.rating.toStringAsFixed(1), translate('label.rating'), statValueColor, statLabelColor),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider(BuildContext context){
    return Container(
      height: responsiveFontSize(context, 35),
      width: 1,
      color: Theme.of(context).dividerColor.withOpacity(0.5),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label, Color valueColor, Color labelColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: responsiveFontSize(context, 17),
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
        SizedBox(height: responsiveFontSize(context, 4)),
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: responsiveFontSize(context, 12),
            color: labelColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionButtons(BuildContext context) {
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
        tooltip: translate(_isBookmarked ? 'label.bookmarkRemove' : 'label.bookmarkAdd'),
        onPressed: () {
          setState(() {
            _isBookmarked = !_isBookmarked;
          });
        },
        padding: EdgeInsets.zero,
        splashRadius: responsiveFontSize(context, 26),
      ),
    );

    Widget continueReadingButton = Expanded(
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ReadNovelScreen(
                chapterIntroLabelText: "Chapter 1",
                chapterTitleText: "Hutan Hitam",
                chapterBodyText: """
Malam turun seperti tirai kematian, membungkus desa Argama dengan hawa dingin yang tak wajar. Kabut mengendap rendah, menyusup ke setiap celah pintu dan jendela, seolah ingin mendengar bisikan terakhir dari mereka yang masih terjaga.

Di tengah kabut itu, seorang gadis berusia tujuh belas tahun berdiri di batas hutan—namanya Elira. Rambutnya gelap seperti arang, dan matanya mengandung sesuatu yang lama tidak dimiliki penduduk desa: rasa ingin tahu.

“Jangan masuk ke Hutan Hitam,” begitu selalu pesan Nenek Rhima. “Karena yang keluar dari sana bukan lagi manusia.”

Tapi malam ini berbeda. Seekor gagak bermata merah telah membisikkan namanya di ambang jendela, dan Elira tahu… kebenaran tentang keluarganya tersembunyi di balik pohon-pohon raksasa yang membentuk gerbang alam lain.

Ia melangkah masuk. Aroma tanah basah dan bunga busuk menyambutnya. Suara ranting patah terdengar dari arah yang tidak terlihat.

Lalu, ia menemukannya—pohon mati yang digambarkan dalam buku peninggalan ibunya. Di bawah akar yang mencuat seperti cakar, terukir simbol aneh dengan darah kering.

Dan di sanalah bayangan itu menunggu.

Bertubuh tinggi, berselubung jubah kelam, dengan wajah yang tak bisa dikenali. Hanya matanya yang terlihat—mata perak yang seolah melihat isi hatinya.

“Elira Veranith,” gumam makhluk itu. “Darah warisan telah bangkit. Kau adalah kunci yang hilang... dan kutukan yang belum ditebus.”

Elira membeku. Kata-kata itu mencabik kepalanya dengan ratusan pertanyaan. Siapa dirinya sebenarnya? Apa yang disembunyikan neneknya? Dan kenapa hutan ini memanggilnya sejak kecil?

Bayangan itu mengangkat tangannya. Dari tanah, tulang-tulang manusia muncul membentuk lingkaran, mengunci Elira dalam ritual yang tak bisa ia hentikan.

Dari balik kabut, suara-suara mulai berdatangan—tangisan, bisikan, tawa yang mengerikan. Elira menyadari: ini bukan sekadar hutan. Ini adalah gerbang dunia yang terlupakan.

Dan ia baru saja membuka jalan pulang bagi sesuatu... yang seharusnya tetap terkunci.
""",
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          minimumSize: Size(0, responsiveFontSize(context, 52)),
          padding: EdgeInsets.symmetric(vertical: responsiveFontSize(context, 15)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(responsiveFontSize(context, 12)),
          ),
          elevation: 4,
        ),
        child: Text(
          translate('label.continueReading'),
          style: GoogleFonts.montserrat(
            fontSize: responsiveFontSize(context, 16),
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );

    return Container(
      color: Theme.of(context).colorScheme.background,
      padding: EdgeInsets.only(
          left: responsiveFontSize(context, 20.0),
          right: responsiveFontSize(context, 20.0),
          top: responsiveFontSize(context, 12.0),
          bottom: MediaQuery.of(context).padding.bottom > 0
              ? MediaQuery.of(context).padding.bottom
              : responsiveFontSize(context, 12.0)
      ),
      child: Row(
        children: [
          bookmarkButton,
          SizedBox(width: responsiveFontSize(context, 12)),
          continueReadingButton,
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection(BuildContext context, bool skipHeroAnimations) {
    ThemeData theme = Theme.of(context);
    if (_recommendedBooks.isEmpty) {
      return const SizedBox.shrink();
    }
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final double bookItemImageHeight = responsiveFontSize(context, 170);
    final double bookItemWidth = bookItemImageHeight * (2.0/3.0);

    final TextPainter titlePainter = TextPainter(
      text: TextSpan(
        text: "Two Lines Example Title Text For Calc",
        style: GoogleFonts.montserrat(
          fontSize: responsiveFontSize(context, 12.0),
          fontWeight: FontWeight.w600,
        ),
      ),
      maxLines: 2,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: bookItemWidth);

    final TextPainter authorPainter = TextPainter(
      text: TextSpan(
        text: "Author Name Example",
        style: GoogleFonts.montserrat(
          fontSize: responsiveFontSize(context, 10.0),
        ),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: bookItemWidth);

    final double textBlockHeight =
        responsiveFontSize(context, 6) +
            titlePainter.height +
            responsiveFontSize(context, 2) +
            authorPainter.height +
            responsiveFontSize(context, 4);

    final double totalItemHeight = bookItemImageHeight + textBlockHeight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: responsiveFontSize(context, 0)),
          child: Text(
            translate('label.recommendations'),
            style: AppFonts.titleLarge(color: theme.textTheme.titleLarge?.color).copyWith(
              fontSize: responsiveFontSize(context, 18),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: responsiveFontSize(context, 16)),
        SizedBox(
          height: totalItemHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _recommendedBooks.length,
            itemBuilder: (context, index) {
              final book = _recommendedBooks[index];
              return Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 0 : responsiveFontSize(context, 12),
                ),
                child: _RecommendedBookItem(
                    book: book,
                    width: bookItemWidth,
                    imageHeight: bookItemImageHeight,
                    itemDevicePixelRatio: devicePixelRatio,
                    skipHeroAnimation: skipHeroAnimations,
                    onTap: () {
                      if (widget.book.id != book.id) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => BookDetailScreen(book: book)),
                        );
                      }
                    }
                ),
              );
            },
            padding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}

class _RecommendedBookItem extends StatelessWidget {
  final Book book;
  final double width;
  final double imageHeight;
  final double itemDevicePixelRatio;
  final VoidCallback onTap;
  final bool skipHeroAnimation;

  static const double _recommendedItemImageClipRadius = 10.0;

  const _RecommendedBookItem({
    required this.book,
    required this.width,
    required this.imageHeight,
    required this.itemDevicePixelRatio,
    required this.onTap,
    required this.skipHeroAnimation,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    const double sourceImageClipRadius = _recommendedItemImageClipRadius;
    const double destinationDetailImageClipRadius = _BookDetailScreenState.detailImageClipRadius;

    Widget bookImageWidget = ClipRRect(
      borderRadius: BorderRadius.circular(sourceImageClipRadius),
      child: CachedNetworkImage(
        imageUrl: book.imageUrl,
        height: imageHeight,
        width: width,
        fit: BoxFit.cover,
        memCacheHeight: (imageHeight * itemDevicePixelRatio).round(),
        memCacheWidth: (width * itemDevicePixelRatio).round(),
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
              height: imageHeight, width: width, color: Colors.white),
        ),
        errorWidget: (context, error, stackTrace) {
          return Container(
            height: imageHeight,
            width: width,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(sourceImageClipRadius),
            ),
            child: Icon(Remix.image_line, size: responsiveFontSize(context, 40), color: Colors.grey[400]),
          );
        },
      ),
    );

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            skipHeroAnimation
                ? bookImageWidget
                : Hero(
              tag: 'bookCover_${book.id}',
              createRectTween: (Rect? begin, Rect? end) {
                return RectTween(begin: begin, end: end);
              },
              flightShuttleBuilder: (
                  BuildContext flightContext,
                  Animation<double> animation,
                  HeroFlightDirection flightDirection,
                  BuildContext fromHeroContext,
                  BuildContext toHeroContext,
                  ) {
                final Book currentBook = book;
                BorderRadius fromRadius = BorderRadius.circular(sourceImageClipRadius);
                BorderRadius toRadius = BorderRadius.circular(destinationDetailImageClipRadius);
                BorderRadius animatedRadius = BorderRadius.lerp(
                    flightDirection == HeroFlightDirection.push ? fromRadius : toRadius,
                    flightDirection == HeroFlightDirection.push ? toRadius : fromRadius,
                    animation.value)!;
                return ClipRRect(
                  borderRadius: animatedRadius,
                  child: CachedNetworkImage(
                    imageUrl: currentBook.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: Colors.grey[200]),
                    errorWidget: (context, url, error) => Container(color: Colors.grey[200]),
                  ),
                );
              },
              child: bookImageWidget,
            ),
            SizedBox(height: responsiveFontSize(context, 6)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: responsiveFontSize(context, 2.0)),
              child: Text(
                book.title,
                style: GoogleFonts.montserrat(
                  fontSize: responsiveFontSize(context, 12.0),
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: responsiveFontSize(context, 2)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: responsiveFontSize(context, 2.0)),
              child: Text(
                book.author,
                style: GoogleFonts.montserrat(
                  fontSize: responsiveFontSize(context, 10.0),
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
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