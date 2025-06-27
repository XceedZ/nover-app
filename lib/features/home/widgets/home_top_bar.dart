import 'package:flutter/material.dart';
import 'package:nover/src/utils/ui_helpers.dart'; // <-- Impor responsiveFontSize dari utilitas
import 'package:remixicon/remixicon.dart';
import 'package:nover/features/search/screens/search_screen.dart'; // Sesuaikan path jika perlu

class HomeTopBar extends StatefulWidget implements PreferredSizeWidget {
  const HomeTopBar({super.key});

  @override
  State<HomeTopBar> createState() => _HomeTopBarState();

  @override
  // Gunakan nilai tetap atau kToolbarHeight untuk stabilitas
  // Tinggi AppBar sebenarnya akan diatur oleh toolbarHeight di dalam build State
  // atau default Flutter jika tidak diset. Ini untuk kontrak PreferredSizeWidget.
  Size get preferredSize => const Size.fromHeight(60.0); // Contoh: tinggi 60
}

class _HomeTopBarState extends State<HomeTopBar> {
  // State untuk search (jika Anda mengembalikan fungsionalitas search di sini nanti)
  // bool _isSearching = false;
  // final TextEditingController _searchController = TextEditingController();
  // final FocusNode _searchFocusNode = FocusNode();

  // @override
  // void initState() {
  //   super.initState();
  //   _searchController.addListener(() {
  //     if (mounted) {
  //       setState(() {});
  //     }
  //   });
  // }

  // @override
  // void dispose() {
  //   _searchController.dispose();
  //   _searchFocusNode.dispose();
  //   super.dispose();
  // }

  // void _toggleSearch() {
  //   setState(() {
  //     _isSearching = !_isSearching;
  //     if (_isSearching) {
  //       Future.delayed(const Duration(milliseconds: 50), () {
  //         if (mounted) _searchFocusNode.requestFocus();
  //       });
  //     } else {
  //       _searchController.clear();
  //       FocusScope.of(context).unfocus();
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    ColorScheme colorScheme = theme.colorScheme;
    AppBarTheme appBarTheme = theme.appBarTheme;

    // Warna berdasarkan tema
    Color appBarBackgroundColor = appBarTheme.backgroundColor ?? colorScheme.surface;
    Color iconColor = appBarTheme.foregroundColor ?? colorScheme.onSurface;
    Color surfaceTintColor = appBarTheme.surfaceTintColor ?? appBarBackgroundColor;
    double elevation = appBarTheme.elevation ?? 0.5;
    double scrolledUnderElevation = appBarTheme.scrolledUnderElevation ?? 1.0;

    // Tinggi logo disesuaikan agar muat dalam AppBar
    final double logoHeight = responsiveFontSize(context, 100.0);
    // Tinggi AppBar yang diinginkan, bisa diambil dari preferredSize
    final double toolbarHeight = widget.preferredSize.height;


    // Jika Anda ingin mengembalikan fungsionalitas search bar dinamis,
    // Anda perlu mengaktifkan kembali _isSearching dan logika terkait.
    // Untuk saat ini, kita buat ikon search hanya menavigasi.

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: appBarBackgroundColor,
      elevation: elevation,
      scrolledUnderElevation: scrolledUnderElevation,
      surfaceTintColor: surfaceTintColor,
      titleSpacing: 0,
      centerTitle: false, // Judul tidak di tengah
      toolbarHeight: toolbarHeight, // Mengatur tinggi AppBar
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
                  splashRadius: responsiveFontSize(context, 22),
                  padding: EdgeInsets.all(responsiveFontSize(context, 8)),
                ),
                IconButton(
                  icon: Icon(Remix.notification_3_line, size: responsiveFontSize(context, 24), color: iconColor),
                  onPressed: () {
                    print('Notification icon tapped from HomeTopBar');
                    // TODO: Implementasi navigasi atau aksi notifikasi
                  },
                  tooltip: 'Notifications',
                  splashRadius: responsiveFontSize(context, 22),
                  padding: EdgeInsets.all(responsiveFontSize(context, 8)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}