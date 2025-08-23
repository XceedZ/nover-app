// lib/src/models/notification_item.dart
import 'package:nover/src/utils/date_convert.dart';

// Model untuk informasi paginasi
class PaginationInfo {
  final int currentPage;
  final int pageSize;
  final int totalItems;
  final int totalPages;

  PaginationInfo({
    required this.currentPage,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      currentPage: json['currentPage'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
      totalItems: json['totalItems'] is int ? json['totalItems'] : int.tryParse(json['totalItems'].toString()) ?? 0,
      totalPages: json['totalPages'] is int ? json['totalPages'] : int.tryParse(json['totalPages'].toString()) ?? 0,
    );
  }
}

// Model untuk satu item notifikasi
class NotificationItem {
  final int notificationId;
  final String notificationType;
  final bool isRead;
  final String createDatetime;
  final String? userName;
  final String? userAvatarUrl;
  final String? bookName;
  final String? chapterName;
  final String? commentContent;
  final int? bookId;
  final int? relatedEntityId;

  NotificationItem({
    required this.notificationId,
    required this.notificationType,
    required this.isRead,
    required this.createDatetime,
    this.userName,
    this.userAvatarUrl,
    this.bookName,
    this.chapterName,
    this.commentContent,
    this.bookId,
    this.relatedEntityId,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      notificationId: json['notificationId'] as int,
      notificationType: json['notificationType'] ?? '',
      isRead: json['isRead'] ?? false,
      createDatetime: json['createDatetime'] ?? '',
      userName: json['userName'] as String?,
      userAvatarUrl: json['userAvatarUrl'] as String?,
      bookName: json['bookName'] as String?,
      chapterName: json['chapterName'] as String?,
      commentContent: json['commentContent'] as String?,
      bookId: json['bookId'] as int?,
      relatedEntityId: json['relatedEntityId'] as int?,
    );
  }
}

// Model untuk seluruh response API yang dipaginasi
class PaginatedNotificationResponse {
  final PaginationInfo pagination;
  final List<NotificationItem> notifications;

  PaginatedNotificationResponse({
    required this.pagination,
    required this.notifications,
  });

  factory PaginatedNotificationResponse.fromJson(Map<String, dynamic> json) {
    var notificationList = <NotificationItem>[];
    if (json['notifications'] != null) {
      json['notifications'].forEach((v) {
        notificationList.add(NotificationItem.fromJson(v));
      });
    }
    return PaginatedNotificationResponse(
      pagination: PaginationInfo.fromJson(json['pagination']),
      notifications: notificationList,
    );
  }
}