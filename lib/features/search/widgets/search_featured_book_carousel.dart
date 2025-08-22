// lib/features/search/widgets/search_featured_book_carousel.dart
import 'package:flutter/material.dart';
import 'package:nover/src/utils/app_fonts.dart';
import 'package:nover/src/utils/ui_helpers.dart';
import 'package:nover/src/models/book.dart'; // UBAH: Import model dari sumber yang benar
import 'package:nover/src/widgets/book_stats_row_widget.dart';
import 'package:remixicon/remixicon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

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
    if (widget.books.isNotEmpty) {
      initialPage = (widget.books.length ~/ 2).clamp(0, widget.books.length - 1);
    }
    _currentPage = initialPage;
    _pageOffset = _currentPage.toDouble();

    _pageController = PageController(
      initialPage: _currentPage,
      viewportFraction: 0.6,
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
    // UBAH: Menggunakan bookId
    bool booksHaveChanged = widget.books.length != oldWidget.books.length ||
        widget.books.map((b) => b.bookId).join(',') != oldWidget.books.map((b) => b.bookId).join(',');

    if (booksHaveChanged) {
      _pageController.dispose();
      _initializePageControllerAndOffset();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _pageController.hasClients && widget.books.isNotEmpty) {
          _pageController.jumpToPage(_currentPage);
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
      return Padding(
        padding: EdgeInsets.all(responsiveFontSize(context, 20)),
        child: Center(
          child: Text(
              "No books to display.",
              style: AppFonts.titleMedium(color: widget.onSectionColor.withOpacity(0.7))
          ),
        ),
      );
    }

    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    int displayPageIndex = _pageOffset.round().clamp(0, widget.books.length - 1);
    Book currentBook = widget.books[displayPageIndex];
    double pageViewHeight = _carouselCoverHeight + responsiveFontSize(context, 40);

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
                if (mounted) {
                  setState(() {
                    _currentPage = index;
                  });
                }
              },
              itemBuilder: (context, index) {
                final book = widget.books[index];
                double scale = (1 - ((_pageOffset - index).abs() * 0.22)).clamp(0.70, 1.0);
                double opacity = (1 - ((_pageOffset - index).abs() * 0.6)).clamp(0.3, 1.0);
                double verticalOffset = (_pageOffset - index).abs() * responsiveFontSize(context, 25);

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
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.0),
                                boxShadow: [
                                  if (scale > 0.95)
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.12),
                                      blurRadius: 12,
                                      spreadRadius: 1,
                                      offset: const Offset(0, 5),
                                    )
                                ]
                            ),
                            child: Hero(
                              tag: 'search_carousel_book_${book.bookId}_$index',
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
                    style: AppFonts.headerStyle.copyWith(
                      fontSize: responsiveFontSize(context, 18),
                      color: widget.onSectionColor,
                    ),
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
                      StatItem(value: currentBook.totalViews.toString(), label: "Views"),
                      const StatDivider(),
                      StatItem(value: currentBook.status.toUpperCase(), label: "Status"),
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
