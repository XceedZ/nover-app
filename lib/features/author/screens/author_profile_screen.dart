// lib/features/author/screens/author_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nover/features/home/screens/home_screen_content.dart' show Book;
import 'package:nover/src/utils/ui_helpers.dart';
import 'package:nover/features/books/widgets/custom_detail_top_bar.dart';
import 'package:remixicon/remixicon.dart';

// Dummy data buku (sama seperti sebelumnya)
final List<Book> dummyAuthorBooks = [
  Book(id: 301, title: "Center Terhebat NBA", author: "Pulpen CEO", imageUrl: "https://i.postimg.cc/G287x9P9/nba-center.jpg", chapter: "Bersambung | Bab 18", genres: ["Aksi", "Olahraga"], description: "Setelah transmigrasi, Orlando menjadi center cadangan tim SUN tahun 2010. Aw...", rating: 4.9, pages: 200, language: "ID"),
  Book(id: 302, title: "Karya Lain Penulis Hebat", author: "Pulpen CEO", imageUrl: "https://i.postimg.cc/d1M6vXzP/fantasy-book.jpg", chapter: "Tamat", genres: ["Fantasi"], description: "Deskripsi singkat untuk karya lain dari penulis ini.", rating: 4.5, pages: 150, language: "ID"),
  Book(id: 303, title: "Petualangan Pulpen Ajaib", author: "Pulpen CEO", imageUrl: "https://i.postimg.cc/s2hWzYx8/adventure-pen.jpg", chapter: "Ongoing | Bab 50", genres: ["Adventure", "Comedy"], description: "Sebuah kisah epik tentang petualangan sebuah pulpen yang bisa berbicara.", rating: 4.7, pages: 300, language: "ID"),
  Book(id: 304, title: "Misteri Kedai Kopi Senja", author: "Author Lain", imageUrl: "https://i.postimg.cc/Bv0SM8rV/coffee-mystery.jpg", chapter: "10 Chapter", genres: ["Mystery", "Slice of Life"], description: "Rahasia kelam di balik secangkir kopi di sebuah kedai tua.", rating: 4.6, pages: 180, language: "ID"),
  Book(id: 305, title: "Robot & Bunga Matahari", author: "Pulpen CEO", imageUrl: "https://i.postimg.cc/Y08KXQ0T/robot-sunflower.jpg", chapter: "Complete", genres: ["Sci-Fi", "Drama"], description: "Kisah persahabatan tak terduga antara robot dan bunga.", rating: 4.8, pages: 220, language: "ID"),
];

class AuthorProfileScreen extends StatefulWidget {
  final String authorName;
  final String authorImageUrl;

  const AuthorProfileScreen({
    super.key,
    required this.authorName,
    required this.authorImageUrl,
  });

  @override
  State<AuthorProfileScreen> createState() => _AuthorProfileScreenState();
}

class _AuthorProfileScreenState extends State<AuthorProfileScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showAuthorNameInAppBar = false;
  final GlobalKey _mainAuthorNameKey = GlobalKey();

  double _scrollThreshold = 150.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final authorNameBox = _mainAuthorNameKey.currentContext?.findRenderObject() as RenderBox?;
        final double appBarTotalHeight = kToolbarHeight + MediaQuery.of(context).padding.top;
        if (authorNameBox != null) {
          final position = authorNameBox.localToGlobal(Offset.zero);
          _scrollThreshold = position.dy + authorNameBox.size.height - appBarTotalHeight;
          if (_scrollThreshold < 0) _scrollThreshold = 150.0;
        }
        _scrollListener();
      }
    });
  }

  void _scrollListener() {
    if (!mounted) return;

    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double appBarContentHeight = kToolbarHeight;
    final double effectiveAppBarVisibleContentBottom = statusBarHeight + appBarContentHeight;
    bool shouldShowNameInBar = false;

    if (_mainAuthorNameKey.currentContext != null) {
      final RenderBox? authorNameRenderBox = _mainAuthorNameKey.currentContext!.findRenderObject() as RenderBox?;
      if (authorNameRenderBox != null && authorNameRenderBox.hasSize) {
        final titleBottomOffsetToGlobal = authorNameRenderBox.localToGlobal(Offset(0, authorNameRenderBox.size.height)).dy;
        if (titleBottomOffsetToGlobal < effectiveAppBarVisibleContentBottom) {
          shouldShowNameInBar = true;
        }
      }
    } else if (_scrollController.hasClients && _scrollController.offset > _scrollThreshold * 0.5) {
      shouldShowNameInBar = true;
    }

    if (shouldShowNameInBar != _showAuthorNameInAppBar) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _showAuthorNameInAppBar = shouldShowNameInBar;
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

  Widget _buildVerticalDivider(BuildContext context) {
    return SizedBox(
      height: responsiveFontSize(context, 28),
      child: VerticalDivider(
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.6),
        thickness: 1,
        width: responsiveFontSize(context, 20),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, Color backgroundColor, Color iconColor, BuildContext context) {
    return Container(
      padding: EdgeInsets.all(responsiveFontSize(context,10)),
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: iconColor, size: responsiveFontSize(context,20)),
    );
  }

  Widget _buildStatColumn(String value, String label, BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: responsiveFontSize(context, 18),
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onBackground,
          ),
        ),
        SizedBox(height: responsiveFontSize(context, 4)),
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: responsiveFontSize(context, 12),
            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    final Color _topBarBackgroundColor = Theme.of(context).colorScheme.background;
    final Color _topBarIconColor = Theme.of(context).colorScheme.onBackground;

    final double statusBarPadding = MediaQuery.of(context).padding.top;
    final double appBarContentHeight = kToolbarHeight;
    // Tinggi total yang akan digunakan oleh CustomDetailTopBar, termasuk area status bar
    final double topBarTotalHeight = appBarContentHeight + statusBarPadding;

    List<Book> displayedBooks;
    final List<Book> booksByThisAuthor = dummyAuthorBooks.where((book) => book.author.trim().toLowerCase() == widget.authorName.trim().toLowerCase()).toList();

    if (booksByThisAuthor.isNotEmpty) {
      displayedBooks = booksByThisAuthor;
    } else {
      displayedBooks = dummyAuthorBooks.where((book) => book.author == "Pulpen CEO").toList();
      if (displayedBooks.isEmpty && dummyAuthorBooks.isNotEmpty) {
        displayedBooks = dummyAuthorBooks.take(3).toList();
      }
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.only(
                // Konten utama dimulai di bawah keseluruhan top bar (termasuk status bar area)
                  top: topBarTotalHeight + responsiveFontSize(context, 10),
                  bottom: responsiveFontSize(context, 20)
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: responsiveFontSize(context, 50),
                      backgroundImage: CachedNetworkImageProvider(widget.authorImageUrl),
                      backgroundColor: theme.colorScheme.surfaceVariant,
                    ),
                    SizedBox(height: responsiveFontSize(context, 16)),
                    Text(
                      widget.authorName,
                      key: _mainAuthorNameKey,
                      style: GoogleFonts.montserrat(
                        fontSize: responsiveFontSize(context, 24),
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onBackground,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: responsiveFontSize(context, 4)),
                    Text(
                      "Author",
                      style: GoogleFonts.montserrat(
                        fontSize: responsiveFontSize(context, 14),
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: responsiveFontSize(context, 20)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialIcon(Remix.twitter_x_line, theme.colorScheme.primary.withOpacity(0.1), theme.colorScheme.primary, context),
                        SizedBox(width: responsiveFontSize(context, 12)),
                        _buildSocialIcon(Remix.facebook_fill, theme.colorScheme.primary.withOpacity(0.1), theme.colorScheme.primary, context),
                        SizedBox(width: responsiveFontSize(context, 12)),
                        _buildSocialIcon(Remix.instagram_line, theme.colorScheme.primary.withOpacity(0.1), theme.colorScheme.primary, context),
                        SizedBox(width: responsiveFontSize(context, 12)),
                        _buildSocialIcon(Remix.linkedin_fill, theme.colorScheme.primary.withOpacity(0.1), theme.colorScheme.primary, context),
                      ],
                    ),
                    SizedBox(height: responsiveFontSize(context, 24)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: responsiveFontSize(context, 16)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(child: _buildStatColumn(displayedBooks.length.toString(), "Works", context)),
                          _buildVerticalDivider(context),
                          Expanded(child: _buildStatColumn("110K", "Followers", context)),
                          _buildVerticalDivider(context),
                          Expanded(child: _buildStatColumn("4.8", "Rating", context)),
                        ],
                      ),
                    ),
                    SizedBox(height: responsiveFontSize(context, 24)),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          padding: EdgeInsets.symmetric(vertical: responsiveFontSize(context, 14)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(responsiveFontSize(context, 8)),
                          ),
                        ),
                        child: Text(
                          "Follow",
                          style: GoogleFonts.montserrat(
                            fontSize: responsiveFontSize(context, 16),
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: responsiveFontSize(context, 30)),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Pustaka",
                        style: GoogleFonts.montserrat(
                          fontSize: responsiveFontSize(context, 20),
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onBackground,
                        ),
                      ),
                    ),
                    SizedBox(height: responsiveFontSize(context, 16)),
                    if (displayedBooks.isNotEmpty)
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: displayedBooks.length,
                        itemBuilder: (context, index) {
                          return _AuthorBookCard(book: displayedBooks[index]);
                        },
                        separatorBuilder: (context, index) => SizedBox(height: responsiveFontSize(context, 12)),
                      )
                    else
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: responsiveFontSize(context, 20)),
                        child: Text(
                          "Penulis ini belum memiliki karya.",
                          style: GoogleFonts.montserrat(
                              fontSize: responsiveFontSize(context, 14),
                              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6)
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    SizedBox(height: responsiveFontSize(context, 30)),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomDetailTopBar(
              backgroundColor: _topBarBackgroundColor, // Selalu hitam
              iconColor: _topBarIconColor,         // Selalu putih atau kontras
              onBackPressed: () => Navigator.of(context).pop(),
              onSharePressed: () {
                print("Share button tapped for author: ${widget.authorName}");
              },
              topPadding: statusBarPadding,
              // --- PERUBAHAN UKURAN TOP BAR ---
              // CustomDetailTopBar menerima tinggi total termasuk area status bar.
              // Widget ini kemudian akan menggunakan topPadding untuk menempatkan kontennya dengan benar.
              height: topBarTotalHeight,
              // --- AKHIR PERUBAHAN UKURAN ---
              bookTitle: widget.authorName,
              bookAuthor: _showAuthorNameInAppBar ? "Author" : "",
              showTitleAuthor: _showAuthorNameInAppBar,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget _AuthorBookCard tetap sama seperti versi sebelumnya
class _AuthorBookCard extends StatelessWidget {
  final Book book;
  const _AuthorBookCard({required this.book});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    final Color customChipBackgroundColor = theme.brightness == Brightness.dark
        ? Colors.grey[800]!
        : const Color(0xFF424242);
    const Color customChipTextColor = Colors.white;

    return Container(
      decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(responsiveFontSize(context, 8)),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ]
      ),
      padding: EdgeInsets.all(responsiveFontSize(context, 12)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(responsiveFontSize(context, 4)),
            child: CachedNetworkImage(
              imageUrl: book.imageUrl,
              height: responsiveFontSize(context, 100),
              width: responsiveFontSize(context, 70),
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: responsiveFontSize(context, 100),
                width: responsiveFontSize(context, 70),
                color: theme.colorScheme.surfaceVariant,
              ),
              errorWidget: (context, url, error) => Container(
                height: responsiveFontSize(context, 100),
                width: responsiveFontSize(context, 70),
                color: theme.colorScheme.surfaceVariant,
                child: Icon(Icons.image_not_supported, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5)),
              ),
            ),
          ),
          SizedBox(width: responsiveFontSize(context, 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: GoogleFonts.montserrat(
                    fontSize: responsiveFontSize(context, 16),
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: responsiveFontSize(context, 4)),
                if (book.chapter != null && book.chapter!.isNotEmpty)
                  Text(
                    book.chapter!,
                    style: GoogleFonts.montserrat(
                      fontSize: responsiveFontSize(context, 12),
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                SizedBox(height: responsiveFontSize(context, 6)),
                if (book.genres != null && book.genres!.isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsiveFontSize(context, 7),
                      vertical: responsiveFontSize(context, 2.5),
                    ),
                    decoration: BoxDecoration(
                      color: customChipBackgroundColor,
                      borderRadius: BorderRadius.circular(responsiveFontSize(context, 5)),
                    ),
                    child: Text(
                      book.genres!.first,
                      style: GoogleFonts.montserrat(
                        fontSize: responsiveFontSize(context, 9.5),
                        color: customChipTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                SizedBox(height: responsiveFontSize(context, 8)),
                Text(
                  book.description,
                  style: GoogleFonts.montserrat(
                    fontSize: responsiveFontSize(context, 12),
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}