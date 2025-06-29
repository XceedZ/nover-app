// lib/src/widgets/custom_menu.dart

import 'package:flutter/material.dart';
import 'package:nover/src/utils/app_fonts.dart'; // Pastikan path ini benar

/// Model data untuk setiap item di dalam menu kustom kita.
class CustomMenuItem {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDanger; // Menandakan apakah ini item "berbahaya" (merah)

  CustomMenuItem({
    required this.title,
    required this.icon,
    required this.onTap,
    this.isDanger = false,
  });
}

/// Kelas helper untuk menampilkan PopupMenu kustom.
class CustomPopupMenu {
  static Future<void> show({
    required BuildContext context,
    required GlobalKey buttonKey, // Kunci dari tombol yang memicu menu
    required List<CustomMenuItem> items,
  }) async {
    final RenderBox renderBox = buttonKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final position = renderBox.localToGlobal(Offset.zero);

    // --- PERBAIKAN 1: Ubah generic type dari <int> menjadi <void> ---
    // Ini karena kita tidak mengharapkan nilai kembalian, hanya aksi onTap.
    await showMenu<void>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy + size.height,
        position.dx + size.width,
        position.dy + size.height,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 8.0,
      items: items.map((item) {
        // --- PERBAIKAN 1 (Lanjutan): Tentukan tipe PopupMenuItem menjadi <void> ---
        return PopupMenuItem<void>(
          onTap: item.onTap,
          padding: EdgeInsets.zero,
          child: _buildMenuItemWidget(context, item),
        );
      }).toList(),
    );
  }

  /// Widget private untuk membangun tampilan setiap item menu.
  static Widget _buildMenuItemWidget(BuildContext context, CustomMenuItem item) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final Color iconColor = item.isDanger ? colorScheme.error : colorScheme.onSurface.withOpacity(0.7);
    final Color textColor = item.isDanger ? colorScheme.error : colorScheme.onSurface;
    final Color? tileColor = item.isDanger ? colorScheme.error.withOpacity(0.1) : null;

    return Container(
      color: tileColor,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Icon(item.icon, color: iconColor, size: 22),
          const SizedBox(width: 16),
          Text(
            item.title,
            // --- PERBAIKAN 2: Menggunakan AppFonts sesuai permintaan ---
            style: AppFonts.titleMedium(color: textColor)?.copyWith(
              fontWeight: FontWeight.w500, // Sedikit penyesuaian agar tidak terlalu tebal
            ),
          ),
        ],
      ),
    );
  }
}