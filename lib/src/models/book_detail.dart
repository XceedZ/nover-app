// lib/src/models/book_detail.dart

import 'package:nover/src/models/book.dart';
import 'package:nover/src/models/chapter.dart';

// Model untuk data Author dari response detail
class AuthorInfo {
  final int userId;
  final String? penName;
  final String? avatarUrl;
  final String? fullName;

  AuthorInfo({
    required this.userId,
    this.penName,
    this.avatarUrl,
    this.fullName,
  });

  factory AuthorInfo.fromJson(Map<String, dynamic> json) {
    return AuthorInfo(
      userId: json['userId'] ?? 0,
      penName: json['penName'],
      avatarUrl: json['avatarUrl'],
      fullName: json['fullName'],
    );
  }
}

// Model untuk data Review
class Review {
  final int reviewId;
  final String? authorPenName;
  final String? authorAvatar;
  final String reviewText;
  final double rating;
  final String createDatetime;

  Review({
    required this.reviewId,
    this.authorPenName,
    this.authorAvatar,
    required this.reviewText,
    required this.rating,
    required this.createDatetime,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      reviewId: json['reviewId'] ?? 0,
      authorPenName: json['authorPenName'],
      authorAvatar: json['authorAvatar'],
      reviewText: json['reviewText'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      createDatetime: json['createDatetime'] ?? '',
    );
  }
}

// Model utama yang membungkus semua data dari response API detail
class BookDetail {
  final Book bookInfo;
  final AuthorInfo author;
  final List<Chapter> chapters;
  final List<Review> reviews;

  BookDetail({
    required this.bookInfo,
    required this.author,
    required this.chapters,
    required this.reviews,
  });

  factory BookDetail.fromJson(Map<String, dynamic> json) {
    var chapterList = (json['chapters'] as List<dynamic>?)
        ?.map((c) => Chapter.fromJson(c as Map<String, dynamic>))
        .toList() ?? [];

    var reviewList = (json['reviews'] as List<dynamic>?)
        ?.map((r) => Review.fromJson(r as Map<String, dynamic>))
        .toList() ?? [];

    return BookDetail(
      bookInfo: Book.fromJson(json['bookInfo'] as Map<String, dynamic>),
      author: AuthorInfo.fromJson(json['author'] as Map<String, dynamic>),
      chapters: chapterList,
      reviews: reviewList,
    );
  }
}