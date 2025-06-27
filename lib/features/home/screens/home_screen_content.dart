// lib/features/home/screens/home_screen_content.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nover/features/books/screens/book_detail_screen.dart';
import 'package:nover/src/utils/app_fonts.dart';
import 'package:remixicon/remixicon.dart';
import 'package:nover/features/home/widgets/sticky_reading_progress_widget.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';

// --- Fungsi Helper untuk Font Adaptif ---
double responsiveFontSize(BuildContext context, double baseFontSize) {
  const double referenceWidth = 375.0;
  double screenWidth = MediaQuery.of(context).size.width;
  double scaleFactor = screenWidth / referenceWidth;
  return baseFontSize * scaleFactor.clamp(0.9, 1.2);
}

// --- Model Data Buku ---
class Book {
  final String title;
  final String chapter;
  final String author;
  final List<String> genres;
  final String imageUrl;
  final double rating;
  final int id;
  final int pages;
  final String language;
  final String description;

  Book({
    required this.id,
    required this.title,
    required this.chapter,
    required this.author,
    required this.imageUrl,
    required this.rating,
    this.pages = 252,
    this.genres = const [],
    this.language = "Eng",
    this.description =
    "This is a captivating novel that takes readers on an extraordinary journey...",
  });
}

// --- Widget Utama Konten Beranda (Stateful) ---
class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({super.key});

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  bool _isLoading = true;
  List<Book> _curatedBooks = [];
  List<Book> _mustReadBooks = [];
  Book? _lastReadBook;
  bool _isStickyProgressVisible = true;

  @override
  void initState() {
    super.initState();
    _loadData(isInitialLoad: true);
  }

  Future<void> _loadData({bool isInitialLoad = false}) async {
    if (!isInitialLoad && mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    await Future.delayed(Duration(seconds: isInitialLoad ? 2 : 1));
    _curatedBooks = [
      Book(
          id: 1,
          title: isInitialLoad ? 'Me Before You' : 'Me Before You (Refreshed)',
          chapter: '',
          author: 'Jojo Moyes',
          imageUrl: 'https://th.bing.com/th/id/R.82199d4b68353382f63987c40be40ce7?rik=xte1cGRjPWBosw&riu=http%3a%2f%2f2.bp.blogspot.com%2f-oCpIvfwa1gE%2fTwbgWGAfxcI%2fAAAAAAAAAoc%2fBzy_5rDIYys%2fs1600%2fMebeforeYou21.jpg&ehk=WhgjZZuufHwn1a%2b1MbdsJGIAMWSUwvE1AaVNpcod8ZY%3d&risl=&pid=ImgRaw&r=0',
          rating: isInitialLoad ? 4.8 : 4.9),
      Book(
          id: 2,
          title: 'Dune',
          chapter: 'Chapter 1',
          author: 'Frank Herbert',
          imageUrl: 'https://th.bing.com/th/id/OIP.cvoSdGRO8TtT-zw5N0qAAQHaLL?cb=iwc2&rs=1&pid=ImgDetMain',
          rating: 4.8),
      Book(
          id: 3,
          title: 'Eleanor Oliphant Is Completely Fine',
          chapter: 'Chapter 5',
          author: 'Gail Honeyman',
          imageUrl: 'https://i.gr-assets.com/images/S/compressed.photo.goodreads.com/books/1493724347l/31434883.jpg',
          rating: 4.5),
    ];
    _mustReadBooks = [
      Book(
          id: 4,
          title: isInitialLoad ? 'The Tale of Genji' : 'The Tale of Genji (Refreshed)',
          chapter: '',
          author: 'Murasaki Shikibu',
          imageUrl: 'https://m.media-amazon.com/images/I/71+KsvdlIYL._SL1500_.jpg',
          rating: 4.7),
      Book(
          id: 5,
          title: 'Project Hail Mary',
          chapter: '',
          author: 'Andy Weir',
          imageUrl: 'https://cdn11.bigcommerce.com/s-65f8qukrjx/images/stencil/800w/products/6929/17271/Weir_Project_Hail_Mary_cover__95757.1687451127.jpg?c=1',
          rating: 4.9),
      Book(
          id: 6,
          title: 'Klara and the Sun',
          chapter: '',
          author: 'Kazuo Ishiguro',
          imageUrl: 'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1603206535i/54120408.jpg',
          rating: 4.6),
    ];
    _lastReadBook = Book(
        id: 100,
        title: isInitialLoad ? 'The Crimson Crown' : 'The Crimson Crown (Refreshed)',
        chapter: 'Chapter 14 - The Revelation',
        author: 'Heather Walter',
        imageUrl: 'https://m.media-amazon.com/images/I/81cd9wVmIrL._SL1500_.jpg',
        rating: isInitialLoad ? 4.6 : 4.7,
        genres: ["Mystery", "Thriller"]);
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (_lastReadBook != null) {
          _isStickyProgressVisible = true;
        }
      });
    }
  }

  Future<void> _handleRefresh() async {
    await _loadData(isInitialLoad: false);
  }

  void _hideStickyProgress() {
    if (mounted) {
      setState(() {
        _isStickyProgressVisible = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color onBackgroundColor = Theme.of(context).colorScheme.onBackground;
    final double skCardWidth = responsiveFontSize(context, 160);
    final double skImageHeight = responsiveFontSize(context, 240);
    final double skCardBorderRadius = 12.0;
    final double skListDisplayHeight = responsiveFontSize(context, 310);
    const double stickyWidgetHeightBuffer = 100.0;

    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: _handleRefresh,
                color: Theme.of(context).colorScheme.primary,
                backgroundColor: Theme.of(context).cardColor,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(top: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Whispers of Fiction.',
                          style: AppFonts.headerStyle.copyWith(
                            fontSize: responsiveFontSize(context, 30),
                            color: onBackgroundColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'For You',
                          style: GoogleFonts.montserrat(
                            fontSize: responsiveFontSize(context, 16),
                            fontWeight: FontWeight.w600,
                            color: onBackgroundColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _isLoading
                          ? _HorizontalBookListSkeleton(
                        cardDisplayHeight: skListDisplayHeight,
                        cardWidth: skCardWidth,
                        imageHeight: skImageHeight,
                        cardBorderRadius: skCardBorderRadius,
                      )
                          : _HorizontalBookList(books: _curatedBooks),
                      const SizedBox(height: 28),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Must Read',
                          style: GoogleFonts.montserrat(
                            fontSize: responsiveFontSize(context, 16),
                            fontWeight: FontWeight.w600,
                            color: onBackgroundColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _isLoading
                          ? _HorizontalBookListSkeleton(
                        cardDisplayHeight: skListDisplayHeight,
                        cardWidth: skCardWidth,
                        imageHeight: skImageHeight,
                        cardBorderRadius: skCardBorderRadius,
                      )
                          : _HorizontalBookList(books: _mustReadBooks),
                      const SizedBox(height: 28),
                      if (!_isLoading)
                        SizedBox(height: _isStickyProgressVisible ? stickyWidgetHeightBuffer : 16.0),
                      if (_isLoading)
                        const SizedBox(height: 16.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 1.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOutQuart)),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: (_isStickyProgressVisible && !_isLoading && _lastReadBook != null)
                ? StickyReadingProgressWidget(
              key: const ValueKey('stickyProgressVisible'),
              book: _lastReadBook!,
              progress: 0.65,
              onClose: _hideStickyProgress,
            )
                : const SizedBox.shrink(key: ValueKey('stickyProgressHidden')),
          ),
        ),
      ],
    );
  }
}

class _HorizontalBookList extends StatelessWidget {
  final List<Book> books;
  const _HorizontalBookList({super.key, required this.books});

  @override
  Widget build(BuildContext context) {
    double cardDisplayHeight = responsiveFontSize(context, 310);
    return SizedBox(
      height: cardDisplayHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: books.length,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
                right: index == books.length - 1 ? 0 : 16.0),
            child: _BookCard(book: books[index]),
          );
        },
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  final Book book;
  static const double cardImageClipRadius = 12.0;
  static const double destinationDetailScreenImageClipRadius = 10.0; // Sesuai dengan BookDetailScreenState.detailImageClipRadius

  const _BookCard({super.key, required this.book});

  Widget _buildImageError(BuildContext context, double height, double width) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(cardImageClipRadius),
      ),
      child: Center(
          child: Icon(Remix.image_line,
              size: responsiveFontSize(context, 50),
              color: Colors.grey.shade600)),
    );
  }

  @override
  Widget build(BuildContext context) {
    double cardWidth = responsiveFontSize(context, 160);
    double imageHeight = responsiveFontSize(context, 240);
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    bool isNetworkImage = book.imageUrl.startsWith('http');
    Color titleColor = Theme.of(context).colorScheme.onSurface;
    Color authorColor = Theme.of(context).colorScheme.onSurfaceVariant;
    Color ratingTextColor = Theme.of(context).colorScheme.onSurface;

    return Hero(
      tag: 'bookCover_${book.id}',
      createRectTween: (Rect? begin, Rect? end) { // Optimasi createRectTween
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
        BorderRadius fromRadius = BorderRadius.circular(cardImageClipRadius);
        BorderRadius toRadius = BorderRadius.circular(destinationDetailScreenImageClipRadius);

        BorderRadius animatedRadius;
        if (flightDirection == HeroFlightDirection.push) {
          animatedRadius = BorderRadius.lerp(fromRadius, toRadius, animation.value)!;
        } else {
          animatedRadius = BorderRadius.lerp(toRadius, fromRadius, animation.value)!;
        }

        return ClipRRect( // Shuttle menampilkan gambar asli
          borderRadius: animatedRadius,
          child: CachedNetworkImage(
            imageUrl: currentBook.imageUrl,
            fit: BoxFit.cover,
            // Placeholder sederhana untuk shuttle karena umurnya singkat
            placeholder: (context, url) => Container(color: Colors.grey[300]),
            errorWidget: (context, url, error) => Container(color: Colors.grey[300]),
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => BookDetailScreen(book: book)),
          );
        },
        child: SizedBox(
          width: cardWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(cardImageClipRadius),
                child: SizedBox(
                  height: imageHeight,
                  width: cardWidth,
                  child: isNetworkImage
                      ? CachedNetworkImage(
                    imageUrl: book.imageUrl,
                    fit: BoxFit.cover,
                    memCacheHeight: (imageHeight * devicePixelRatio).round(),
                    memCacheWidth: (cardWidth * devicePixelRatio).round(),
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(color: Colors.white),
                    ),
                    errorWidget: (context, url, error) =>
                        _buildImageError(context, imageHeight, cardWidth),
                  )
                      : Image.asset(
                    book.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildImageError(context, imageHeight, cardWidth),
                  ),
                ),
              ),
              SizedBox(height: responsiveFontSize(context, 10)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: responsiveFontSize(context, 2)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            book.title,
                            style: GoogleFonts.montserrat(
                              fontSize: responsiveFontSize(context, 13),
                              fontWeight: FontWeight.w600,
                              color: titleColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: responsiveFontSize(context, 3)),
                          if (book.author.isNotEmpty)
                            Text(
                              book.author,
                              style: GoogleFonts.montserrat(
                                fontSize: responsiveFontSize(context, 11),
                                color: authorColor,
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    SizedBox(width: responsiveFontSize(context, 6)),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Remix.star_s_fill,
                          color: Colors.amber,
                          size: responsiveFontSize(context, 16),
                        ),
                        SizedBox(width: responsiveFontSize(context, 4)),
                        Text(
                          book.rating.toString(),
                          style: GoogleFonts.montserrat(
                            fontSize: responsiveFontSize(context, 12),
                            fontWeight: FontWeight.bold,
                            color: ratingTextColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Skeleton Widgets ---
class _BookCardSkeleton extends StatelessWidget {
  final double cardWidth;
  final double imageHeight;
  final double cardBorderRadius;

  const _BookCardSkeleton({
    super.key,
    required this.cardWidth,
    required this.imageHeight,
    required this.cardBorderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SizedBox(
        width: cardWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: imageHeight,
              width: cardWidth,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(cardBorderRadius),
              ),
            ),
            SizedBox(height: responsiveFontSize(context, 10)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: responsiveFontSize(context, 2)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: responsiveFontSize(context, 12),
                          width: cardWidth * 0.8,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                        ),
                        SizedBox(height: responsiveFontSize(context, 5)),
                        Container(
                          height: responsiveFontSize(context, 12),
                          width: cardWidth * 0.6,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                        ),
                        SizedBox(height: responsiveFontSize(context, 6)),
                        Container(
                          height: responsiveFontSize(context, 10),
                          width: cardWidth * 0.4,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: responsiveFontSize(context, 6)),
                  Container(
                    height: responsiveFontSize(context, 14),
                    width: cardWidth * 0.25,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HorizontalBookListSkeleton extends StatelessWidget {
  final double cardDisplayHeight;
  final double cardWidth;
  final double imageHeight;
  final double cardBorderRadius;

  const _HorizontalBookListSkeleton({
    super.key,
    required this.cardDisplayHeight,
    required this.cardWidth,
    required this.imageHeight,
    required this.cardBorderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: cardDisplayHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
                right: index == 2 ? 0 : 16.0),
            child: _BookCardSkeleton(
              cardWidth: cardWidth,
              imageHeight: imageHeight,
              cardBorderRadius: cardBorderRadius,
            ),
          );
        },
      ),
    );
  }
}

// CATATAN PENTING untuk BookDetailScreen.dart dan HomeScreenContent.dart:
// Pastikan definisi class ChapterInfo konsisten dan diimpor dari satu sumber
// untuk menghindari error type mismatch.