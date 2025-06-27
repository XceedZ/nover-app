// lib/src/widgets/custom_bottom_nav_bar.dart
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final Duration animationDuration;
  final double iconSize;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.animationDuration = const Duration(milliseconds: 200),
    this.iconSize = 28.0,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context); // Ambil tema saat ini
    ColorScheme colorScheme = theme.colorScheme; // Ambil ColorScheme dari tema

    // Tentukan warna berdasarkan tema
    // Untuk item yang terpilih, kita bisa gunakan warna primer dari tema
    Color navSelectedItemColor = colorScheme.primary;
    // Untuk item yang tidak terpilih, kita bisa gunakan warna onSurface dengan opacity
    // atau warna sekunder yang lebih lembut dari tema
    Color navUnselectedItemColor = colorScheme.onSurface.withOpacity(0.6);
    // Warna latar belakang BottomNavigationBar bisa diambil dari theme.bottomAppBarColor
    // atau theme.colorScheme.surface (putih di light theme, gelap di dark theme)
    Color navBackgroundColor = theme.bottomAppBarTheme.color ?? colorScheme.background;
    // Elevasi bisa diambil dari theme.bottomAppBarTheme.elevation
    double navElevation = theme.bottomAppBarTheme.elevation ?? 5.0;


    return BottomNavigationBar(
      iconSize: iconSize,
      items: <BottomNavigationBarItem>[
        // Item Beranda
        BottomNavigationBarItem(
          icon: AnimatedSwitcher(
            duration: animationDuration,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: Icon(
              currentIndex == 0 ? RemixIcons.home_5_fill : RemixIcons.home_5_line,
              key: ValueKey<IconData>(currentIndex == 0 ? RemixIcons.home_5_fill : RemixIcons.home_5_line),
            ),
          ),
          label: 'Home', // Label dalam Bahasa Inggris
        ),
        // Item Buku (Novel)
        BottomNavigationBarItem(
          icon: AnimatedSwitcher(
            duration: animationDuration,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: Icon(
              currentIndex == 1 ? RemixIcons.book_open_fill : RemixIcons.book_open_line,
              key: ValueKey<IconData>(currentIndex == 1 ? RemixIcons.book_open_fill : RemixIcons.book_open_line),
            ),
          ),
          label: 'Books', // Label dalam Bahasa Inggris
        ),
        // Item Profil
        BottomNavigationBarItem(
          icon: AnimatedSwitcher(
            duration: animationDuration,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: Icon(
              currentIndex == 2 ? RemixIcons.user_smile_fill : RemixIcons.user_smile_line,
              key: ValueKey<IconData>(currentIndex == 2 ? RemixIcons.user_smile_fill : RemixIcons.user_smile_line),
            ),
          ),
          label: 'Profile', // Label dalam Bahasa Inggris
        ),
      ],
      currentIndex: currentIndex,
      selectedItemColor: navSelectedItemColor,     // Warna dari tema
      unselectedItemColor: navUnselectedItemColor, // Warna dari tema
      onTap: onTap,
      showSelectedLabels: false, // Sesuai kode Anda, label tidak ditampilkan
      showUnselectedLabels: false, // Sesuai kode Anda, label tidak ditampilkan
      type: BottomNavigationBarType.fixed, // Atau .shifting jika Anda mau efek shifting
      backgroundColor: navBackgroundColor,     // Warna latar dari tema
      elevation: navElevation,                 // Elevasi dari tema atau nilai default
    );
  }
}