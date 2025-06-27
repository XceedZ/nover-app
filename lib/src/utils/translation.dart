import 'package:flutter_translate/flutter_translate.dart';

/// Fungsi untuk label umum, otomatis menambahkan prefix 'label.'
String tl(String key, {Map<String, dynamic>? args}) {
  const String defaultPrefix = 'label.';
  final bool isFullPath = key.contains('.');
  final String finalKey = isFullPath ? key : '$defaultPrefix$key';

  return translate(finalKey, args: args);
}

// BARU: Fungsi khusus untuk menerjemahkan kode error dari API.
// Otomatis menambahkan prefix 'error.'
String te(String errorCode, {Map<String, dynamic>? args}) {
  const String errorPrefix = 'error.';
  final String finalKey = '$errorPrefix$errorCode';

  return translate(finalKey, args: args);
}