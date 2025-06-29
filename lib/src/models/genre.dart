// lib/src/models/genre.dart

class Genre {
  final int genreId;
  final String genreName;
  final String genreTl;

  Genre({
    required this.genreId,
    required this.genreName,
    required this.genreTl,
  });

  // Diperlukan agar perbandingan objek di dalam Set berfungsi dengan benar.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Genre &&
              runtimeType == other.runtimeType &&
              genreId == other.genreId;

  @override
  int get hashCode => genreId.hashCode;

  /// Factory constructor untuk membuat instance Genre dari JSON.
  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      genreId: json['genreId'] as int,
      genreName: json['genreName'] as String,
      genreTl: json['genreTl'] as String,
    );
  }
}
