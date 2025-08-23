// lib/src/models/book_comment.dart

import 'package:nover/src/utils/date_convert.dart'; // Impor helper tanggal Anda

class BookComment {
  final int commentId;
  final int bookId;
  final int userId;
  final String commentText;
  final int? parentCommentId;
  final String createDatetime;
  final String authorPenName;
  final String? authorAvatar;
  final List<BookComment> replies; // Untuk menampung balasan di sisi client

  BookComment({
    required this.commentId,
    required this.bookId,
    required this.userId,
    required this.commentText,
    this.parentCommentId,
    required this.createDatetime,
    required this.authorPenName,
    this.authorAvatar,
    this.replies = const [],
  });

  factory BookComment.fromJson(Map<String, dynamic> json) {
    return BookComment(
      commentId: json['commentId'] as int,
      bookId: json['bookId'] as int,
      userId: json['userId'] as int,
      commentText: json['commentText'] ?? '',
      parentCommentId: json['parentCommentId'] as int?,
      createDatetime: json['createDatetime'] ?? '',
      authorPenName: json['authorPenName'] ?? 'Anonymous',
      authorAvatar: json['authorAvatar'] as String?,
      replies: [], // Diisi secara manual nanti
    );
  }
}