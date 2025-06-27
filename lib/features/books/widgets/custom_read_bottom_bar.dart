// lib/widgets/custom_read_bottom_bar.dart (atau path Anda)
import 'package:flutter/material.dart';
import 'package:nover/src/utils/ui_helpers.dart'; // Untuk responsiveFontSize
import 'package:remixicon/remixicon.dart';

class CustomReadBottomBar extends StatelessWidget {
  final VoidCallback onTableOfContentsPressed;
  final VoidCallback onCommentsPressed;
  final VoidCallback onSettingsPressed;
  final Color? iconColor;
  final Color? backgroundColor;

  // Tinggi standar untuk bottom bar dengan ikon saja
  static const double kBottomBarHeight = 56.0;

  const CustomReadBottomBar({
    super.key,
    required this.onTableOfContentsPressed,
    required this.onCommentsPressed,
    required this.onSettingsPressed,
    this.iconColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveIconColor = iconColor ?? theme.colorScheme.onSurface.withOpacity(0.85); // Sedikit lebih solid tanpa label
    final effectiveBackgroundColor = backgroundColor ?? theme.bottomAppBarTheme.color ?? theme.colorScheme.surfaceContainerHighest;
    final double iconSize = responsiveFontSize(context, 24); // Mungkin sedikit lebih besar tanpa label
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      height: kBottomBarHeight + bottomPadding, // Tinggi total termasuk safe area
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.only(bottom: bottomPadding), // Padding hanya untuk safe area bawah
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center, // Icon di tengah vertikal
        children: <Widget>[
          _buildBottomBarItem(
            context: context,
            icon: Remix.list_unordered,
            tooltip: 'Daftar Isi', // Tooltip tetap berguna
            onPressed: onTableOfContentsPressed,
            iconColor: effectiveIconColor,
            iconSize: iconSize,
          ),
          _buildBottomBarItem(
            context: context,
            icon: Remix.chat_3_line,
            tooltip: 'Komentar',
            onPressed: onCommentsPressed,
            iconColor: effectiveIconColor,
            iconSize: iconSize,
          ),
          _buildBottomBarItem(
            context: context,
            icon: Remix.settings_3_line,
            tooltip: 'Pengaturan',
            onPressed: onSettingsPressed,
            iconColor: effectiveIconColor,
            iconSize: iconSize,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBarItem({
    required BuildContext context,
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    required Color iconColor,
    required double iconSize,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(responsiveFontSize(context, 28)), // Area tap lebih besar
          customBorder: const CircleBorder(), // Bentuk feedback tap
          child: Tooltip( // Menambahkan tooltip karena tidak ada label
            message: tooltip,
            child: SizedBox( // Pastikan area tap cukup
              height: CustomReadBottomBar.kBottomBarHeight, // Tinggi item sama dengan tinggi bar
              child: Icon(icon, color: iconColor, size: iconSize),
            ),
          ),
        ),
      ),
    );
  }
}