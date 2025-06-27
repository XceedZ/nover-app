// lib/features/search/widgets/search_featured_book_carousel.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nover/src/utils/app_fonts.dart';
import 'package:nover/src/utils/ui_helpers.dart';
import 'package:nover/features/home/screens/home_screen_content.dart' show Book;
import 'package:nover/features/search/widgets/book_stats_row_widget.dart'; // Pastikan path ini benar
import 'package:remixicon/remixicon.dart';

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

  final double _carouselCoverBaseHeight = 250.0; // Ukuran cover diperbesar

  @override
  void initState() {
    super.initState();
    _initializePageControllerAndOffset();
    // Listener untuk _pageOffset sudah ada di _initializePageController
  }

  void _initializePageControllerAndOffset() {
    int initialPage = 0;
    if (widget.books.isNotEmpty) {
      initialPage = (widget.books.length ~/ 2).clamp(0, widget.books.length - 1);
    }
    _currentPage = initialPage;
    _pageOffset = _currentPage.toDouble(); // Inisialisasi _pageOffset agar animasi awal benar

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
    bool booksHaveChanged = widget.books.length != oldWidget.books.length ||
        widget.books.map((b) => b.id).join(',') != oldWidget.books.map((b) => b.id).join(',');

    if (booksHaveChanged) {
      _pageController.dispose();
      _initializePageControllerAndOffset(); // Panggil ini untuk reset semua

      // Penting untuk memastikan PageView melompat ke halaman yang benar setelah rebuild
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

  @override
  Widget build(BuildContext context) {
    // Hitung dimensi cover di dalam build agar selalu terupdate dengan context
    final double carouselCoverHeight = responsiveFontSize(context, _carouselCoverBaseHeight);
    final double carouselCoverWidth = carouselCoverHeight * (2.0 / 3.0);

    if (widget.books.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(responsiveFontSize(context, 20)),
        child: Center(
          child: Text(
              "No books to display.", // Pesan jika tidak ada buku
              style: AppFonts.titleMedium(color: widget.onSectionColor.withOpacity(0.7))
          ),
        ),
      );
    }

    // displayPageIndex sekarang selalu berdasarkan _pageOffset yang diupdate oleh listener
    int displayPageIndex = _pageOffset.round().clamp(0, widget.books.length - 1);
    Book currentBook = widget.books[displayPageIndex];

    double pageViewHeight = carouselCoverHeight + responsiveFontSize(context, 40); // Tinggi untuk PageView, beri ruang untuk vertical offset

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
                    _currentPage = index; // Update _currentPage saat user scroll dan halaman berhenti
                  });
                }
              },
              itemBuilder: (context, index) {
                final book = widget.books[index];
                double scale;
                double opacity;
                double verticalOffset;

                // Kalkulasi animasi selalu berdasarkan _pageOffset untuk smoothness
                double pageDistance = (_pageOffset - index).abs();

                scale = (1 - (pageDistance * 0.22)).clamp(0.70, 1.0);
                opacity = (1 - (pageDistance * 0.6)).clamp(0.3, 1.0); // Opacity item samping dari 0.3
                verticalOffset = pageDistance * responsiveFontSize(context, 25);

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
                            width: carouselCoverWidth,
                            height: carouselCoverHeight,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.0),
                                boxShadow: [
                                  if (scale > 0.95) // Shadow hanya untuk item yang hampir/tengah
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.12),
                                      blurRadius: 12,
                                      spreadRadius: 1,
                                      offset: const Offset(0, 5),
                                    )
                                ]
                            ),
                            child: Hero(
                              tag: 'search_carousel_book_${book.id}_$index', // Pastikan tag unik
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12.0),
                                child: Image.network(
                                  book.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                      child: Icon(Remix.image_line, size: responsiveFontSize(context, 50), color: Colors.grey[500]),
                                    );
                                  },
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
                  BookStatsRowWidget(
                    pages: currentBook.pages,
                    language: currentBook.language,
                    rating: currentBook.rating,
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