// lib/src/models/book.dart

class Book {
  final int bookId;
  final String coverImageUrl;
  final String createDatetime;
  final String description;
  final String? genres;
  final double ratingAverage;
  final String status;
  final String title;
  final int totalViews;
  final String updateDatetime;
  final String? author;

  Book({
    required this.bookId,
    required this.coverImageUrl,
    required this.createDatetime,
    required this.description,
    this.genres,
    required this.ratingAverage,
    required this.status,
    required this.title,
    required this.totalViews,
    required this.updateDatetime,
    this.author,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      bookId: json['bookId'] as int,
      coverImageUrl: json['coverImageUrl'] ?? '',
      createDatetime: json['createDatetime'] ?? '',
      description: json['description'] ?? 'No description available.',
      genres: json['genres'] as String?,
      ratingAverage: (json['ratingAverage'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'Unknown',
      title: json['title'] ?? 'Untitled',
      totalViews: json['totalViews'] as int,
      updateDatetime: json['updateDatetime'] ?? '',
      author: json['author'],
    );
  }

  /// Metode copyWith untuk membuat salinan objek dengan nilai yang diperbarui.
  /// Ini akan menyelesaikan error 'copyWith' is not defined.
  Book copyWith({
    String? status,
    // Anda bisa tambahkan properti lain di sini jika ingin memperbaruinya di masa depan
  }) {
    return Book(
      bookId: bookId,
      coverImageUrl: coverImageUrl,
      createDatetime: createDatetime,
      description: description,
      genres: genres,
      ratingAverage: ratingAverage,
      status: status ?? this.status, // Gunakan status baru jika ada, jika tidak, gunakan yang lama
      title: title,
      totalViews: totalViews,
      updateDatetime: updateDatetime,
      author: author,
    );
  }
}
