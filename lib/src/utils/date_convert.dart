import 'package:intl/intl.dart';
import 'package:nover/src/utils/translation.dart'; // Impor tl()

/// Kelas helper untuk memformat data yang berhubungan dengan tanggal.
class DateFormatter {
  DateFormatter._();

  static String formatApiDate(String? isoString, {String? locale}) {
    if (isoString == null || isoString.isEmpty) return '';
    try {
      final dateTime = DateTime.parse(isoString);
      // Gunakan locale saat memformat
      return DateFormat('dd MMM yyyy', locale).format(dateTime);
    } catch (e) {
      return '';
    }
  }

  static String formatApiDateToTimeAgo(String? isoString, {String? locale}) {
    if (isoString == null || isoString.isEmpty) return '';
    try {
      final dateTime = DateTime.parse(isoString);
      final difference = DateTime.now().difference(dateTime);

      if (difference.inDays > 7) {
        return DateFormat('dd MMM yyyy', locale).format(dateTime);
      } else if (difference.inDays >= 1) {
        return tl('daysAgo', args: {'count': difference.inDays});
      } else if (difference.inHours >= 1) {
        return tl('hoursAgo', args: {'count': difference.inHours});
      } else if (difference.inMinutes >= 1) {
        return tl('minutesAgo', args: {'count': difference.inMinutes});
      } else if (difference.inSeconds >= 5) {
        return tl('secondsAgo', args: {'count': difference.inSeconds});
      } else {
        return tl('justNow');
      }
    } catch (e) {
      return '';
    }
  }
}