// lib/src/models/book_detail.dart (File Baru)
import 'package:nover/src/models/book.dart';
import 'package:nover/src/models/chapter.dart';
import 'package:nover/src/models/author.dart'; // Asumsi Anda punya model Author

class BookDetail {
  final Book bookInfo;
  final Author author;
  final List<Chapter> chapters;

  BookDetail({
    required this.bookInfo,
    required this.author,
    required this.chapters,
  });

  factory BookDetail.fromJson(Map<String, dynamic> json) {
    return BookDetail(
      bookInfo: Book.fromJson(json['bookInfo'] as Map<String, dynamic>),
      author: Author.fromJson(json['author'] as Map<String, dynamic>),
      chapters: (json['chapters'] as List<dynamic>)
          .map((chapterJson) => Chapter.fromJson(chapterJson as Map<String, dynamic>))
          .toList(),
    );
  }
}