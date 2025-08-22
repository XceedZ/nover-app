// lib/src/widgets/custom_snackbar.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nover/src/utils/app_fonts.dart';
import 'package:nover/src/utils/translation.dart';
import 'package:remixicon/remixicon.dart';

enum AppSnackbarType { success, error, info }

/// Kelas helper untuk menampilkan notifikasi overlay yang konsisten dan aman.
/// Menggunakan OverlayEntry untuk kontrol penuh atas posisi dan animasi.
class AppSnackbar {
  AppSnackbar._();

  static OverlayEntry? _overlayEntry;
  // Timer sekarang dikelola di dalam widget notifikasi itu sendiri
  // untuk memastikan animasi keluar berjalan dengan benar.

  static void showSuccess(BuildContext context, {String? title, required String message}) {
    _show(
      context,
      title: title ?? tl('success'),
      message: message,
      type: AppSnackbarType.success,
    );
  }

  static void showError(BuildContext context, {String? title, required String message}) {
    _show(
      context,
      title: title ?? tl('error'),
      message: message,
      type: AppSnackbarType.error,
    );
  }

  static void _show(BuildContext context, {required String title, required String message, required AppSnackbarType type}) {
    // Sembunyikan notifikasi yang mungkin masih ada
    _hide();

    final overlay = Overlay.of(context);

    // Buat OverlayEntry
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return _CustomSnackbarWidget(
          title: title,
          message: message,
          type: type,
          // Saat widget ini selesai dengan animasi keluarnya, ia akan memanggil _hide.
          onDismissed: _hide,
        );
      },
    );

    // Tampilkan overlay baru
    overlay.insert(_overlayEntry!);
  }

  static void _hide() {
    // Fungsi ini sekarang hanya bertugas menghapus overlay dari tree.
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

/// Widget internal yang sekarang mengelola animasi masuk dan keluarnya sendiri.
class _CustomSnackbarWidget extends StatefulWidget {
  final String title;
  final String message;
  final AppSnackbarType type;
  final VoidCallback onDismissed; // Callback untuk memberitahu AppSnackbar agar menghapus overlay

  const _CustomSnackbarWidget({
    required this.title,
    required this.message,
    required this.type,
    required this.onDismissed,
  });

  @override
  State<_CustomSnackbarWidget> createState() => _CustomSnackbarWidgetState();
}

class _CustomSnackbarWidgetState extends State<_CustomSnackbarWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    // Tambahkan listener untuk menghilangkan overlay setelah animasi keluar selesai
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        widget.onDismissed();
      }
    });

    // Jalankan animasi masuk
    _controller.forward();

    // Mulai timer untuk animasi keluar otomatis
    _timer = Timer(const Duration(seconds: 2), () {
      _startExitAnimation();
    });
  }

  void _startExitAnimation() {
    _timer?.cancel(); // Batalkan timer jika ada
    if (mounted) {
      // Jalankan animasi secara terbalik untuk efek "slide up"
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color iconAndBackgroundColor;
    IconData iconData;

    switch (widget.type) {
      case AppSnackbarType.success:
        iconAndBackgroundColor = Colors.green.shade500;
        iconData = Remix.checkbox_circle_fill;
        break;
      case AppSnackbarType.error:
        iconAndBackgroundColor = colorScheme.error;
        iconData = Remix.error_warning_fill;
        break;
      case AppSnackbarType.info:
        iconAndBackgroundColor = Colors.blue.shade500;
        iconData = Remix.information_fill;
        break;
    }

    return Positioned(
      top: MediaQuery.of(context).viewPadding.top + 8,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _offsetAnimation,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: iconAndBackgroundColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(iconData, color: iconAndBackgroundColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.title,
                        style: AppFonts.titleMedium(color: colorScheme.onSurface)?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (widget.message.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          widget.message,
                          style: AppFonts.titleSmall(color: colorScheme.onSurface.withOpacity(0.7)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ]
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Remix.close_line, color: colorScheme.onSurface.withOpacity(0.6), size: 20),
                  onPressed: _startExitAnimation, // Tombol close sekarang memicu animasi keluar
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
