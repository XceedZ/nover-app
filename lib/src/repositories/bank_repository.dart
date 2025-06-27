// lib/src/repositories/bank_repository.dart

import 'package:dio/dio.dart';
import 'package:nover/src/constants/api_constants.dart';
import 'package:nover/src/models/bank.dart';
import 'package:nover/src/services/api_service.dart';

class BankRepository {
  final ApiService _apiService = ApiService();

  /// Mengambil daftar bank dari API.
  /// Melempar [DioException] jika terjadi error.
  Future<List<Bank>> getBankList() async {
    try {
      final response = await _apiService.get(ApiConstants.getBanksEndpoint);

      // Pastikan data yang diterima adalah list
      if (response.data['bankList'] is List) {
        // Parsing list JSON menjadi List<Bank>
        final List<dynamic> bankData = response.data['bankList'];
        return bankData.map((json) => Bank.fromJson(json)).toList();
      } else {
        // Jika format response tidak sesuai
        throw Exception('Format response tidak valid');
      }
    } on DioException {
      // Lemparkan kembali error dari Dio untuk ditangani oleh UI
      rethrow;
    } catch (e) {
      // Tangani error lainnya
      throw Exception('Gagal memuat daftar bank: $e');
    }
  }
}