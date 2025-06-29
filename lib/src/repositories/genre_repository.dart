// lib/src/repositories/genre_repository.dart
import 'package:dio/dio.dart';
import 'package:nover/src/constants/api_constants.dart';
import 'package:nover/src/models/genre.dart'; // Import model Genre yang baru
import 'package:nover/src/services/api_service.dart';
import 'dart:developer' as developer;

class GenreRepository {
  final ApiService _apiService = ApiService();

  /// Mengambil daftar semua genre yang tersedia dari API.
  Future<List<Genre>> getGenres() async {
    try {
      final response = await _apiService.get(ApiConstants.getGenresEndpoint);

      // Memeriksa apakah response sukses dan memiliki key 'genreList' yang berupa List.
      if (response.statusCode == 200 && response.data['genreList'] is List) {
        final List<dynamic> genreData = response.data['genreList'];
        // Mengubah setiap item JSON menjadi objek Genre.
        return genreData.map((json) => Genre.fromJson(json)).toList();
      } else {
        // Melempar error jika format response tidak sesuai.
        throw Exception('Format response tidak valid untuk genres.');
      }
    } on DioException catch (e) {
      developer.log('DioException saat mengambil genres: ${e.message}', name: 'GenreRepository');
      rethrow; // Lemparkan kembali error untuk ditangani oleh UI.
    } catch (e) {
      developer.log('Error tak terduga saat mengambil genres: $e', name: 'GenreRepository');
      throw Exception('Gagal memuat daftar genre.');
    }
  }
}
