// lib/features/settings/services/update_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:nover/src/constants/app_constants.dart';
import 'package:version/version.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:dio/dio.dart'; // <-- IMPORT BARU

class UpdateInfo {
  final Version latestVersion;
  final String downloadUrl;
  final String releaseNotes;

  UpdateInfo({
    required this.latestVersion,
    required this.downloadUrl,
    required this.releaseNotes,
  });

  factory UpdateInfo.fromJson(Map<String, dynamic> json) {
    return UpdateInfo(
      latestVersion: Version.parse(json['version']),
      downloadUrl: json['url'],
      releaseNotes: json['release_notes'],
    );
  }
}

class UpdateService {
  Future<UpdateInfo?> checkForUpdate() async {
    // ================== MULAI KODE DIAGNOSTIK ==================
    debugPrint('-------------------------------------------');
    debugPrint('--- MEMULAI PROSES CEK PEMBARUAN ---');

    if (!Platform.isAndroid) {
      debugPrint('Bukan Android, proses dibatalkan.');
      return null;
    }

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = Version.parse('${packageInfo.version}');
      debugPrint('✅ Versi Terpasang (Lokal): $currentVersion');

      final uniqueUrl = "${AppConstants.updateJsonUrl}&v=${DateTime.now().millisecondsSinceEpoch}";
      debugPrint('➡️  Mengakses URL: $uniqueUrl');

      final response = await http.get(
        Uri.parse(uniqueUrl),
        headers: {'Cache-Control': 'no-cache, must-revalidate'},
      );

      debugPrint('⬅️  Status Kode Respons Server: ${response.statusCode}');
      debugPrint('📦 Isi Respons (JSON Mentah dari Server):');
      debugPrint(response.body); // INI AKAN MENUNJUKKAN APA YANG SEBENARNYA DITERIMA APLIKASI

      if (response.statusCode == 200) {
        final updateInfo = UpdateInfo.fromJson(json.decode(response.body));
        debugPrint('✅ Versi Terbaru (Remote): ${updateInfo.latestVersion}');

        final isUpdateAvailable = updateInfo.latestVersion > currentVersion;
        debugPrint('📊 Hasil Perbandingan: ${updateInfo.latestVersion} > $currentVersion adalah $isUpdateAvailable');

        if (isUpdateAvailable) {
          debugPrint('✔️ KESIMPULAN: PEMBARUAN DITEMUKAN!');
          debugPrint('-------------------------------------------');
          return updateInfo;
        }
      }

      debugPrint('❌ KESIMPULAN: TIDAK ADA PEMBARUAN TERSEDIA.');
      debugPrint('-------------------------------------------');
      return null;
    } catch (e) {
      debugPrint('🚨 ERROR SAAT CEK PEMBARUAN: $e');
      debugPrint('-------------------------------------------');
      return null;
    }
    // ================== AKHIR KODE DIAGNOSTIK ==================
  }

  Future<void> downloadAndInstall(String url, Function(double) onProgress) async {
    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/app-update.apk';
    final dio = Dio();

    debugPrint('-------------------------------------------');
    debugPrint('--- MEMULAI PROSES DOWNLOAD ---');
    debugPrint('🔗 URL Unduhan: $url');
    debugPrint('💾 Lokasi Penyimpanan: $filePath');

    try {
      await dio.download(
        url,
        filePath,
        onReceiveProgress: (receivedBytes, totalBytes) {
          if (totalBytes != -1) {
            debugPrint('📥 Progress: $receivedBytes / $totalBytes bytes');
            onProgress(receivedBytes / totalBytes);
          } else {
            // Jika totalBytes tidak diketahui, kita tidak bisa menghitung progress
            debugPrint('📥 Menerima data: $receivedBytes bytes (total tidak diketahui)');
          }
        },
      );

      debugPrint('✅ Unduhan Selesai. File tersimpan di: $filePath');

      final file = File(filePath);
      final fileSize = await file.length();
      debugPrint('📦 Ukuran file yang diunduh: $fileSize bytes');

      if (fileSize < 1000000) { // APK Anda >80MB, jadi di bawah 1MB pasti salah
          debugPrint('🚨 PERINGATAN: Ukuran file sangat kecil! Kemungkinan ini bukan APK yang valid, melainkan halaman web error.');
      }

      await OpenFilex.open(filePath);

    } on DioException catch (e) {
      debugPrint('--- 🚨 DIO ERROR SAAT DOWNLOAD ---');
      debugPrint('Pesan Error: ${e.message}');
      debugPrint('Tipe Error: ${e.type}');
      if (e.response != null) {
        debugPrint('Status Kode Respons: ${e.response?.statusCode}');
        // Header ini SANGAT PENTING untuk kita lihat
        debugPrint('HEADER RESPONS: ${e.response?.headers}');
        debugPrint('Data Respons: ${e.response?.data}');
      }
      debugPrint('----------------------------------');
    } catch (e) {
      debugPrint('--- 🚨 ERROR UMUM SAAT DOWNLOAD ---');
      debugPrint(e.toString());
      debugPrint('----------------------------------');
    }
  }
}