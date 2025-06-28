// lib/src/widgets/custom_snackbar.dart

import 'package:flutter/material.dart';
import 'package:nover/src/utils/app_fonts.dart';
import 'package:snackify/snackify.dart';
import 'package:snackify/enums/snack_enums.dart';

/// Kelas helper untuk menampilkan notifikasi Snackify yang konsisten di seluruh aplikasi.
class AppSnackbar {
  // Private constructor agar kelas ini tidak bisa di-instantiate.
  AppSnackbar._();

  /// Menampilkan notifikasi sukses.
  static void showSuccess(BuildContext context, {String? title, required String message}) {
    Snackify.show(
      context: context,
      type: SnackType.success,
      // Gunakan AppFonts dan atur warna teks menjadi putih untuk kontras
      title: title != null ? Text(title, style: AppFonts.titleMedium(color: Colors.white)?.copyWith(fontWeight: FontWeight.bold)) : null,
      subtitle: Text(message, style: AppFonts.titleSmall(color: Colors.white)),
      position: SnackPosition.top,
    );
  }

  /// Menampilkan notifikasi error.
  static void showError(BuildContext context, {String? title, required String message}) {
    Snackify.show(
      context: context,
      type: SnackType.error,
      // Gunakan AppFonts dan atur warna teks menjadi putih untuk kontras
      title: title != null ? Text(title, style: AppFonts.titleMedium(color: Colors.white)?.copyWith(fontWeight: FontWeight.bold)) : null,
      subtitle: Text(message, style: AppFonts.titleSmall(color: Colors.white), maxLines: 3, overflow: TextOverflow.ellipsis),
      position: SnackPosition.top,
      duration: const Duration(seconds: 4), // Error ditampilkan lebih lama
    );
  }
}
