// lib/features/home/widgets/sticky_reading_progress_widget.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nover/features/home/screens/home_screen_content.dart'; // Untuk akses Book model & responsiveFontSize
import 'package:nover/features/books/screens/book_detail_screen.dart'; // Untuk navigasi ke detail
import 'package:remixicon/remixicon.dart';

// Asumsi responsiveFontSize ada di scope global atau diimpor
// Jika tidak, Anda perlu menyediakannya di sini atau mengimpornya.

class StickyReadingProgressWidget extends StatefulWidget {
  final Book book;
  final double progress; // Nilai antara 0.0 dan 1.0
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
      duration: const Duration(milliseconds: 800), // Durasi animasi progress bar
      vsync: this,
    );
    _updateProgressAnimation(0.0, widget.progress); // Mulai dari 0 ke progress saat ini
    _progressController.forward();
  }

  void _updateProgressAnimation(double oldProgress, double newProgress) {
    _progressAnimation = Tween<double>(
      begin: oldProgress, // Mulai dari progress sebelumnya (atau 0 untuk animasi awal)
      end: newProgress,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(covariant StickyReadingProgressWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.progress != oldWidget.progress) {
      _updateProgressAnimation(_progressAnimation.value, widget.progress); // Animasikan dari nilai saat ini ke nilai baru
      _progressController.reset();
      _progressController.forward();
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
    bool isNetworkImage = widget.book.imageUrl.startsWith('http');

    Color barBackgroundColor = colorScheme.background;
    Color progressColor = theme.colorScheme.primary;
    Color progressBackgroundColor = theme.colorScheme.primary.withOpacity(0.2);
    Color iconCloseColor = theme.textTheme.bodySmall?.color ?? Colors.grey.shade600;
    Color titleColor = theme.textTheme.titleSmall?.color ?? Colors.black87;
    Color subtitleColor = theme.textTheme.bodySmall?.color ?? Colors.grey.shade600;

    return Material(
      elevation: 6.0,
      color: barBackgroundColor,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BookDetailScreen(book: widget.book)),
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
                    child: isNetworkImage
                        ? Image.network(
                      widget.book.imageUrl,
                      width: rfs * 40,
                      height: rfs * 56,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, st) => _buildImageError(ctx, rfs * 40, rfs * 56),
                    )
                        : Image.asset(
                      widget.book.imageUrl,
                      width: rfs * 40,
                      height: rfs * 56,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, st) => _buildImageError(ctx, rfs * 40, rfs * 56),
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
                          style: GoogleFonts.montserrat(
                            fontSize: rfs * 13.5,
                            fontWeight: FontWeight.w600,
                            color: titleColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: rfs * 2),
                        Text(
                          widget.book.chapter.isNotEmpty ? widget.book.chapter : widget.book.author,
                          style: GoogleFonts.montserrat(
                            fontSize: rfs * 11,
                            fontWeight: FontWeight.w400,
                            color: subtitleColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: rfs * 12),
                  IconButton(
                    icon: Icon(RemixIcons.close_line, size: rfs * 28, color: iconCloseColor),
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
                      value: _progressAnimation.value, // Gunakan nilai animasi
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