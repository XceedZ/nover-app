// lib/src/services/logout_service.dart

import 'package:flutter/material.dart';
import 'package:nover/features/auth/screens/welcome_screen.dart';
import 'package:nover/main.dart'; // Untuk mengakses authNotifier global
import 'package:nover/src/repositories/auth_repository.dart';
import 'package:nover/src/services/navigation_service.dart';

/// Sebuah layanan terpusat untuk menangani semua logika logout.
class LogoutService {
  // Constructor privat agar kelas ini tidak bisa dibuat instance-nya.
  LogoutService._();

  /// Melakukan semua langkah yang diperlukan untuk logout pengguna.
  static Future<void> perform() async {
    // Dapatkan navigator state saat ini menggunakan kunci global.
    final navigatorState = NavigationService.navigatorKey.currentState;
    if (navigatorState == null) return;

    // 1. Hapus data sesi lokal (token dan user data).
    await AuthRepository().logout();

    // 2. Perbarui state global untuk memberitahu seluruh UI bahwa pengguna sudah logout.
    authNotifier.value = null;

    // 3. Arahkan pengguna ke halaman Welcome dan hapus semua halaman sebelumnya dari tumpukan.
    // Ini mencegah pengguna menekan tombol "kembali" ke halaman yang memerlukan login.
    navigatorState.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
          (route) => false,
    );
  }
}
