// lib/features/books/widgets/custom_detail_top_bar.dart
import 'package:flutter/material.dart';
import 'package:nover/src/utils/app_fonts.dart';
import 'package:nover/src/utils/ui_helpers.dart';
import 'package:remixicon/remixicon.dart';

class CustomDetailTopBar extends StatelessWidget implements PreferredSizeWidget {
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onBackPressed;
  final VoidCallback onSharePressed;
  final double topPadding;
  final double height;
  final String? bookTitle;
  final String? bookAuthor;
  final String? chapterText;
  final bool showTitleAuthor;

  const CustomDetailTopBar({
    super.key,
    required this.backgroundColor,
    required this.iconColor,
    required this.onBackPressed,
    required this.onSharePressed,
    required this.topPadding,
    required this.height,
    this.bookTitle,
    this.bookAuthor,
    this.chapterText,
    this.showTitleAuthor = false,
  });

  @override
  Widget build(BuildContext context) {
    final double rfsValue = responsiveFontSize(context, 1.0);
    final double iconSize = responsiveFontSize(context, 22);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      color: backgroundColor,
      padding: EdgeInsets.only(
        top: topPadding,
        left: rfsValue * 8,
        right: rfsValue * 8,
      ),
      height: height,
      child: SizedBox(
        height: height - topPadding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Remix.arrow_left_s_line, color: iconColor, size: iconSize + 2),
              onPressed: onBackPressed,
              tooltip: 'Back',
              splashRadius: rfsValue * 24,
              padding: EdgeInsets.all(rfsValue * 10),
            ),
            Expanded(
              child: AnimatedOpacity(
                opacity: showTitleAuthor ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (bookTitle != null && bookTitle!.isNotEmpty)
                      Text(
                        bookTitle!,
                        // --- PERBAIKAN UTAMA DI SINI ---
                        // Mengganti `AppFonts.titleStyle` yang sudah tidak ada
                        // dengan `AppFonts.titleMedium` yang menggunakan Montserrat.
                        style: AppFonts.titleMedium(color: iconColor)?.copyWith(
                          fontSize: responsiveFontSize(context, 15),
                          fontWeight: FontWeight.w600, // Menjadikannya semi-bold
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    if (chapterText != null && chapterText!.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: responsiveFontSize(context, 1.5)),
                        child: Text(
                          chapterText!,
                          style: AppFonts.titleSmall(color: iconColor.withOpacity(0.8))?.copyWith(
                            fontSize: responsiveFontSize(context, 10),
                            fontWeight: FontWeight.w400,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    if (bookAuthor != null && bookAuthor!.isNotEmpty && (chapterText == null || chapterText!.isEmpty))
                      SizedBox(height: responsiveFontSize(context, 1)),
                    if (bookAuthor != null && bookAuthor!.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: (chapterText != null && chapterText!.isNotEmpty) ? responsiveFontSize(context, 1.5) : responsiveFontSize(context, 1)),
                        child: Text(
                          bookAuthor!,
                          style: AppFonts.titleSmall(color: iconColor.withOpacity(0.8))?.copyWith(
                            fontSize: responsiveFontSize(context, 11),
                            fontWeight: FontWeight.w400,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: Icon(Remix.share_line, color: iconColor, size: iconSize),
              onPressed: onSharePressed,
              tooltip: 'Share',
              splashRadius: rfsValue * 24,
              padding: EdgeInsets.all(rfsValue * 10),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
