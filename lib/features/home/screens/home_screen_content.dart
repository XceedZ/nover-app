// lib/features/home/screens/home_screen_content.dart
import 'package:flutter/material.dart';
import 'package:nover/features/books/screens/book_detail_screen.dart';
import 'package:nover/src/models/book.dart';
import 'package:nover/src/repositories/book_repository.dart';
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

// --- Widget Utama Konten Beranda (Stateful) ---
class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({super.key});

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  final BookRepository _bookRepository = BookRepository();
  late Future<List<Book>> _forYouFuture;

  Book? _lastReadBook;
  bool _isStickyProgressVisible = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _forYouFuture = _bookRepository.getBooks(page: 1, limit: 10);

    _lastReadBook = Book(
      bookId: 100,
      title: 'The Crimson Crown',
      status: 'P',
      author: 'Heather Walter',
      coverImageUrl: 'https://m.media-amazon.com/images/I/81cd9wVmIrL._SL1500_.jpg',
      ratingAverage: 4.6,
      genres: "Mystery, Thriller",
      description: '',
      createDatetime: DateTime.now().toIso8601String(),
      updateDatetime: DateTime.now().toIso8601String(),
      totalViews: 1520,
    );
    setStateIfMounted(() {});
  }

  Future<void> _handleRefresh() async {
    setStateIfMounted(() {
      _loadData();
    });
  }

  void setStateIfMounted(VoidCallback f) {
    if (mounted) setState(f);
  }

  void _hideStickyProgress() {
    setStateIfMounted(() => _isStickyProgressVisible = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onBackgroundColor = theme.colorScheme.onBackground;

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _handleRefresh,
          color: theme.colorScheme.primary,
          backgroundColor: theme.cardColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: 24.0, bottom: 100.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Whispers of Fiction.',
                    style: AppFonts.headerStyle?.copyWith(
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
                    style: AppFonts.titleMedium(color: onBackgroundColor)?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                FutureBuilder<List<Book>>(
                  future: _forYouFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const _HorizontalBookListSkeleton();
                    }
                    if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                      return SizedBox(height: responsiveFontSize(context, 300), child: const Center(child: Text('Gagal memuat data.')));
                    }
                    return _HorizontalBookList(books: snapshot.data!);
                  },
                ),
              ],
            ),
          ),
        ),
        if (_lastReadBook != null)
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0.0, 1.0), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOutQuart)),
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: _isStickyProgressVisible
                  ? StickyReadingProgressWidget(key: const ValueKey('stickyProgressVisible'), book: _lastReadBook!, progress: 0.65, onClose: _hideStickyProgress)
                  : const SizedBox.shrink(key: ValueKey('stickyProgressHidden')),
            ),
          ),
      ],
    );
  }
}

class _HorizontalBookList extends StatelessWidget {
  final List<Book> books;
  const _HorizontalBookList({required this.books});

  @override
  Widget build(BuildContext context) {
    final double imageHeight = responsiveFontSize(context, 210);
    final double textBlockHeight = responsiveFontSize(context, 70);
    final double totalCardHeight = imageHeight + textBlockHeight;

    return SizedBox(
      height: totalCardHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: books.length,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(right: index == books.length - 1 ? 0 : 16.0),
            child: _BookCard(
              book: books[index],
              imageHeight: imageHeight,
              textBlockHeight: textBlockHeight,
            ),
          );
        },
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  final Book book;
  final double imageHeight;
  final double textBlockHeight;
  static const double cardImageClipRadius = 12.0;

  const _BookCard({
    required this.book,
    required this.imageHeight,
    required this.textBlockHeight,
  });

  Widget _buildImageError(BuildContext context, double height, double width) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(cardImageClipRadius)),
      child: Center(child: Icon(Remix.image_line, size: responsiveFontSize(context, 50), color: Colors.grey.shade600)),
    );
  }

  @override
  Widget build(BuildContext context) {
    double cardWidth = responsiveFontSize(context, 150);
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    Color titleColor = Theme.of(context).colorScheme.onSurface;
    Color authorColor = Theme.of(context).colorScheme.onSurfaceVariant;
    Color ratingTextColor = Theme.of(context).colorScheme.onSurface;

    return Hero(
      tag: 'bookCover_${book.bookId}',
      child: GestureDetector(
        onTap: () {
          // --- PERBAIKAN UTAMA ADA DI SINI ---
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => BookDetailScreen(
                  // Mengirim parameter sesuai konstruktor baru
                  bookId: book.bookId,
                  initialBookData: book,
                )
            ),
          );
        },
        child: SizedBox(
          width: cardWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(cardImageClipRadius),
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
                      child: Container(color: Colors.white),
                    ),
                    errorWidget: (context, url, error) => _buildImageError(context, imageHeight, cardWidth),
                  ),
                ),
              ),
              SizedBox(
                height: textBlockHeight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, left: 2, right: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              book.title,
                              style: AppFonts.titleSmall(color: titleColor)?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (book.author != null && book.author!.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(
                                book.author!,
                                style: AppFonts.bodySmall(color: authorColor),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Remix.star_s_fill, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            book.ratingAverage.toStringAsFixed(1),
                            style: AppFonts.bodyMedium(color: ratingTextColor)?.copyWith(
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HorizontalBookListSkeleton extends StatelessWidget {
  const _HorizontalBookListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double imageHeight = responsiveFontSize(context, 210);
    final double textBlockHeight = responsiveFontSize(context, 70);
    final double totalCardHeight = imageHeight + textBlockHeight;
    double cardWidth = responsiveFontSize(context, 150);

    return Shimmer.fromColors(
      baseColor: theme.colorScheme.surfaceContainer,
      highlightColor: theme.colorScheme.surfaceContainerHighest,
      child: SizedBox(
        height: totalCardHeight,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 3,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.only(right: index == 2 ? 0 : 16.0),
              child: SizedBox(
                width: cardWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: imageHeight, width: cardWidth, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
                    const SizedBox(height: 10),
                    Container(height: 14, width: cardWidth * 0.8, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                    const SizedBox(height: 5),
                    Container(height: 12, width: cardWidth * 0.5, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}