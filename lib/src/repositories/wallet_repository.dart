import 'package:dio/dio.dart';
import 'package:nover/src/constants/api_constants.dart';
import 'package:nover/src/models/wallet.dart';
import 'package:nover/src/services/api_service.dart';
import 'dart:developer' as developer;

class WalletRepository {
  final ApiService _apiService = ApiService();

  Future<Wallet> getMyWallet() async {
    try {
      final response = await _apiService.get(ApiConstants.getMyWalletEndpoint);
      return Wallet.fromJson(response.data);
    } on DioException {
      throw Exception('Failed to connect to the server.');
    } catch (e) {
      developer.log('Unexpected error fetching wallet: $e', name: 'WalletRepository');
      throw Exception('An unexpected error occurred.');
    }
  }
}