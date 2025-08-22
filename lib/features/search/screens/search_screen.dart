// lib/features/search/screens/search_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nover/src/utils/app_fonts.dart';
import 'package:nover/src/utils/ui_helpers.dart';
import 'package:nover/src/models/book.dart';
import 'package:nover/features/books/screens/book_detail_screen.dart';
import 'package:nover/src/widgets/book_stats_row_widget.dart';
import 'package:remixicon/remixicon.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

// --- Definisi BookCard dan HorizontalBookList ---
class HorizontalBookList extends StatelessWidget {
  final List<Book> books;
  final double? listHeight;
  const HorizontalBookList({super.key, required this.books, this.listHeight});

  @override
  Widget build(BuildContext context) {
    double cardDisplayHeight = listHeight ?? responsiveFontSize(context, 310);
    return SizedBox(
      height: cardDisplayHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: books.length,
        padding: EdgeInsets.symmetric(horizontal: responsiveFontSize(context, 16.0)),
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(right: index == books.length - 1 ? 0 : responsiveFontSize(context, 16.0)),
            child: BookCard(book: books[index]),
          );
        },
      ),
    );
  }
}

class BookCard extends StatelessWidget {
  final Book book;
  static const double _cardImageClipRadius = 12.0;

  const BookCard({super.key, required this.book});

  Widget _buildImageErrorWidget(BuildContext context, double height, double width) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(_cardImageClipRadius)
      ),
      child: Center(child: Icon(Remix.image_line, size: responsiveFontSize(context, 50), color: Colors.grey.shade600)),
    );
  }

  @override
  Widget build(BuildContext context) {
    double cardWidth = responsiveFontSize(context, 160);
    double imageHeight = responsiveFontSize(context, 240);
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

    Color titleColor = Theme.of(context).colorScheme.onSurface;
    Color authorColor = Theme.of(context).colorScheme.onSurfaceVariant;

    return Hero(
      tag: 'bookCover_${book.bookId}',
      child: Material(
        type: MaterialType.transparency,
        child: GestureDetector(
          onTap: () {
            // --- PERBAIKAN: Sesuaikan pemanggilan dengan konstruktor baru ---
            Navigator.push(context, MaterialPageRoute(
                builder: (context) => BookDetailScreen(
                  bookId: book.bookId,
                  initialBookData: book,
                ))
            );
          },
          child: SizedBox(
            width: cardWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(_cardImageClipRadius),
                  child: SizedBox(
                    height: imageHeight,
                    width: cardWidth,
                    child: CachedNetworkImage(
                      imageUrl: book.coverImageUrl,
                      fit: BoxFit.cover,
                      memCacheHeight: (imageHeight * devicePixelRatio).round(),
                      memCacheWidth: (cardWidth * devicePixelRatio).round(),
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          height: imageHeight,
                          width: cardWidth,
                          color: Theme.of(context).colorScheme.surfaceVariant,
                        ),
                      ),
                      errorWidget: (context, url, error) => _buildImageErrorWidget(context, imageHeight, cardWidth),
                    ),
                  ),
                ),
                SizedBox(height: responsiveFontSize(context, 10)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: responsiveFontSize(context, 2)),
                  child: Text(
                      book.title,
                      style: AppFonts.bodyMedium(color: titleColor)?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis
                  ),
                ),
                SizedBox(height: responsiveFontSize(context, 3)),
                if (book.author != null && book.author!.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: responsiveFontSize(context, 2)),
                    child: Text(
                        book.author!,
                        style: AppFonts.bodySmall(color: authorColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Book> _displayBooksInCarousel = [];
  bool _isLoading = false;
  String _currentQuery = "";
  List<Book> _trendingNovelsData = [];

  // Data dummy disesuaikan dengan model Book yang benar
  final List<Book> _allBooksForDemo = [
    Book(
        bookId: 301, title: "The Silent Patient", status: "P", author: "Alex Michaelides",
        coverImageUrl: "https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEiue8RWfDLFk_oKlNDz1HS6MCagKJ9WG3Hwz8rlyRNyt_tkaZNSgrzXa6P2996vgQGQHIjO9FY5MgtxJw49BmQcBHHjHl0auO3SJ_JOL3P-T0LY00Bt9n_lexYL-rd23VjcMm8pT6pBqhk_TTMTIAymW6wtwgF0bgx0lASyvIkGDzCmopSJ2OfOk1Ov/s1000/81dkqO5LAQL._AC_UF1000,1000_QL80_.jpg",
        ratingAverage: 4.8, description: "Alicia Berenson’s life is seemingly perfect...",
        genres: "Thriller, Mystery", createDatetime: DateTime.now().toIso8601String(), updateDatetime: DateTime.now().toIso8601String(), totalViews: 10200
    ),
    Book(
        bookId: 302, title: "Atomic Habits", status: "C", author: "James Clear",
        coverImageUrl: "https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1535115320i/40121378.jpg",
        ratingAverage: 4.9, description: "No matter your goals, Atomic Habits offers a proven framework for improving--every day.",
        genres: "Self-help, Productivity", createDatetime: DateTime.now().toIso8601String(), updateDatetime: DateTime.now().toIso8601String(), totalViews: 9870
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _searchController.addListener(() {
      if (mounted) {
        if (_searchController.text.isEmpty && _currentQuery.isNotEmpty) {
          _performSearch("");
        }
      }
    });
  }

  Future<void> _loadInitialData() async {
    if (mounted) setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 300));
    _trendingNovelsData = _allBooksForDemo.take(5).toList();
    _displayBooksInCarousel = List.from(_allBooksForDemo);
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    _currentQuery = query.trim();
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      if (_currentQuery.isNotEmpty) {
        _displayBooksInCarousel = [];
      }
    });

    await Future.delayed(const Duration(milliseconds: 600));

    List<Book> results = [];
    if (_currentQuery.isNotEmpty) {
      results = _allBooksForDemo.where((book) {
        final titleMatch = book.title.toLowerCase().contains(_currentQuery.toLowerCase());
        final authorMatch = (book.author ?? '').toLowerCase().contains(_currentQuery.toLowerCase());
        final genreMatch = (book.genres ?? '').toLowerCase().contains(_currentQuery.toLowerCase());
        return titleMatch || authorMatch || genreMatch;
      }).toList();
    } else {
      results = List.from(_allBooksForDemo);
    }

    if (mounted) {
      setState(() {
        _displayBooksInCarousel = results;
        _isLoading = false;
      });
    }
  }

  bool _isColorDark(Color color) {
    return color.computeLuminance() < 0.5;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color screenBackgroundColor = theme.colorScheme.background;
    final Color appBarBackgroundColor = theme.colorScheme.surface;
    final Color onAppBarColor = theme.colorScheme.onSurface;
    final Color onScreenTextColor = theme.colorScheme.onBackground;
    final Brightness statusBarIconBrightness = _isColorDark(appBarBackgroundColor) ? Brightness.light : Brightness.dark;
    final Brightness statusBarBrightnessForApple = _isColorDark(appBarBackgroundColor) ? Brightness.dark : Brightness.light;

    Widget bodyContent;
    if (_isLoading && _currentQuery.isNotEmpty && _displayBooksInCarousel.isEmpty) {
      bodyContent = Center(
        child: LoadingAnimationWidget.staggeredDotsWave(
          color: theme.colorScheme.primary,
          size: responsiveFontSize(context, 50),
        ),
      );
    } else if (_displayBooksInCarousel.isNotEmpty) {
      bodyContent = Column(
        children: [
          SearchFeaturedBookCarousel(
            key: ValueKey("carousel_${_currentQuery}_${_displayBooksInCarousel.map((b)=>b.bookId).join()}"),
            books: _displayBooksInCarousel,
            onBookTap: (book) {
              // --- PERBAIKAN: Sesuaikan pemanggilan dengan konstruktor baru ---
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => BookDetailScreen(
                    bookId: book.bookId,
                    initialBookData: book,
                  ))
              );
            },
            onSectionColor: onScreenTextColor,
          ),
          SizedBox(height: responsiveFontSize(context, 28)),
          _buildTrendingSection(onScreenTextColor),
        ],
      );
    } else {
      bodyContent = Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: responsiveFontSize(context, 24.0),
                vertical: responsiveFontSize(context, 60.0)
            ),
            child: Center(
              child: Text(
                _currentQuery.isNotEmpty
                    ? 'No results found for "$_currentQuery".\nPlease try a different keyword.'
                    : 'Search for books, authors, or genres.',
                textAlign: TextAlign.center,
                style: AppFonts.titleMedium(color: onScreenTextColor.withOpacity(0.6))?.copyWith(height: 1.5),
              ),
            ),
          ),
          _buildTrendingSection(onScreenTextColor),
        ],
      );
    }

    return Scaffold(
      backgroundColor: screenBackgroundColor,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: appBarBackgroundColor,
          statusBarIconBrightness: statusBarIconBrightness,
          statusBarBrightness: statusBarBrightnessForApple,
        ),
        backgroundColor: appBarBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Remix.arrow_left_s_line, color: onAppBarColor, size: responsiveFontSize(context, 26)),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: AppFonts.titleMedium(color: onAppBarColor),
          decoration: InputDecoration(
            hintText: "Search books, authors, genres...",
            hintStyle: AppFonts.titleSmall(color: onAppBarColor.withOpacity(0.5)),
            border: InputBorder.none,
          ),
          onSubmitted: _performSearch,
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: Icon(Remix.close_circle_fill, color: onAppBarColor.withOpacity(0.7), size: responsiveFontSize(context, 22)),
              onPressed: () {
                _searchController.clear();
                _performSearch("");
              },
            )
          else
            SizedBox(width: responsiveFontSize(context, 48)),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: screenBackgroundColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: bodyContent,
        ),
      ),
    );
  }

  Widget _buildTrendingSection(Color titleColor) {
    if (_trendingNovelsData.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: responsiveFontSize(context, 16.0),
              vertical: responsiveFontSize(context, 10.0)
          ),
          child: Text(
            'Trending Novel',
            style: AppFonts.titleLarge(color: titleColor)?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        HorizontalBookList(books: _trendingNovelsData),
        SizedBox(height: responsiveFontSize(context, 20)),
      ],
    );
  }
}

class SearchFeaturedBookCarousel extends StatefulWidget {
  final List<Book> books;
  final Function(Book) onBookTap;
  final Color onSectionColor;
  const SearchFeaturedBookCarousel({
    super.key,
    required this.books,
    required this.onBookTap,
    required this.onSectionColor,
  });

  @override
  State<SearchFeaturedBookCarousel> createState() => _SearchFeaturedBookCarouselState();
}

class _SearchFeaturedBookCarouselState extends State<SearchFeaturedBookCarousel> {
  late PageController _pageController;
  int _currentPage = 0;
  double _pageOffset = 0.0;
  final double _carouselCoverBaseHeight = 250.0;
  double _carouselCoverHeight = 250.0;
  double _carouselCoverWidth = 250.0 * (2.0/3.0);

  @override
  void initState() {
    super.initState();
    _initializePageControllerAndOffset();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final newCoverHeight = responsiveFontSize(context, _carouselCoverBaseHeight);
        final newCoverWidth = newCoverHeight * (2.0 / 3.0);
        if (_carouselCoverHeight != newCoverHeight || _carouselCoverWidth != newCoverWidth) {
          setState(() {
            _carouselCoverHeight = newCoverHeight;
            _carouselCoverWidth = newCoverWidth;
          });
        }
      }
    });
  }

  void _initializePageControllerAndOffset() {
    int initialPage = 0;
    _currentPage = initialPage;
    _pageOffset = _currentPage.toDouble();
    _pageController = PageController(
      initialPage: _currentPage,
      viewportFraction: 0.62,
    );
    _pageController.addListener(() {
      if (mounted && _pageController.page != null) {
        setState(() {
          _pageOffset = _pageController.page!;
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant SearchFeaturedBookCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    bool booksHaveChanged = widget.books.length != oldWidget.books.length ||
        widget.books.map((b) => b.bookId).join(',') != oldWidget.books.map((b) => b.bookId).join(',');
    if (booksHaveChanged) {
      int targetPage = 0;
      if (_pageController.hasClients && widget.books.isNotEmpty) {
        targetPage = _pageController.page?.round().clamp(0, widget.books.length -1) ?? 0;
        if (targetPage >= widget.books.length) targetPage = 0;
      }
      _pageController.dispose();
      _currentPage = targetPage;
      _initializePageControllerAndOffset();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildCarouselImageErrorWidget(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Icon(Remix.image_line, size: responsiveFontSize(context, 50), color: Theme.of(context).colorScheme.onSurfaceVariant),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.books.isEmpty) {
      return const SizedBox.shrink();
    }
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    int displayPageIndex = _pageOffset.round().clamp(0, widget.books.length - 1);
    Book currentBook = widget.books[displayPageIndex];
    double pageViewHeight = _carouselCoverHeight + responsiveFontSize(context, 30);

    return Container(
      padding: EdgeInsets.symmetric(vertical: responsiveFontSize(context, 10)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: pageViewHeight,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.books.length,
              onPageChanged: (index) {
                if (mounted) setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) {
                final book = widget.books[index];
                double scale = (1 - ((_pageOffset - index).abs() * 0.25)).clamp(0.65, 1.0);
                double opacity = (1 - ((_pageOffset - index).abs() * 0.7)).clamp(0.1, 1.0);
                double verticalOffset = (_pageOffset - index).abs() * responsiveFontSize(context, 30);

                return Center(
                  child: Transform.translate(
                    offset: Offset(0, verticalOffset),
                    child: Opacity(
                      opacity: opacity,
                      child: Transform.scale(
                        scale: scale,
                        child: GestureDetector(
                          onTap: () => widget.onBookTap(book),
                          child: Container(
                            width: _carouselCoverWidth,
                            height: _carouselCoverHeight,
                            margin: EdgeInsets.symmetric(horizontal: responsiveFontSize(context, 3)),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.0),
                                boxShadow: [ if (scale > 0.95) BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 3)) ]
                            ),
                            child: Hero(
                              tag: 'bookCover_${book.bookId}',
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12.0),
                                child: CachedNetworkImage(
                                  imageUrl: book.coverImageUrl,
                                  fit: BoxFit.cover,
                                  memCacheHeight: (_carouselCoverHeight * devicePixelRatio).round(),
                                  memCacheWidth: (_carouselCoverWidth * devicePixelRatio).round(),
                                  placeholder: (context, url) => Shimmer.fromColors(baseColor: Colors.grey[300]!, highlightColor: Colors.grey[100]!, child: Container(color: Theme.of(context).colorScheme.surfaceVariant)),
                                  errorWidget: (context, url, error) => _buildCarouselImageErrorWidget(context),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: responsiveFontSize(context, 12)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: responsiveFontSize(context, 20)),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
              child: Column(
                key: ValueKey<int>(currentBook.bookId),
                children: [
                  Text(
                    currentBook.title,
                    textAlign: TextAlign.center,
                    style: AppFonts.headerStyle?.copyWith(fontSize: responsiveFontSize(context, 18), color: widget.onSectionColor),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: responsiveFontSize(context, 6)),
                  Text(
                    currentBook.author ?? '',
                    textAlign: TextAlign.center,
                    style: AppFonts.bodyMedium(color: widget.onSectionColor.withOpacity(0.75))?.copyWith(fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: responsiveFontSize(context, 16)),
                  StatsRowContainer(
                    children: [
                      StatItem(value: (currentBook.totalViews).toString(), label: "Views"),
                      const StatDivider(),
                      StatItem(value: currentBook.status, label: "Status"),
                      const StatDivider(),
                      StatItem(value: currentBook.ratingAverage.toStringAsFixed(1), label: "Rating"),
                    ],
                  ),
                  SizedBox(height: responsiveFontSize(context, 16)),
                  Text(
                    currentBook.description,
                    style: AppFonts.bodySmall(color: widget.onSectionColor.withOpacity(0.7))?.copyWith(height: 1.4),
                    maxLines: 3,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: responsiveFontSize(context, 10)),
        ],
      ),
    );
  }
}