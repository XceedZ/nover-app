// lib/src/models/author.dart (File Baru, sesuaikan dengan data user Anda)

class Author {
  final int userId;
  final String fullName;
  final String? avatarUrl;
  // Tambahkan properti lain yang relevan

  Author({
    required this.userId,
    required this.fullName,
    this.avatarUrl,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      userId: json['userId'] as int,
      fullName: json['fullName'] ?? 'Unknown Author',
      avatarUrl: json['avatarUrl'] as String?,
    );
  }
}