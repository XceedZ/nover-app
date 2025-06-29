// lib/features/search/screens/search_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nover/src/utils/app_fonts.dart';
import 'package:nover/src/utils/ui_helpers.dart';
import 'package:nover/features/home/screens/home_screen_content.dart' show Book;
import 'package:nover/features/books/screens/book_detail_screen.dart';
import 'package:nover/src/widgets/book_stats_row_widget.dart';
import 'package:remixicon/remixicon.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

// --- Definisi BookCard dan HorizontalBookList (Tidak ada perubahan) ---
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
      tag: 'bookCover_${book.id}',
      child: Material(
        type: MaterialType.transparency,
        child: GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => BookDetailScreen(book: book)));
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
                      imageUrl: book.imageUrl,
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
                  child: Text(book.title, style: GoogleFonts.montserrat(fontSize: responsiveFontSize(context, 13), fontWeight: FontWeight.w600, color: titleColor), maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
                SizedBox(height: responsiveFontSize(context, 3)),
                if (book.author.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: responsiveFontSize(context, 2)),
                    child: Text(book.author, style: GoogleFonts.montserrat(fontSize: responsiveFontSize(context, 11), color: authorColor, fontWeight: FontWeight.w400), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
// --- Akhir Definisi ---


class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // ... (Logika State SearchScreen tidak ada perubahan)
  final TextEditingController _searchController = TextEditingController();
  List<Book> _displayBooksInCarousel = [];
  bool _isLoading = false;
  String _currentQuery = "";
  List<Book> _trendingNovelsData = [];
  final List<Book> _allBooksForDemo = [
    Book(id: 301, title: "The Silent Patient", chapter: "Preview", author: "Alex Michaelides",
        imageUrl: "https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEiue8RWfDLFk_oKlNDz1HS6MCagKJ9WG3Hwz8rlyRNyt_tkaZNSgrzXa6P2996vgQGQHIjO9FY5MgtxJw49BmQcBHHjHl0auO3SJ_JOL3P-T0LY00Bt9n_lexYL-rd23VjcMm8pT6pBqhk_TTMTIAymW6wtwgF0bgx0lASyvIkGDzCmopSJ2OfOk1Ov/s1000/81dkqO5LAQL._AC_UF1000,1000_QL80_.jpg",
        rating: 4.8, pages: 336, language: "Eng",
        description: "Alicia Berenson’s life is seemingly perfect. A famous painter married to an in-demand fashion photographer, she lives in a grand house with big windows overlooking a park in one of London’s most desirable areas.",
        genres: ["Thriller", "Mystery"]),
    Book(id: 302, title: "Atomic Habits", chapter: "Preview", author: "James Clear",
        imageUrl: "https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1535115320i/40121378.jpg",
        rating: 4.9, pages: 320, language: "Eng",
        description: "No matter your goals, Atomic Habits offers a proven framework for improving--every day. James Clear, one of the world's leading experts on habit formation, reveals practical strategies that will teach you exactly how to form good habits, break bad ones, and master the tiny behaviors that lead to remarkable results.",
        genres: ["Self-help", "Productivity"]),
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
        final authorMatch = book.author.toLowerCase().contains(_currentQuery.toLowerCase());
        final genreMatch = book.genres.any((genre) => genre.toLowerCase().contains(_currentQuery.toLowerCase()));
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
    // ... (Logika build SearchScreen tidak ada perubahan)
    final ThemeData theme = Theme.of(context);
    final Color screenBackgroundColor = theme.colorScheme.background;
    final Color appBarBackgroundColor = theme.colorScheme.surface;
    final Color onAppBarColor = theme.colorScheme.onSurface;
    final Color onScreenTextColor = theme.colorScheme.onBackground;
    final Brightness statusBarIconBrightness =
    _isColorDark(appBarBackgroundColor) ? Brightness.light : Brightness.dark;
    final Brightness statusBarBrightnessForApple =
    _isColorDark(appBarBackgroundColor) ? Brightness.dark : Brightness.light;
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
            key: ValueKey("carousel_${_currentQuery}_${_displayBooksInCarousel.map((b)=>b.id).join()}"),
            books: _displayBooksInCarousel,
            onBookTap: (book) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BookDetailScreen(book: book)),
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
                style: AppFonts.titleMedium(color: onScreenTextColor.withOpacity(0.6)).copyWith(
                  fontSize: responsiveFontSize(context, 15),
                  height: 1.5,
                ),
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
          style: AppFonts.titleMedium(color: onAppBarColor).copyWith(
            fontSize: responsiveFontSize(context, 16),
          ),
          decoration: InputDecoration(
            hintText: "Search books, authors, genres...",
            hintStyle: AppFonts.titleSmall(color: onAppBarColor.withOpacity(0.5)).copyWith(
              fontSize: responsiveFontSize(context, 15),
            ),
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
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
          padding: EdgeInsets.only(
              left: responsiveFontSize(context, 16.0),
              right: responsiveFontSize(context, 16.0),
              top: responsiveFontSize(context, 10.0),
              bottom: responsiveFontSize(context, 16.0)
          ),
          child: Text(
            'Trending Novel',
            style: AppFonts.titleLarge(color: titleColor).copyWith(
              fontSize: responsiveFontSize(context, 18),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        HorizontalBookList(books: _trendingNovelsData),
        SizedBox(height: responsiveFontSize(context, 20)),
      ],
    );
  }
}


class SearchFeaturedBookCarousel extends StatefulWidget {
  // ... (properti tidak ada perubahan)
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
  // ... (logika state tidak ada perubahan)
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
        widget.books.map((b) => b.id).join(',') != oldWidget.books.map((b) => b.id).join(',');
    if (booksHaveChanged) {
      int targetPage = 0;
      if (_pageController.hasClients && widget.books.isNotEmpty) {
        targetPage = _pageController.page?.round().clamp(0, widget.books.length -1) ?? 0;
        if (targetPage >= widget.books.length) targetPage = 0;
      }
      _pageController.dispose();
      _currentPage = targetPage;
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
              // ... (logika PageView.builder tidak ada perubahan)
              controller: _pageController,
              itemCount: widget.books.length,
              onPageChanged: (index) {
                if (mounted) {
                  setState(() {
                    _currentPage = index;
                  });
                }
              },
              itemBuilder: (context, index) {
                final book = widget.books[index];
                double scale;
                double opacity;
                double verticalOffset;
                double pageDistance = (_pageOffset - index).abs();
                scale = (1 - (pageDistance * 0.25)).clamp(0.65, 1.0);
                opacity = (1 - (pageDistance * 0.7)).clamp(0.1, 1.0);
                verticalOffset = pageDistance * responsiveFontSize(context, 30);
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
                                boxShadow: [
                                  if (scale > 0.95)
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      spreadRadius: 0.2,
                                      offset: const Offset(0, 3),
                                    )
                                ]
                            ),
                            child: Hero(
                              tag: 'bookCover_${book.id}',
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12.0),
                                child: CachedNetworkImage(
                                  imageUrl: book.imageUrl,
                                  fit: BoxFit.cover,
                                  memCacheHeight: (_carouselCoverHeight * devicePixelRatio).round(),
                                  memCacheWidth: (_carouselCoverWidth * devicePixelRatio).round(),
                                  placeholder: (context, url) => Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Container(
                                      width: _carouselCoverWidth,
                                      height: _carouselCoverHeight,
                                      color: Theme.of(context).colorScheme.surfaceVariant,
                                    ),
                                  ),
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
                key: ValueKey<String>("detail_search_page_${currentBook.id}"),
                children: [
                  Text(
                    currentBook.title,
                    textAlign: TextAlign.center,
                    style: AppFonts.headerStyle.copyWith(
                      fontSize: responsiveFontSize(context, 18),
                      color: widget.onSectionColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: responsiveFontSize(context, 6)),
                  Text(
                    currentBook.author,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: responsiveFontSize(context, 13),
                      color: widget.onSectionColor.withOpacity(0.75),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: responsiveFontSize(context, 16)),

                  // --- PERUBAHAN DI SINI ---
                  // Mengganti BookStatsRowWidget lama dengan komposisi widget baru
                  StatsRowContainer(
                    children: [
                      StatItem(value: currentBook.pages.toString(), label: "Chapters"),
                      const StatDivider(),
                      StatItem(value: currentBook.language, label: "Language"),
                      const StatDivider(),
                      StatItem(value: currentBook.rating.toStringAsFixed(1), label: "Rating"),
                    ],
                  ),

                  SizedBox(height: responsiveFontSize(context, 16)),
                  Text(
                    currentBook.description,
                    style: GoogleFonts.montserrat(
                      fontSize: responsiveFontSize(context, 12),
                      color: widget.onSectionColor.withOpacity(0.7),
                      height: 1.4,
                    ),
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