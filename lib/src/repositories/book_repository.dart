// lib/src/repositories/book_repository.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:nover/src/constants/api_constants.dart';
import 'package:nover/src/models/book.dart';
import 'package:nover/src/models/book_detail.dart'; // <-- IMPORT BARU
import 'package:nover/src/services/api_service.dart';
import 'package:nover/src/utils/translation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nover/src/models/chapter.dart'; // Pastikan import ini ada
import 'dart:developer' as developer;

class BookRepository {
  final ApiService _apiService = ApiService();
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  /// Meng-upload file gambar cover ke Supabase Storage dan mengembalikan URL publiknya.
  Future<String> _uploadCoverImageAndGetUrl(File imageFile) async {
    try {
      const bucketName = String.fromEnvironment(
          'SUPABASE_STORAGE_BUCKET',
          defaultValue: 'coverbooks'
      );

      final fileName = '${DateTime.now().millisecondsSinceEpoch}.${imageFile.path.split('.').last}';
      final filePath = 'public/$fileName';

      await _supabaseClient.storage.from(bucketName).upload(
        filePath,
        imageFile,
      );

      final imageUrl = _supabaseClient.storage
          .from(bucketName)
          .getPublicUrl(filePath);

      developer.log('Upload sukses ke bucket "$bucketName", URL: $imageUrl', name: 'BookRepository');
      return imageUrl;
    } catch (e) {
      developer.log('Gagal meng-upload gambar ke Supabase: $e', name: 'BookRepository');
      throw 'Gagal meng-upload gambar cover.';
    }
  }

  Future<void> createBook({
    required String title,
    required String description,
    required List<int> genreIds,
    required File coverImageFile,
  }) async {
    try {
      final String coverImageUrl = await _uploadCoverImageAndGetUrl(coverImageFile);

      final requestBody = {
        "title": title,
        "description": description,
        "genreIds": genreIds,
        "coverImageUrl": coverImageUrl,
      };

      await _apiService.post(ApiConstants.createBookEndpoint, data: requestBody);

    } on DioException catch (e) {
      developer.log('DioException saat membuat buku: ${e.response?.data}', error: e, name: 'BookRepository');
      if (e.response?.data != null && e.response!.data is Map) {
        final errorCode = e.response!.data['code'];
        if (errorCode != null && errorCode is String) {
          throw te(errorCode);
        }
      }
      throw te('unknownApi');
    } catch (e) {
      developer.log('Error tak terduga saat membuat buku: $e', name: 'BookRepository');
      throw te('unexpected');
    }
  }

  // --- FUNGSI BARU UNTUK UPDATE STATUS BUKU ---
  /// Mengirim request untuk mengubah status sebuah buku.
  /// [bookId] adalah ID dari buku yang akan diubah.
  /// [action] adalah string aksi ('complete', 'hold', 'publish', 'unpublish').
  /// Mengembalikan objek Book yang sudah diperbarui dari server.
  Future<void> updateBookStatus(int bookId, String action) async {
    try {
      final endpoint = ApiConstants.updateBookStatus(bookId, action);
      final response = await _apiService.patch(endpoint);

      if (response.statusCode != 200) {
        throw Exception('Server responded with status: ${response.statusCode}');
      }

    } on DioException catch (e) {
      developer.log('DioException saat update status buku: ${e.response?.data}', name: 'BookRepository');
      if (e.response?.data != null && e.response!.data is Map) {
        final errorCode = e.response!.data['code'];
        if (errorCode != null && errorCode is String) {
          throw te(errorCode);
        }
      }
      throw te('unknownApi');
    } catch (e) {
      developer.log('Error tak terduga saat update status buku: $e', name: 'BookRepository');
      throw te('unexpected');
    }
  }

  // --- FUNGSI BARU UNTUK MEMBUAT CHAPTER ---
  Future<void> createChapter({
    required int bookId,
    required String title,
    required String content,
    required int coinCost,
  }) async {
    final requestBody = {
      "title": title,
      "content": content,
      "coinCost": coinCost,
    };

    try {
      final response = await _apiService.post(
        ApiConstants.createChapter(bookId),
        data: requestBody,
      );

      // UBAH: Sekarang menerima status 201 (Created) sebagai tanda sukses.
      if (response.statusCode != 201) {
        throw Exception('Server responded with status: ${response.statusCode}');
      }
      // Jika sukses, tidak melakukan apa-apa dan tidak melempar error.

    } on DioException catch (e) {
      developer.log('DioException saat membuat chapter: ${e.response?.data}', name: 'BookRepository');
      if (e.response?.data != null && e.response!.data is Map) {
        final errorCode = e.response!.data['code'];
        if (errorCode != null && errorCode is String) {
          throw te(errorCode);
        }
      }
      throw te('unknownApi');
    } catch (e) {
      developer.log('Error tak terduga saat membuat chapter: $e', name: 'BookRepository');
      throw te('unexpected');
    }
  }

  // --- FUNGSI BARU UNTUK MENGAMBIL DETAIL BUKU SAYA(PRIBADI) ---
  Future<BookDetail> getMyBookDetail(int bookId) async {
    try {
      final endpoint = ApiConstants.getBookDetail(bookId); // Gunakan endpoint dinamis
      final response = await _apiService.get(endpoint);

      if (response.statusCode == 200 && response.data != null) {
        return BookDetail.fromJson(response.data);
      } else {
        throw Exception('Gagal memuat detail buku.');
      }
    } on DioException catch (e) {
      developer.log('DioException saat mengambil detail buku: ${e.message}', name: 'BookRepository');
      rethrow;
    } catch (e) {
      developer.log('Error tak terduga saat mengambil detail buku: $e', name: 'BookRepository');
      throw Exception('Gagal memuat detail buku.');
    }
  }

  // --- FUNGSI BARU UNTUK MENGAMBIL DETAIL BUKU UMUM ---
  Future<BookDetail> getBookDetail(int bookId) async {
    try {
      final endpoint = ApiConstants.getBookDetailPublic(bookId); // Gunakan endpoint baru
      final response = await _apiService.get(endpoint);

      if (response.statusCode == 200 && response.data != null) {
        return BookDetail.fromJson(response.data);
      } else {
        throw Exception('Gagal memuat detail buku.');
      }
    } on DioException catch (e) {
      developer.log('DioException saat mengambil detail buku: ${e.message}', name: 'BookRepository');
      throw Exception('Gagal terhubung ke server.');
    } catch (e) {
      developer.log('Error tak terduga saat mengambil detail buku: $e', name: 'BookRepository');
      throw Exception('Terjadi kesalahan tidak terduga.');
    }
  }

  // --- FUNGSI BARU UNTUK MENGAMBIL DAFTAR BUKU UMUM ---
  Future<List<Book>> getBooks({int page = 1, int limit = 10}) async {
    try {
      final response = await _apiService.get(
        ApiConstants.getBooksEndpoint,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      // Sesuaikan key 'books' dengan response API Anda yang sebenarnya
      if (response.statusCode == 200 && response.data['books'] is List) {
        final List<dynamic> bookData = response.data['books'];
        return bookData.map((json) => Book.fromJson(json)).toList();
      } else {
        throw Exception('Format response tidak valid saat memuat buku.');
      }
    } on DioException {
      rethrow;
    } catch (e) {
      developer.log('Error tak terduga saat mengambil buku: $e', name: 'BookRepository');
      throw Exception('Gagal memuat daftar buku.');
    }
  }

  /// Mengambil detail lengkap sebuah chapter, termasuk kontennya.
  Future<Chapter> getChapterDetail(int chapterId) async {
    try {
      final endpoint = ApiConstants.getChapterDetail(chapterId);
      final response = await _apiService.get(endpoint);

      // Asumsi response API adalah objek chapter tunggal
      if (response.statusCode == 200 && response.data != null) {
        return Chapter.fromJson(response.data);
      } else {
        throw Exception('Gagal memuat konten chapter.');
      }
    } on DioException catch (e) {
      developer.log('DioException saat mengambil detail chapter: ${e.message}', name: 'BookRepository');
      throw Exception('Gagal terhubung ke server.');
    } catch (e) {
      developer.log('Error tak terduga saat mengambil detail chapter: $e', name: 'BookRepository');
      throw Exception('Terjadi kesalahan tidak terduga.');
    }
  }
}