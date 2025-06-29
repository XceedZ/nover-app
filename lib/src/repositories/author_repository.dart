// lib/src/repositories/author_repository.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:nover/src/constants/api_constants.dart';
import 'package:nover/src/constants/constants.dart';
import 'package:nover/src/models/book.dart';
import 'package:nover/src/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nover/src/utils/translation.dart';
import 'dart:developer' as developer;

class AuthorRepository {
  final ApiService _apiService = ApiService();

  /// Mengirim permintaan untuk menjadi penulis.
  Future<void> requestAuthorStatus({
    required String accountNumber,
    required int bankId,
    required String instagram,
    required String penName,
    required String phone,
  }) async {
    final requestBody = {
      "accountNumber": accountNumber,
      "bankId": bankId,
      "instagram": instagram,
      "penName": penName,
      "phone": phone,
    };

    try {
      await _apiService.post(
        ApiConstants.requestAuthorEndpoint,
        data: requestBody,
      );
    } on DioException catch (e) {
      developer.log('DioException saat mengirim permintaan penulis: ${e.response?.data}', error: e, name: 'AuthorRepository');
      if (e.response?.data != null && e.response!.data is Map) {
        final errorCode = e.response!.data['code'];
        if (errorCode != null && errorCode is String) {
          throw te(errorCode);
        }
      }
      throw te('unknownApi');
    } catch (e) {
      developer.log('Error tak terduga saat mengirim permintaan penulis', error: e, name: 'AuthorRepository');
      throw te('unexpected');
    }
  }

  /// Memaksa refresh status penulis dari API dan memperbarui data lokal.
  Future<Map<String, dynamic>> checkAndRefreshAuthorStatus() async {
    try {
      final response = await _apiService.get(ApiConstants.getAuthorStatusEndpoint);
      if (response.statusCode == 200 && response.data != null) {
        final bool isAuthor = response.data['isAuthor'] ?? false;
        final dynamic user = response.data['user'];

        if (isAuthor && user != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(userSessionKey, jsonEncode(user));
        }
        return response.data as Map<String, dynamic>;
      } else {
        throw te('unknownApi');
      }
    } on DioException catch (e) {
      developer.log('DioException saat cek status penulis: ${e.message}', name: 'AuthorRepository');
      rethrow;
    } catch (e) {
      developer.log('Error tak terduga saat cek status penulis: $e', name: 'AuthorRepository');
      throw te('unexpected');
    }
  }

  /// Mendapatkan status penulis dengan logika caching.
  /// Cek data lokal dulu, baru panggil API jika perlu.
  Future<Map<String, dynamic>> getAuthorStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(userSessionKey);

    if (userDataString != null) {
      final userData = jsonDecode(userDataString) as Map<String, dynamic>;
      // Asumsi API mengembalikan flgAuthor dengan nilai 'Y'. Sesuaikan jika berbeda.
      if (userData['flgAuthor'] == 'Y') {
        developer.log('Author status ditemukan di cache lokal.', name: 'AuthorRepository');
        return {
          "isAuthor": true,
          "user": userData,
        };
      }
    }

    developer.log('Author status tidak ada di cache. Memanggil API.', name: 'AuthorRepository');
    return checkAndRefreshAuthorStatus();
  }

  /// Mengambil daftar buku yang ditulis oleh pengguna yang sedang login.
  Future<List<Book>> getMyBooks() async {
    try {
      final response = await _apiService.get(ApiConstants.getMyBooksEndpoint);

      if (response.statusCode == 200 && response.data['bookList'] is List) {
        final List<dynamic> bookData = response.data['bookList'];
        return bookData.map((json) => Book.fromJson(json)).toList();
      } else {
        throw Exception('Format response tidak valid saat memuat buku.');
      }
    } on DioException catch (e) {
      developer.log('DioException saat mengambil buku penulis: ${e.message}', name: 'AuthorRepository');
      rethrow;
    } catch (e) {
      developer.log('Error tak terduga saat mengambil buku penulis: $e', name: 'AuthorRepository');
      throw Exception('Gagal memuat daftar buku.');
    }
  }
}
