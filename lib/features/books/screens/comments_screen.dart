import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:nover/main.dart';
import 'package:nover/src/models/book_comment.dart';
import 'package:nover/src/repositories/book_repository.dart';
import 'package:nover/src/repositories/dicebear_repository.dart';
import 'package:nover/src/utils/app_fonts.dart';
import 'package:nover/src/utils/date_convert.dart';
import 'package:nover/src/utils/translation.dart';
import 'package:nover/src/widgets/custom_snackbar.dart';
import 'package:remixicon/remixicon.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class CommentsScreen extends StatefulWidget {
  final int bookId;
  final int? highlightCommentId;

  const CommentsScreen({
    super.key,
    required this.bookId,
    this.highlightCommentId,
  });

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final BookRepository _bookRepository = BookRepository();
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  final ItemScrollController _itemScrollController = ItemScrollController();

  BookComment? _replyingToComment;
  List<BookComment> _comments = [];
  int? _highlightedCommentId;
  bool _isLoading = true;
  bool _isPosting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _highlightedCommentId = widget.highlightCommentId;
    _fetchComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  Future<void> _fetchComments({bool showLoadingIndicator = true}) async {
    if (!mounted) return;
    if (showLoadingIndicator) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final flatComments = await _bookRepository.getBookComments(widget.bookId);
      final Map<int, BookComment> commentIdMap = {
        for (var c in flatComments) c.commentId: c
      };
      final List<BookComment> topLevelComments = [];

      for (var comment in flatComments) {
        if (comment.parentCommentId == null) {
          topLevelComments.add(comment);
        } else {
          final parent = commentIdMap[comment.parentCommentId];
          if (parent != null) {
            parent.replies.add(comment);
          }
        }
      }

      if (mounted) {
        setState(() {
          _comments = topLevelComments;
          _isLoading = false;
        });
        if (widget.highlightCommentId != null && showLoadingIndicator) {
          _scrollToComment(topLevelComments);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _scrollToComment(List<BookComment> comments) {
    int targetIndex = -1;
    for (int i = 0; i < comments.length; i++) {
      if (comments[i].commentId == widget.highlightCommentId ||
          comments[i]
              .replies
              .any((r) => r.commentId == widget.highlightCommentId)) {
        targetIndex = i;
        break;
      }
    }

    if (targetIndex != -1) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _itemScrollController.scrollTo(
            index: targetIndex,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
          Future.delayed(const Duration(milliseconds: 600), () {
            if (mounted) setState(() => _highlightedCommentId = null);
          });
        }
      });
    }
  }

  Future<void> _postComment() async {
    if (_commentController.text.trim().isEmpty || _isPosting) return;

    setState(() => _isPosting = true);

    int? parentIdToSend;
    if (_replyingToComment != null) {
      if (_replyingToComment!.parentCommentId != null) {
        parentIdToSend = _replyingToComment!.parentCommentId;
      } else {
        parentIdToSend = _replyingToComment!.commentId;
      }
    }

    try {
      await _bookRepository.postBookComment(
        bookId: widget.bookId,
        commentText: _commentController.text.trim(),
        parentId: parentIdToSend,
      );

      _commentController.clear();
      _cancelReply();
      await _fetchComments(showLoadingIndicator: false);
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(
          context,
          message: e.toString().replaceFirst("Exception: ", ""),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPosting = false);
      }
    }
  }

  void _startReply(BookComment comment) {
    setState(() => _replyingToComment = comment);
    _commentFocusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() => _replyingToComment = null);
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(tl('commentCount', args: {'count': _comments.length})),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Remix.arrow_left_s_line),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _buildBody()),
          _buildCommentInputField(context),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: LoadingAnimationWidget.staggeredDotsWave(
          color: Theme.of(context).colorScheme.primary,
          size: 50,
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(tl('failedToLoadComments'), style: AppFonts.titleMedium()),
            const SizedBox(height: 8),
            ElevatedButton(
                onPressed: () => _fetchComments(showLoadingIndicator: true),
                child: Text(tl('retry'))),
          ],
        ),
      );
    }

    if (_comments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Remix.chat_off_line, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            Text(tl('beTheFirstToComment'),
                style: AppFonts.titleMedium(color: Colors.grey)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _fetchComments(showLoadingIndicator: true),
      child: ScrollablePositionedList.builder(
        itemScrollController: _itemScrollController,
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        itemCount: _comments.length,
        itemBuilder: (context, index) {
          final comment = _comments[index];
          return _CommentItem(
            comment: comment,
            onReply: _startReply,
            isHighlighted: _highlightedCommentId == comment.commentId ||
                comment.replies
                    .any((r) => r.commentId == _highlightedCommentId),
          );
        },
      ),
    );
  }

  Widget _buildCommentInputField(BuildContext context) {
    final theme = Theme.of(context);
    return ValueListenableBuilder<Map<String, dynamic>?>(
      valueListenable: authNotifier,
      builder: (context, currentUser, child) {
        Widget avatarWidget;
        final dicebearRepo = DicebearRepository();
        if (currentUser != null) {
          final String? avatarUrl = currentUser['avatarUrl'];
          final String fullName = currentUser['fullName'] ?? 'User';
          if (avatarUrl != null && avatarUrl.isNotEmpty) {
            avatarWidget = avatarUrl.endsWith('.svg')
                ? SvgPicture.network(avatarUrl, fit: BoxFit.cover)
                : Image.network(avatarUrl, fit: BoxFit.cover);
          } else {
            final String dicebearUrl = dicebearRepo.getAvatarUrl(fullName);
            avatarWidget = SvgPicture.network(dicebearUrl, fit: BoxFit.cover);
          }
        } else {
          avatarWidget =
              Icon(Remix.user_fill, color: theme.colorScheme.onSurfaceVariant);
        }
        return Container(
          padding: EdgeInsets.fromLTRB(
              16, 8, 16, 8 + MediaQuery.of(context).viewPadding.bottom),
          decoration: BoxDecoration(
            color: theme.cardColor,
            border:
            Border(top: BorderSide(color: theme.dividerColor, width: 0.5)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_replyingToComment != null) _buildReplyPreview(context),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: theme.colorScheme.surfaceVariant,
                    child: ClipOval(child: avatarWidget),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      focusNode: _commentFocusNode,
                      decoration: InputDecoration(
                        hintText: _replyingToComment == null
                            ? tl('writeCommentHint')
                            : tl('writeReplyHint'),
                        hintStyle: AppFonts.bodyMedium(
                            color:
                            theme.colorScheme.onSurface.withOpacity(0.5)),
                        fillColor: theme.colorScheme.surfaceVariant,
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none),
                      ),
                      minLines: 1,
                      maxLines: 5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _isPosting
                      ? const SizedBox(
                      width: 40,
                      height: 40,
                      child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(strokeWidth: 2)))
                      : CircleAvatar(
                    radius: 20,
                    backgroundColor: theme.colorScheme.primary,
                    child: IconButton(
                      icon: Icon(Remix.send_plane_2_fill,
                          color: theme.colorScheme.onPrimary, size: 20),
                      onPressed: _postComment,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReplyPreview(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tl('replyingTo',
                      args: {'name': _replyingToComment!.authorPenName}),
                  style: AppFonts.bodySmall(
                      color: theme.colorScheme.onSurface.withOpacity(0.7))
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  _replyingToComment!.commentText,
                  style: AppFonts.bodySmall(
                      color: theme.colorScheme.onSurface.withOpacity(0.7)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Remix.close_line,
                size: 18,
                color: theme.colorScheme.onSurface.withOpacity(0.7)),
            onPressed: _cancelReply,
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          )
        ],
      ),
    );
  }
}

class _CommentItem extends StatefulWidget {
  final BookComment comment;
  final bool isReply;
  final Function(BookComment) onReply;
  final bool isHighlighted;

  const _CommentItem(
      {required this.comment,
        required this.onReply,
        this.isReply = false,
        this.isHighlighted = false});

  @override
  State<_CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<_CommentItem> {
  bool _showReplies = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dicebearRepo = DicebearRepository();
    final String? avatarUrl = widget.comment.authorAvatar;
    final String penName = widget.comment.authorPenName;
    Widget avatarWidget;
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      avatarWidget = avatarUrl.endsWith('.svg')
          ? SvgPicture.network(avatarUrl, fit: BoxFit.cover)
          : Image.network(avatarUrl, fit: BoxFit.cover);
    } else {
      final String dicebearUrl = dicebearRepo.getAvatarUrl(penName);
      avatarWidget = SvgPicture.network(dicebearUrl, fit: BoxFit.cover);
    }
    final containerColor = widget.isHighlighted
        ? theme.colorScheme.primary.withOpacity(0.1)
        : Colors.transparent;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(8.0),
      margin: EdgeInsets.only(
          left: widget.isReply ? 32.0 : 0, top: 4.0, bottom: 4.0),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: widget.isReply ? 16 : 20,
                backgroundColor: theme.colorScheme.surfaceVariant,
                child: ClipOval(child: avatarWidget),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14.0, vertical: 10.0),
                      decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.comment.authorPenName,
                            style: AppFonts.titleSmall(
                                color: theme.colorScheme.onSurface)
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(widget.comment.commentText,
                              style: AppFonts.bodyMedium(
                                  color: theme.colorScheme.onSurface)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildCommentActions(context),
                  ],
                ),
              ),
            ],
          ),
          if (widget.comment.replies.isNotEmpty) _buildRepliesSection(context)
        ],
      ),
    );
  }

  Widget _buildCommentActions(BuildContext context) {
    final theme = Theme.of(context);
    final mutedColor = theme.colorScheme.onSurface.withOpacity(0.6);
    final locale = Localizations.localeOf(context).toString();
    return Padding(
      padding: const EdgeInsets.only(left: 14.0),
      child: Row(
        children: [
          Text(
              DateFormatter.formatApiDateToTimeAgo(
                  widget.comment.createDatetime,
                  locale: locale),
              style: AppFonts.bodySmall(color: mutedColor)),
          const SizedBox(width: 16),
          InkWell(
            onTap: () => widget.onReply(widget.comment),
            child: Text(tl('reply'),
                style: AppFonts.bodySmall(color: mutedColor)
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildRepliesSection(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    return Padding(
      padding:
      const EdgeInsets.only(left: 46.0, top: 8.0), // Disesuaikan paddingnya
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _showReplies = !_showReplies),
            child: Text(
              _showReplies
                  ? tl('hideReplies')
                  : tl('viewReplies',
                  args: {'count': widget.comment.replies.length}),
              style: AppFonts.bodySmall(color: primaryColor)
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          if (_showReplies)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                children: widget.comment.replies
                    .map((reply) => _CommentItem(
                    comment: reply, isReply: true, onReply: widget.onReply))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}