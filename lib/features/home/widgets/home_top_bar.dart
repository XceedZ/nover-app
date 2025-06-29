// lib/features/home/widgets/home_top_bar.dart

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:nover/src/utils/ui_helpers.dart';
import 'package:remixicon/remixicon.dart';
import 'package:nover/features/search/screens/search_screen.dart';
import 'package:nover/features/notifications/screens/notification_screen.dart';
import 'package:nover/src/utils/translation.dart';

class HomeTopBar extends StatefulWidget implements PreferredSizeWidget {
  const HomeTopBar({super.key});

  @override
  State<HomeTopBar> createState() => _HomeTopBarState();

  @override
  Size get preferredSize => const Size.fromHeight(60.0);
}

class _HomeTopBarState extends State<HomeTopBar> {

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    ColorScheme colorScheme = theme.colorScheme;
    AppBarTheme appBarTheme = theme.appBarTheme;

    Color appBarBackgroundColor = appBarTheme.backgroundColor ?? colorScheme.surface;
    Color iconColor = appBarTheme.foregroundColor ?? colorScheme.onSurface;
    Color surfaceTintColor = appBarTheme.surfaceTintColor ?? appBarBackgroundColor;
    double elevation = appBarTheme.elevation ?? 0.5;
    double scrolledUnderElevation = appBarTheme.scrolledUnderElevation ?? 1.0;

    final double logoHeight = responsiveFontSize(context, 100.0);
    final double toolbarHeight = widget.preferredSize.height;

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: appBarBackgroundColor,
      elevation: elevation,
      scrolledUnderElevation: scrolledUnderElevation,
      surfaceTintColor: surfaceTintColor,
      titleSpacing: 0,
      centerTitle: false,
      toolbarHeight: toolbarHeight,
      title: Padding(
        padding: EdgeInsets.symmetric(horizontal: responsiveFontSize(context, 16.0)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ColorFiltered(
              colorFilter: Theme.of(context).brightness == Brightness.dark
                  ? const ColorFilter.mode(Colors.white, BlendMode.srcIn)
                  : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
              child: Image.asset(
                'assets/images/logo-removebg-preview.png',
                height: logoHeight,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Remix.book_3_line,
                    size: logoHeight,
                    color: iconColor,
                  );
                },
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Remix.search_line, size: responsiveFontSize(context, 24), color: iconColor),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SearchScreen()),
                    );
                  },
                  tooltip: 'Search',
                ),
                // --- PERUBAHAN UTAMA: Bungkus IconButton dengan OpenContainer ---
                OpenContainer(
                  transitionType: ContainerTransitionType.fadeThrough,
                  openColor: theme.scaffoldBackgroundColor,
                  closedColor: appBarBackgroundColor,
                  closedElevation: 0,
                  openElevation: 0,
                  closedShape: const CircleBorder(),
                  openShape: const RoundedRectangleBorder(),
                  transitionDuration: const Duration(milliseconds: 350),
                  openBuilder: (context, _) {
                    return const NotificationScreen();
                  },
                  // Widget awal (tombol notifikasi)
                  closedBuilder: (context, openContainer) {
                    return IconButton(
                      icon: Icon(Remix.notification_3_line, size: responsiveFontSize(context, 24), color: iconColor),
                      onPressed: openContainer, // Panggil ini untuk memulai animasi
                      tooltip: tl('notification'),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}