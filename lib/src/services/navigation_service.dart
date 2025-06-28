// lib/src/services/navigation_service.dart

import 'package:flutter/material.dart';

/// Menyediakan sebuah GlobalKey untuk Navigator.
/// Ini memungkinkan navigasi dari mana saja di dalam aplikasi tanpa memerlukan BuildContext,
/// sangat penting untuk menangani aksi global seperti logout dari service atau interceptor.
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}
