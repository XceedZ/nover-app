import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:nover/features/author/screens/became_author_screen.dart';
import 'package:nover/features/author/screens/create_book_screen.dart';
import 'package:nover/features/posts/screens/detail_my_book_screen.dart';
import 'package:nover/main.dart';
import 'package:nover/src/models/book.dart';
import 'package:nover/src/repositories/author_repository.dart';
import 'package:nover/src/utils/app_fonts.dart';
import 'package:nover/src/utils/translation.dart';
import 'package:nover/src/utils/ui_helpers.dart';
import 'package:nover/src/widgets/custom_chips.dart';
import 'package:remixicon/remixicon.dart';
import 'package:animations/animations.dart';

class MyPostsScreen extends StatefulWidget {
  const MyPostsScreen({super.key});

  @override
  State<MyPostsScreen> createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends State<MyPostsScreen> {
  final AuthorRepository _authorRepository = AuthorRepository();
  late Future<List<Book>> _myPostsFuture;
  List<Book> _books = [];
  bool _isInitialLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMyBooks();
  }

  Future<void> _fetchMyBooks() async {
    setState(() => _isInitialLoading = true);
    final books = await _authorRepository.getMyBooks();
    if (mounted) {
      setState(() {
        _books = books;
        _isInitialLoading = false;
      });
    }
  }

  Future<void> _refreshMyBooks() async {
    final books = await _authorRepository.getMyBooks();
    if (mounted) {
      setState(() => _books = books);
    }
  }

  void _navigateToCreateBookAndRefresh() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const CreateBookScreen()),
    );
    if (result == true) {
      _fetchMyBooks();
    }
  }

  void _navigateToBecameAuthor() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BecameAuthorScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryTextColor = colorScheme.onSurface;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          shape: Border(
            bottom: BorderSide(
              color: theme.dividerColor.withOpacity(0.5),
              width: 1.0,
            ),
          ),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Remix.arrow_left_s_line, color: primaryTextColor),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            tl('myPosts'),
            style: AppFonts.appBarTitle(color: primaryTextColor),
          ),
          centerTitle: true,
          bottom: TabBar(
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(width: 3.5, color: colorScheme.primary),
            ),
            indicatorSize: TabBarIndicatorSize.label,
            dividerHeight: 0,
            labelColor: colorScheme.primary,
            unselectedLabelColor: primaryTextColor.withOpacity(0.7),
            labelStyle: AppFonts.titleMedium()?.copyWith(fontWeight: FontWeight.bold),
            unselectedLabelStyle: AppFonts.titleMedium(),
            tabs: [
              Tab(text: tl('books')),
              Tab(text: tl('comments')),
            ],
          ),
        ),
        body: ValueListenableBuilder<Map<String, dynamic>?>(
          valueListenable: authNotifier,
          builder: (context, currentUser, child) {
            final bool isAuthor = currentUser?['flgAuthor'] == 'Y';
            return TabBarView(
              children: [
                _buildBooksTab(isAuthor: isAuthor),
                _buildCommentsTab(),
              ],
            );
          },
        ),
        floatingActionButton: ValueListenableBuilder<Map<String, dynamic>?>(
          valueListenable: authNotifier,
          builder: (context, currentUser, child) {
            final bool isAuthor = currentUser?['flgAuthor'] == 'Y';
            if (!isAuthor) return const SizedBox.shrink();

            return OpenContainer(
              closedShape: const CircleBorder(),
              closedColor: colorScheme.primary,
              transitionDuration: const Duration(milliseconds: 350),
              openBuilder: (context, _) => const CreateBookScreen(),
              closedBuilder: (context, openContainer) => FloatingActionButton(
                onPressed: openContainer,
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                child: const Icon(Remix.add_line),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBooksTab({required bool isAuthor}) {
    final theme = Theme.of(context);

    if (!isAuthor) {
      return _buildEmptyState(
        lottieAsset: 'assets/images/AnimationWritingDark.json',
        title: tl('becomeAnAuthorTitle'),
        message: tl('becomeAnAuthorSubtitle'),
        actionText: tl('becomeAuthor').toUpperCase(),
        onActionPressed: _navigateToBecameAuthor,
      );
    }

    if (_isInitialLoading) {
      return Center(
        child: LoadingAnimationWidget.staggeredDotsWave(
          color: theme.colorScheme.primary,
          size: 50,
        ),
      );
    }

    if (_books.isEmpty) {
      return _buildEmptyState(
        lottieAsset: 'assets/images/AnimationWritingDark.json',
        title: tl('noBooksYetTitle'),
        message: tl('noBooksYetSubtitle'),
        actionText: tl('startCreating'),
        onActionPressed: _navigateToCreateBookAndRefresh,
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshMyBooks,
      color: theme.colorScheme.primary,
      child: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: _books.length,
        itemBuilder: (context, index) {
          return MyPostBookCard(book: _books[index]);
        },
        separatorBuilder: (context, index) => const SizedBox(height: 12),
      ),
    );
  }

  Widget _buildCommentsTab() {
    return _buildEmptyState(
      lottieAsset: 'assets/images/AnimationCommentDark.json',
      title: tl('noCommentsYetTitle'),
      message: tl('noCommentsYetSubtitle'),
    );
  }

  Widget _buildEmptyState({
    required String lottieAsset,
    required String title,
    required String message,
    String? actionText,
    VoidCallback? onActionPressed,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              lottieAsset,
              width: MediaQuery.of(context).size.width * 1,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 32),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppFonts.titleLarge(color: colorScheme.onSurface)?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppFonts.titleMedium(color: colorScheme.onSurface.withOpacity(0.7))?.copyWith(height: 1.5),
            ),
            if (actionText != null && onActionPressed != null) ...[
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: onActionPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(actionText, style: AppFonts.titleMedium()?.copyWith(fontWeight: FontWeight.bold)),
              )
            ]
          ],
        ),
      ),
    );
  }
}

class MyPostBookCard extends StatelessWidget {
  final Book book;
  const MyPostBookCard({required this.book, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailMyBookScreen(bookId: book.bookId),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Hero(
                tag: 'book-cover-${book.bookId}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: CachedNetworkImage(
                    imageUrl: book.coverImageUrl,
                    height: 130,
                    width: 90,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: theme.colorScheme.surfaceVariant),
                    errorWidget: (context, url, error) => Container(
                      color: theme.colorScheme.surfaceVariant,
                      child: const Icon(Icons.image_not_supported),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: AppFonts.titleMedium(color: theme.colorScheme.onSurface)?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    ChipStatus(status: book.status),
                    const SizedBox(height: 6),
                    GenreChips(genreString: book.genres),
                    const SizedBox(height: 8),
                    Text(
                      book.description,
                      style: AppFonts.titleSmall(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
