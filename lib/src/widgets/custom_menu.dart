// lib/src/widgets/custom_menu.dart
import 'package:flutter/material.dart';
import 'package:nover/src/utils/app_fonts.dart';

/// Model untuk setiap item di dalam menu kustom.
class CustomMenuItem {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isDanger;

  CustomMenuItem({
    required this.title,
    required this.icon,
    this.onTap,
    this.isDanger = false,
  });
}

/// Kelas untuk menampilkan PopupMenu kustom yang modern.
class CustomPopupMenu {
  CustomPopupMenu._();

  static void show({
    required BuildContext context,
    required GlobalKey buttonKey,
    required List<CustomMenuItem> items,
  }) {
    // Dapatkan posisi dan ukuran tombol yang ditekan
    final RenderBox? renderBox = buttonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    final RelativeRect position = RelativeRect.fromLTRB(
      offset.dx, // left
      offset.dy + size.height, // top (di bawah tombol)
      offset.dx + size.width, // right
      offset.dy + size.height, // bottom
    );

    // Gunakan showMenu bawaan Flutter, ini adalah cara yang paling stabil.
    showMenu<void>(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      items: items.map((item) {
        return PopupMenuItem<void>(
          // UBAH: onTap sekarang langsung memanggil aksi.
          // showMenu secara otomatis akan menutup menu setelah onTap selesai.
          onTap: item.onTap,
          child: Row(
            children: [
              Icon(
                item.icon,
                size: 20,
                color: item.isDanger ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: 12),
              Text(
                item.title,
                style: AppFonts.titleSmall(
                  color: item.isDanger ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
