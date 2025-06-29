import 'package:flutter/material.dart';
import 'package:nover/src/models/chapter.dart';
import 'package:nover/src/utils/app_fonts.dart';
import 'package:nover/src/utils/date_convert.dart';
import 'package:nover/src/utils/translation.dart';
import 'package:nover/src/widgets/custom_menu.dart';
import 'package:remixicon/remixicon.dart';

class AllChaptersBottomSheet extends StatefulWidget {
  final List<Chapter> allChapters;
  const AllChaptersBottomSheet({super.key, required this.allChapters});

  @override
  State<AllChaptersBottomSheet> createState() => _AllChaptersBottomSheetState();
}

class _AllChaptersBottomSheetState extends State<AllChaptersBottomSheet> {
  late List<Chapter> _filteredChapters;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredChapters = widget.allChapters;
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
    setState(() {
      _filteredChapters = query.isEmpty
          ? widget.allChapters
          : widget.allChapters
          .where((chapter) => chapter.title.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.85,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 8, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tl('allChapters'),
                  style: AppFonts.appBarTitle(color: colorScheme.onSurface),
                ),
                IconButton(
                  icon: const Icon(Remix.close_line, size: 24.0),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchController,
              style: AppFonts.titleMedium(color: colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: tl('searchChapter'),
                hintStyle: AppFonts.titleMedium(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
                prefixIcon: Icon(
                  Remix.search_line,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
                filled: true,
                fillColor: colorScheme.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.primary),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredChapters.length,
              padding: const EdgeInsets.only(top: 8),
              itemBuilder: (context, index) {
                return _ChapterListItem(chapter: _filteredChapters[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ChapterListItem extends StatelessWidget {
  final Chapter chapter;
  const _ChapterListItem({required this.chapter});

  void _showChapterMenu(BuildContext context, GlobalKey menuKey) {
    CustomPopupMenu.show(
      context: context,
      buttonKey: menuKey,
      items: [
        CustomMenuItem(title: tl('edit'), icon: Remix.edit_2_line, onTap: () {}),
        CustomMenuItem(title: tl('remove'), icon: Remix.delete_bin_line, isDanger: true, onTap: () {}),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final GlobalKey menuKey = GlobalKey();

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.of(context).pop(chapter);
            },
            borderRadius: BorderRadius.zero,
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
                        Row(
                          children: [
                            Text(
                              DateFormatter.formatApiDate(chapter.createDatetime),
                              style: AppFonts.titleSmall(color: colorScheme.onSurface.withOpacity(0.6)),
                            ),
                            const SizedBox(width: 12),
                            Icon(Remix.eye_line, size: 14, color: colorScheme.onSurface.withOpacity(0.6)),
                            const SizedBox(width: 4),
                            Text(
                              chapter.totalViews.toString(),
                              style: AppFonts.titleSmall(color: colorScheme.onSurface.withOpacity(0.6)),
                            ),
                            const SizedBox(width: 12),
                            Icon(Remix.chat_1_line, size: 14, color: colorScheme.onSurface.withOpacity(0.6)),
                            const SizedBox(width: 4),
                            Text(
                              0.toString(),
                              style: AppFonts.titleSmall(color: colorScheme.onSurface.withOpacity(0.6)),
                            ),
                            const SizedBox(width: 12),
                            Icon(Remix.copper_coin_line, size: 14, color: Colors.orange.shade700),
                            const SizedBox(width: 4),
                            Text(
                              chapter.coinCost.toString(),
                              style: AppFonts.titleSmall(color: Colors.orange.shade800)?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    key: menuKey,
                    onPressed: () => _showChapterMenu(context, menuKey),
                    icon: Icon(Remix.more_2_fill, color: colorScheme.onSurface.withOpacity(0.6), size: 20),
                    tooltip: 'Opsi Bab',
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
