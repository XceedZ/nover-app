// lib/features/home/screens/home_page.dart (MyHomePage)
import 'package:flutter/material.dart';
import 'package:nover/src/widgets/custom_bottom_nav_bar.dart';
import 'package:nover/features/home/screens/home_screen_content.dart';
import 'package:nover/features/home/widgets/home_top_bar.dart';
import 'package:nover/features/collections/screens/book_collections_screen.dart';
import 'package:nover/features/profile/screens/profile_screen.dart';
// Import tambahan jika diperlukan, misalnya flutter_translate untuk debug
// import 'package:flutter_translate/flutter_translate.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  // HILANGKAN 'static final' dan buat sebagai instance variable biasa.
  // Widget-widget ini (karena 'const') akan menjadi konfigurasi.
  // Ketika MyHomePage di-rebuild dengan BuildContext baru (karena MaterialApp key berubah),
  // IndexedStack akan memberikan BuildContext baru ini ke ProfileScreen,
  // dan State dari ProfileScreen (yang StatefulWidget) akan me-rebuild tampilannya.
  final List<Widget> _widgetOptions = <Widget>[
    const HomeScreenContent(),    // Index 0: Beranda
    const BookCollectionsScreen(),  // Index 1: Buku (Koleksi)
    const ProfileScreen(),        // Index 2: Profil
  ];

  // Alternatif lain adalah menginisialisasi di initState atau didChangeDependencies
  // jika Anda perlu membuat instance baru atau memberi key unik berbasis lokal
  // pada setiap halaman tab, tapi coba dulu dengan perubahan di atas.
  /*
  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _buildWidgetOptions(); // Panggil sekali di awal
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Dipanggil ketika InheritedWidget yang di-depend (seperti dari flutter_translate) berubah
    // Ini bisa jadi tempat untuk membangun ulang _widgetOptions jika diperlukan key berbasis lokal
    // print("MyHomePage didChangeDependencies called, locale: ${LocalizedApp.of(context).delegate.currentLocale}");
    // _buildWidgetOptions(); // Anda mungkin perlu memanggil setState jika _widgetOptions diubah di sini
                             // agar build method terpanggil lagi.
  }

  void _buildWidgetOptions() {
    // String localeKey = LocalizedApp.of(context).delegate.currentLocale.toString();
    _widgetOptions = <Widget>[
      const HomeScreenContent(), // Atau dengan key: HomeScreenContent(key: ValueKey('home_$localeKey')),
      const BookCollectionsScreen(), // BookCollectionsScreen(key: ValueKey('books_$localeKey')),
      const ProfileScreen(),       // ProfileScreen(key: ValueKey('profile_$localeKey')),
    ];
  }
  */

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Tambahkan print untuk debug
    // print("MyHomePage rebuilt, current locale: ${LocalizedApp.of(context).delegate.currentLocale}");

    PreferredSizeWidget? appBar;
    if (_selectedIndex == 0) {
      appBar = const HomeTopBar();
    } else if (_selectedIndex == 1) {
      appBar = null;
    } else if (_selectedIndex == 2) {
      appBar = null;
    }

    return Scaffold(
      appBar: appBar,
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions, // Menggunakan _widgetOptions yang sudah jadi instance variable
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        // iconSize: 28.0, // Sudah ada default di CustomBottomNavBar
      ),
    );
  }
}