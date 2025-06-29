// lib/features/notifications/screens/notification_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nover/src/utils/app_fonts.dart';
import 'package:nover/src/utils/ui_helpers.dart';
import 'package:nover/src/utils/translation.dart';
import 'package:remixicon/remixicon.dart';

// Model data
class NotificationItemData {
  final String userName;
  final String userAvatarUrl;
  final String bookName;
  final String chapterName;
  final String commentContent;
  final String timestamp;
  final bool isMention;

  NotificationItemData({
    required this.userName,
    required this.userAvatarUrl,
    required this.bookName,
    required this.chapterName,
    required this.commentContent,
    required this.timestamp,
    this.isMention = false,
  });
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // Data dummy
  final List<NotificationItemData> _notifications = [
    NotificationItemData(
      userName: 'Lilly',
      userAvatarUrl: 'https://i.pravatar.cc/150?u=lilly',
      bookName: 'Website Redesign',
      chapterName: 'Chapter 5',
      commentContent: 'Updated the homepage layout to reflect the latest feedback. Done ✨',
      timestamp: '17 minutes ago',
    ),
    NotificationItemData(
      userName: 'Emma',
      userAvatarUrl: 'https://i.pravatar.cc/150?u=emma',
      bookName: 'The Last Kingdom',
      chapterName: 'Chapter 12',
      commentContent: '@You Could you review the new navigation structure and let me know what you think?',
      timestamp: '11 hours ago',
      isMention: true,
    ),
    NotificationItemData(
      userName: 'William',
      userAvatarUrl: 'https://i.pravatar.cc/150?u=william',
      bookName: 'Project Archangel',
      chapterName: 'Chapter 3',
      commentContent: 'The bug on the mobile view should be fixed now. Please verify.',
      timestamp: '7 hours ago',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final backgroundColor = theme.scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          tl('notification'),
          style: AppFonts.appBarTitle(color: colorScheme.onSurface),
        ),
        leading: IconButton(
          icon: Icon(Remix.arrow_left_s_line, color: colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: backgroundColor,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          return _buildNotificationItem(_notifications[index], theme);
        },
        separatorBuilder: (context, index) => Divider(
            indent: 20,
            endIndent: 20,
            height: 1,
            color: theme.dividerColor.withOpacity(0.5)
        ),
      ),
    );
  }

  // --- DIKEMBALIKAN menjadi InkWell sederhana ---
  Widget _buildNotificationItem(NotificationItemData item, ThemeData theme) {
    return InkWell(
      onTap: () {
        print("Navigate to detail for ${item.bookName}");
        // Jika Anda ingin animasi Lanjutan DARI SINI ke detail,
        // OpenContainer bisa ditaruh di sini. Tapi untuk sekarang kita buat simpel.
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: CachedNetworkImageProvider(item.userAvatarUrl),
              backgroundColor: theme.colorScheme.surfaceVariant,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      style: GoogleFonts.montserrat(fontSize: 13.5, color: theme.colorScheme.onSurface),
                      children: [
                        TextSpan(text: item.userName, style: const TextStyle(fontWeight: FontWeight.w600)),
                        const TextSpan(text: ' commented on '),
                        TextSpan(text: item.bookName, style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(item.timestamp, style: GoogleFonts.montserrat(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 11)),
                      const SizedBox(width: 8),
                      _buildChapterChip(item.chapterName, theme),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildCommentBlock(item.commentContent, item.isMention, theme),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // ... (sisa kode helper _buildChapterChip dan _buildCommentBlock tidak berubah)
  Widget _buildChapterChip(String chapterName, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(Remix.file_text_line, size: 12, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            chapterName,
            style: GoogleFonts.montserrat(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentBlock(String content, bool isMention, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: const BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
        border: Border(left: BorderSide(color: isMention ? Colors.deepPurple.shade300 : theme.dividerColor.withOpacity(0.8), width: 3.0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text(
          content,
          style: GoogleFonts.montserrat(
            color: theme.colorScheme.onSurface.withOpacity(0.9),
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}