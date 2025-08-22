// lib/features/home/widgets/sticky_reading_progress_widget.dart
import 'package:flutter/material.dart';
import 'package:nover/src/models/book.dart';
import 'package:nover/src/utils/app_fonts.dart';
import 'package:nover/src/utils/ui_helpers.dart';
import 'package:nover/features/books/screens/book_detail_screen.dart';
import 'package:remixicon/remixicon.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Import untuk CachedNetworkImageProvider

class StickyReadingProgressWidget extends StatefulWidget {
  final Book book;
  final double progress;
  final VoidCallback? onClose;

  const StickyReadingProgressWidget({
    super.key,
    required this.book,
    required this.progress,
    this.onClose,
  });

  @override
  State<StickyReadingProgressWidget> createState() => _StickyReadingProgressWidgetState();
}

class _StickyReadingProgressWidgetState extends State<StickyReadingProgressWidget> with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    // Inisialisasi animasi dengan nilai awal 0.0 agar ada efek dari kiri ke kanan
    _progressAnimation = Tween<double>(begin: 0.0, end: widget.progress).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    _progressController.forward();
  }

  @override
  void didUpdateWidget(covariant StickyReadingProgressWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.progress != oldWidget.progress) {
      // Update animasi jika progres berubah
      _progressAnimation = Tween<double>(begin: _progressAnimation.value, end: widget.progress).animate(CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOut,
      ));
      _progressController
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  Widget _buildImageError(BuildContext context, double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(responsiveFontSize(context, 4)),
        color: Colors.grey.shade300,
      ),
      child: Center(
          child: Icon(Remix.image_line,
              size: responsiveFontSize(context, 20),
              color: Colors.grey.shade600)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double rfs = responsiveFontSize(context, 1);
    ThemeData theme = Theme.of(context);
    ColorScheme colorScheme = theme.colorScheme;
    bool isNetworkImage = widget.book.coverImageUrl.startsWith('http');

    Color barBackgroundColor = colorScheme.surfaceContainer; // Warna yang lebih sesuai tema
    Color progressColor = theme.colorScheme.primary;
    Color progressBackgroundColor = theme.colorScheme.primary.withOpacity(0.2);
    Color iconCloseColor = theme.colorScheme.onSurfaceVariant;
    Color titleColor = theme.colorScheme.onSurface;
    Color subtitleColor = theme.colorScheme.onSurfaceVariant;

    return Material(
      elevation: 6.0,
      color: barBackgroundColor,
      child: InkWell(
        onTap: () {
          // --- PERBAIKAN UTAMA ADA DI SINI ---
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookDetailScreen(
                // Mengirim parameter sesuai konstruktor baru
                bookId: widget.book.bookId,
                initialBookData: widget.book,
              ),
            ),
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: rfs * 16,
              vertical: rfs * 10
          ).copyWith(bottom: rfs * 10 + MediaQuery.of(context).padding.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(rfs * 4),
                    // Menggunakan CachedNetworkImage untuk performa lebih baik
                    child: CachedNetworkImage(
                      imageUrl: widget.book.coverImageUrl,
                      width: rfs * 40,
                      height: rfs * 56,
                      fit: BoxFit.cover,
                      errorWidget: (ctx, err, st) => _buildImageError(ctx, rfs * 40, rfs * 56),
                      placeholder: (ctx, url) => Container(
                        width: rfs * 40,
                        height: rfs * 56,
                        color: theme.colorScheme.surfaceVariant,
                      ),
                    ),
                  ),
                  SizedBox(width: rfs * 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.book.title,
                          style: AppFonts.titleSmall(color: titleColor)?.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: rfs * 2),
                        Text(
                          // Menggunakan properti status yang ada di model Book
                          // atau fallback ke penulis jika status tidak relevan di sini
                          "Continue reading...", // Teks yang lebih relevan
                          style: AppFonts.bodySmall(color: subtitleColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: rfs * 12),
                  IconButton(
                    icon: Icon(Remix.close_line, size: rfs * 28, color: iconCloseColor),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    onPressed: widget.onClose,
                    tooltip: 'Sembunyikan',
                  ),
                ],
              ),
              SizedBox(height: rfs * 8),
              AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return LinearProgressIndicator(
                      value: _progressAnimation.value,
                      backgroundColor: progressBackgroundColor,
                      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                      minHeight: rfs * 3.5,
                      borderRadius: BorderRadius.circular(rfs*2),
                    );
                  }
              ),
            ],
          ),
        ),
      ),
    );
  }
}