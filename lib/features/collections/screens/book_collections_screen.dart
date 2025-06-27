// lib/features/collections/screens/book_collections_screen.dart
import 'package:flutter/material.dart';
import 'package:nover/features/collections/models/book_collection_model.dart';
import 'package:nover/features/collections/widgets/collection_card_widget.dart';
import 'package:nover/src/utils/app_fonts.dart';
import 'package:remixicon/remixicon.dart';
import 'package:palette_generator/palette_generator.dart';
import 'dart:async';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter_translate/flutter_translate.dart';

// Fungsi Helper untuk Font Adaptif (tetap sama)
double responsiveFontSize(BuildContext context, double baseFontSize) {
  const double referenceWidth = 375.0;
  double screenWidth = MediaQuery.of(context).size.width;
  double scaleFactor = screenWidth / referenceWidth;
  return baseFontSize * scaleFactor.clamp(0.85, 1.25);
}

class BookCollectionsScreen extends StatefulWidget {
  const BookCollectionsScreen({super.key});

  @override
  State<BookCollectionsScreen> createState() => _BookCollectionsScreenState();
}

class _BookCollectionsScreenState extends State<BookCollectionsScreen>
    with TickerProviderStateMixin {
  List<BookCollection> _collections = [];
  bool _isLoadingCollections = true;
  TabController? _tabController;

  final List<Map<String, dynamic>> _rawCollectionData = [
    {
      'id': '1',
      'mainBookCoverUrl': 'https://d28hgpri8am2if.cloudfront.net/book_images/onix/cvr9781501171345/the-last-thing-he-told-me-9781501171345_xlg.jpg',
      'genres': ['Mystery', 'Thriller', 'Suspense'],
      'title': 'The Last Thing He Told Me',
      'mainAuthorName': 'Laura Dave',
      'totalChapters': 21,
    },
    {
      'id': '2',
      'mainBookCoverUrl': 'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1490854793i/34733043.jpg',
      'genres': ['Thriller', 'Horror'],
      'title': 'The Past Is Rising',
      'mainAuthorName': 'Kathryn Bywaters',
      'totalChapters': 8,
    },
    {
      'id': '3',
      'mainBookCoverUrl': 'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1686586552i/174721610.jpg',
      'genres': ['Classic', 'Adventure'],
      'title': 'Timeless Adventures',
      'mainAuthorName': 'Brian J Robb',
      'totalChapters': 35,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCollectionsWithDynamicFallbackColors();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<Color?> _generateFallbackColorFromCover(String imageUrl) async {
    try {
      final PaletteGenerator paletteGenerator =
      await PaletteGenerator.fromImageProvider(
        NetworkImage(imageUrl),
        size: const Size(100, 150),
      );
      return paletteGenerator.mutedColor?.color ??
          paletteGenerator.dominantColor?.color ??
          paletteGenerator.vibrantColor?.color;
    } catch (e) {
      print("Error generating fallback color for $imageUrl: $e");
      return null;
    }
  }

  Future<void> _loadCollectionsWithDynamicFallbackColors() async {
    List<BookCollection> processedCollections = [];
    for (var data in _rawCollectionData) {
      Color? dynamicFallbackColor = await _generateFallbackColorFromCover(data['mainBookCoverUrl'] as String);
      processedCollections.add(
        BookCollection(
          id: data['id'] as String,
          mainBookCoverUrl: data['mainBookCoverUrl'] as String,
          genres: List<String>.from(data['genres'] as List<dynamic>),
          title: data['title'] as String,
          mainAuthorName: data['mainAuthorName'] as String,
          totalChapters: data['totalChapters'] as int,
          fallbackCardColor: dynamicFallbackColor,
        ),
      );
    }
    if (mounted) {
      setState(() {
        _collections = processedCollections;
        _isLoadingCollections = false;
      });
    }
  }

  Widget _buildBookshelfTab() {
    return _isLoadingCollections
        ? Center(
      child: LoadingAnimationWidget.staggeredDotsWave(
        color: Theme.of(context).colorScheme.primary,
        size: responsiveFontSize(context, 50),
      ),
    )
        : _collections.isEmpty
        ? Center(child: Text(translate('collections.emptyState')))
        : ListView.builder(
      padding: const EdgeInsets.only(top: 8.0), // Padding untuk jarak dari track ke item pertama
      itemCount: _collections.length,
      itemBuilder: (context, index) {
        return CollectionCardWidget(collection: _collections[index]);
      },
    );
  }

  Widget _buildHistoryTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Remix.history_line,
            size: responsiveFontSize(context, 60),
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
          ),
          SizedBox(height: responsiveFontSize(context, 16)),
          Text(
            translate('collections.historyEmptyState'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: responsiveFontSize(context, 16),
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowedTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Remix.user_follow_line,
            size: responsiveFontSize(context, 60),
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
          ),
          SizedBox(height: responsiveFontSize(context, 16)),
          Text(
            translate('collections.followedEmptyState'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: responsiveFontSize(context, 16),
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      translate('menu.collection'),
                      style: AppFonts.headerStyle.copyWith(
                        fontSize: responsiveFontSize(context, 28),
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onBackground,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Remix.add_line,
                        size: responsiveFontSize(context, 30),
                        color: theme.colorScheme.primary,
                      ),
                      onPressed: () {
                        print('Add new collection tapped');
                      },
                      splashRadius: responsiveFontSize(context, 24),
                    ),
                  ],
                ),
              ),

              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: theme.colorScheme.secondary,
                      width: 1.0,
                    ),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: theme.colorScheme.primary,
                  unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.3),
                  indicatorColor: theme.colorScheme.primary,
                  indicatorWeight: 3.5,
                  indicatorSize: TabBarIndicatorSize.label,
                  dividerColor: Colors.transparent,
                  dividerHeight: 0.0,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 10.0),
                  labelStyle: AppFonts.titleSmall().copyWith(
                    fontSize: responsiveFontSize(context, 14.5),
                    fontWeight: FontWeight.bold,
                  ),
                  unselectedLabelStyle: AppFonts.titleSmall().copyWith(
                    fontSize: responsiveFontSize(context, 14.5),
                    fontWeight: FontWeight.bold,
                  ),
                  tabs: [
                    Tab(text: translate('label.bookshelf')),
                    Tab(text: translate('label.history')),
                    Tab(text: translate('label.followed')),
                  ],
                ),
              ),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBookshelfTab(),
                    _buildHistoryTab(),
                    _buildFollowedTab(),
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