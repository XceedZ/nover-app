import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:nover/src/models/chapter.dart';
import 'package:nover/src/repositories/book_repository.dart';
import 'package:nover/src/utils/translation.dart';
import 'package:nover/features/books/screens/read_book_screen.dart';

/// Sebuah screen "wrapper" yang bertugas untuk memuat data detail
/// sebuah chapter sebelum menampilkannya di ReadNovelScreen.
class ReadChapterScreen extends StatefulWidget {
  final int chapterId;
  final String initialTitle; // Judul awal untuk ditampilkan saat loading

  const ReadChapterScreen({
    super.key,
    required this.chapterId,
    required this.initialTitle,
  });

  @override
  State<ReadChapterScreen> createState() => _ReadChapterScreenState();
}

class _ReadChapterScreenState extends State<ReadChapterScreen> {
  final BookRepository _bookRepository = BookRepository();
  late Future<Chapter> _chapterDetailFuture;

  @override
  void initState() {
    super.initState();
    _chapterDetailFuture = _bookRepository.getChapterDetail(widget.chapterId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Chapter>(
      future: _chapterDetailFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScreen(context);
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return _buildErrorScreen(context, snapshot.error.toString());
        }

        final chapter = snapshot.data!;

        // Setelah data didapat, panggil ReadNovelScreen yang "bodoh"
        return ReadNovelScreen(
          chapterIntroLabelText: '${tl('chapter')} ${chapter.chapterOrder}',
          chapterTitleText: chapter.title,
          chapterBodyText: chapter.content ?? tl('error.contentNotAvailable'),
        );
      },
    );
  }

  Widget _buildLoadingScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialTitle, style: const TextStyle(fontSize: 16)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Center(
        child: LoadingAnimationWidget.staggeredDotsWave(
          color: Theme.of(context).colorScheme.primary,
          size: 50,
        ),
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context, String error) {
    return Scaffold(
      appBar: AppBar(title: Text(tl('error'))),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(error, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}