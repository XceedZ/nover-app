// lib/models/book.dart
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
  // double currentProgress; // Anda bisa tambahkan ini jika progress disimpan per buku

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
    // this.currentProgress = 0.0,
    this.description =
    "This is a captivating novel that takes readers on an extraordinary journey...",
  });
}