import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:nover/features/books/screens/comments_screen.dart';
import 'package:nover/src/models/notification_item.dart';
import 'package:nover/src/repositories/dicebear_repository.dart';
import 'package:nover/src/repositories/notification_repository.dart';
import 'package:nover/src/utils/app_fonts.dart';
import 'package:nover/src/utils/date_convert.dart';
import 'package:nover/src/utils/translation.dart';
import 'package:remixicon/remixicon.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationRepository _notificationRepository =
  NotificationRepository();
  final ScrollController _scrollController = ScrollController();

  List<NotificationItem> _notifications = [];
  int _currentPage = 1;
  bool _hasNextPage = true;
  bool _isFirstLoadRunning = false;
  bool _isLoadMoreRunning = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initialFetch();
    _scrollController.addListener(_loadMore);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_loadMore);
    _scrollController.dispose();
    super.dispose();
  }

  void _initialFetch() async {
    setState(() {
      _isFirstLoadRunning = true;
      _error = null;
    });
    try {
      final res = await _notificationRepository.getNotifications(page: 1);
      setState(() {
        _notifications = res.notifications;
        _hasNextPage = res.pagination.currentPage < res.pagination.totalPages;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    }
    setState(() => _isFirstLoadRunning = false);
  }

  void _loadMore() async {
    if (_hasNextPage &&
        !_isFirstLoadRunning &&
        !_isLoadMoreRunning &&
        _scrollController.position.extentAfter < 200) {
      setState(() => _isLoadMoreRunning = true);
      _currentPage += 1;
      try {
        final res =
        await _notificationRepository.getNotifications(page: _currentPage);
        setState(() {
          _notifications.addAll(res.notifications);
          _hasNextPage =
              res.pagination.currentPage < res.pagination.totalPages;
        });
      } catch (e) {
        // Handle error, maybe show a snackbar
      }
      setState(() => _isLoadMoreRunning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(tl('notification'),
            style: AppFonts.appBarTitle(color: theme.colorScheme.onSurface)),
        leading: IconButton(
          icon: Icon(Remix.arrow_left_s_line,
              color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isFirstLoadRunning) {
      return Center(
        child: LoadingAnimationWidget.staggeredDotsWave(
            color: Theme.of(context).colorScheme.primary, size: 50),
      );
    }
    if (_error != null) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('Failed to load notifications.', style: AppFonts.titleMedium()),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: _initialFetch, child: const Text('Retry')),
        ]),
      );
    }
    if (_notifications.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Remix.notification_off_line, size: 60, color: Colors.grey),
          const SizedBox(height: 16),
          Text('No notifications yet.',
              style: AppFonts.titleMedium(color: Colors.grey)),
        ]),
      );
    }
    return ListView.separated(
      controller: _scrollController,
      padding: EdgeInsets.zero,
      itemCount: _notifications.length + (_isLoadMoreRunning ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _notifications.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return _buildNotificationItem(_notifications[index], Theme.of(context));
      },
      separatorBuilder: (context, index) => Divider(
          indent: 20,
          endIndent: 20,
          height: 1,
          color: Theme.of(context).dividerColor.withOpacity(0.5)),
    );
  }

  Widget _buildNotificationItem(NotificationItem item, ThemeData theme) {
    final locale = Localizations.localeOf(context).toString();
    final dicebearRepo = DicebearRepository();
    final String? avatarUrl = item.userAvatarUrl;
    final String penName = item.userName ?? 'User';

    Widget avatarWidget;
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      avatarWidget = avatarUrl.endsWith('.svg')
          ? SvgPicture.network(avatarUrl, fit: BoxFit.cover)
          : CachedNetworkImage(imageUrl: avatarUrl, fit: BoxFit.cover);
    } else {
      final String dicebearUrl = dicebearRepo.getAvatarUrl(penName);
      avatarWidget = SvgPicture.network(dicebearUrl, fit: BoxFit.cover);
    }

    TextSpan contentSpan;
    if (item.notificationType == 'NEW_COMMENT' ||
        item.notificationType == 'COMMENT_REPLY') {
      contentSpan = TextSpan(
        children: [
          TextSpan(
              text: penName, style: const TextStyle(fontWeight: FontWeight.w600)),
          TextSpan(text: tl('commentedOn')),
          TextSpan(
              text: item.bookName ?? tl('a_book'),
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      );
    } else {
      contentSpan = TextSpan(text: item.userName ?? 'Notification');
    }

    return InkWell(
      onTap: () {
        if (item.bookId != null &&
            (item.notificationType == 'NEW_COMMENT' ||
                item.notificationType == 'COMMENT_REPLY')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CommentsScreen(
                bookId: item.bookId!,
                highlightCommentId: item.relatedEntityId,
              ),
            ),
          );
        } else {
          print("Navigasi untuk tipe notifikasi ini belum diimplementasikan.");
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: theme.colorScheme.surfaceVariant,
              child: ClipOval(child: avatarWidget),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      style: GoogleFonts.montserrat(
                          fontSize: 13.5,
                          color: theme.colorScheme.onSurface),
                      children: [contentSpan],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                          DateFormatter.formatApiDateToTimeAgo(
                              item.createDatetime,
                              locale: locale),
                          style: GoogleFonts.montserrat(
                              color: theme.colorScheme.onSurface
                                  .withOpacity(0.6),
                              fontSize: 11)),
                      const SizedBox(width: 8),
                      if (item.chapterName != null)
                        _buildChapterChip(item.chapterName!, theme),
                    ],
                  ),
                  if (item.commentContent != null &&
                      item.commentContent!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildCommentBlock(item.commentContent!, false, theme),
                  ]
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildChapterChip(String chapterName, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(Remix.file_text_line,
              size: 12, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(chapterName,
              style: GoogleFonts.montserrat(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildCommentBlock(String content, bool isMention, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: const BorderRadius.only(
            topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
        border: Border(
            left: BorderSide(
                color: isMention
                    ? Colors.deepPurple.shade300
                    : theme.dividerColor.withOpacity(0.8),
                width: 3.0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text(content,
            style: GoogleFonts.montserrat(
                color: theme.colorScheme.onSurface.withOpacity(0.9),
                fontSize: 13,
                height: 1.5)),
      ),
    );
  }
}