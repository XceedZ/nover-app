// lib/features/books/widgets/chapters_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:nover/src/models/book.dart';
import 'package:nover/src/models/chapter.dart';
import 'package:nover/src/utils/app_fonts.dart';
import 'package:nover/src/utils/date_convert.dart';
import 'package:nover/src/utils/translation.dart';
import 'package:nover/src/utils/ui_helpers.dart';
import 'package:remixicon/remixicon.dart';
import 'package:cached_network_image/cached_network_image.dart';
// FIX: Import screen wrapper yang benar
import 'package:nover/features/books/screens/read_chapter_screen.dart';

class ChaptersBottomSheet extends StatefulWidget {
  final Book book;
  final String? authorPenName;
  final List<Chapter> chapters;

  const ChaptersBottomSheet({
    super.key,
    required this.book,
    required this.authorPenName,
    required this.chapters,
  });

  @override
  State<ChaptersBottomSheet> createState() => _ChaptersBottomSheetState();
}

class _ChaptersBottomSheetState extends State<ChaptersBottomSheet> {
  late List<Chapter> _filteredChapters;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredChapters = widget.chapters;
    _searchController.addListener(_filterChapters);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterChapters);
    _searchController.dispose();
    super.dispose();
  }

  void _filterChapters() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() => _filteredChapters = widget.chapters);
    } else {
      setState(() {
        _filteredChapters = widget.chapters
            .where((chapter) => chapter.title.toLowerCase().contains(query))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final onSheetColor = colorScheme.onSurface;
    final subtleOnSheetColor = onSheetColor.withOpacity(0.65);
    final iconColor = onSheetColor.withOpacity(0.7);

    return FractionallySizedBox(
      heightFactor: 0.88,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
        child: Container(
          color: colorScheme.surface,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(responsiveFontSize(context, 16.0)),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(responsiveFontSize(context, 4.0)),
                      child: CachedNetworkImage(
                        imageUrl: widget.book.coverImageUrl,
                        width: responsiveFontSize(context, 48.0),
                        height: responsiveFontSize(context, 48.0 * 1.5),
                        fit: BoxFit.cover,
                        errorWidget: (ctx, err, st) => Container(
                          width: responsiveFontSize(context, 48.0),
                          height: responsiveFontSize(context, 48.0 * 1.5),
                          color: colorScheme.surfaceVariant,
                          child: Icon(Remix.image_line, color: iconColor, size: responsiveFontSize(context, 24)),
                        ),
                      ),
                    ),
                    SizedBox(width: responsiveFontSize(context, 12.0)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.book.title,
                            style: AppFonts.titleMedium(color: onSheetColor)?.copyWith(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: responsiveFontSize(context, 4.0)),
                          if (widget.authorPenName != null && widget.authorPenName!.isNotEmpty)
                            Text(
                              widget.authorPenName!,
                              style: AppFonts.titleSmall(color: subtleOnSheetColor),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Remix.close_line, color: iconColor, size: responsiveFontSize(context, 24.0)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: TextField(
                  controller: _searchController,
                  style: AppFonts.titleSmall(color: onSheetColor),
                  decoration: InputDecoration(
                    hintText: tl('searchChapter'),
                    hintStyle: AppFonts.titleSmall(color: subtleOnSheetColor),
                    prefixIcon: Icon(Remix.search_line, color: subtleOnSheetColor),
                    isDense: true,
                    filled: true,
                    fillColor: theme.colorScheme.surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _filteredChapters.isEmpty
                    ? Center(
                  child: Text(
                    tl('noChaptersYet'),
                    style: AppFonts.titleMedium(color: subtleOnSheetColor),
                  ),
                )
                    : ListView.builder(
                  itemCount: _filteredChapters.length,
                  padding: const EdgeInsets.only(top: 8),
                  itemBuilder: (context, index) {
                    return _ChapterListItem(chapter: _filteredChapters[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChapterListItem extends StatelessWidget {
  final Chapter chapter;
  const _ChapterListItem({required this.chapter});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Tutup bottom sheet terlebih dahulu
              Navigator.of(context).pop();
              // FIX: Arahkan ke ReadChapterScreen, bukan ReadNovelScreen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReadChapterScreen(
                    chapterId: chapter.chapterId,
                    initialTitle: chapter.title,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: theme.brightness == Brightness.light
                        ? colorScheme.secondaryContainer
                        : colorScheme.primary,
                    child: Text(
                      '${chapter.chapterOrder}',
                      style: AppFonts.titleSmall(
                        color: theme.brightness == Brightness.light
                            ? colorScheme.onSecondaryContainer
                            : colorScheme.onPrimary,
                      )?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chapter.title,
                          style: AppFonts.titleMedium(color: colorScheme.onSurface)?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 12,
                          runSpacing: 4,
                          children: [
                            Text(
                              DateFormatter.formatApiDate(chapter.createDatetime),
                              style: AppFonts.titleSmall(color: colorScheme.onSurface.withOpacity(0.6)),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Remix.eye_line, size: 14, color: colorScheme.onSurface.withOpacity(0.6)),
                                const SizedBox(width: 4),
                                Text(
                                  chapter.totalViews.toString(),
                                  style: AppFonts.titleSmall(color: colorScheme.onSurface.withOpacity(0.6)),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Remix.chat_3_line, size: 14, color: colorScheme.onSurface.withOpacity(0.6)),
                                const SizedBox(width: 4),
                                Text(
                                  "0",
                                  style: AppFonts.titleSmall(color: colorScheme.onSurface.withOpacity(0.6)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (chapter.coinCost > 0)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Icon(
                        Remix.lock_line,
                        color: Colors.orange.shade700,
                        size: 20,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Divider(
            color: theme.dividerColor.withOpacity(0.5),
            thickness: 0.6,
            height: 1,
          ),
        ),
      ],
    );
  }
}