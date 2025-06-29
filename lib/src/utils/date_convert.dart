// lib/src/utils/date_convert.dart
import 'package:intl/intl.dart';

/// Kelas helper untuk memformat data yang berhubungan dengan tanggal.
class DateFormatter {
  // Private constructor agar kelas ini tidak bisa di-instantiate.
  DateFormatter._();

  /// Mengubah string tanggal ISO 8601 (contoh: "2025-06-27T03:37:47.834395Z")
  /// menjadi format "dd/MM/yyyy" (contoh: "27/06/2025").
  ///
  /// Mengembalikan string kosong jika format input tidak valid.
  static String formatApiDate(String? isoString) {
    if (isoString == null || isoString.isEmpty) {
      return '';
    }
    try {
      final dateTime = DateTime.parse(isoString);
      return DateFormat('dd/MM/yyyy').format(dateTime);
    } catch (e) {
      // Jika terjadi error parsing, kembalikan string kosong atau tanggal default
      print('Error parsing date: $isoString');
      return '';
    }
  }
}
