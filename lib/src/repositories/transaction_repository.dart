import 'package:nover/src/constants/api_constants.dart';
import 'package:nover/src/models/coin_transaction.dart';
import 'package:nover/src/services/api_service.dart';

enum TransactionType { earn, spend }

class TransactionRepository {
  final ApiService _apiService = ApiService();

  Future<List<CoinTransaction>> getTransactions(TransactionType type) async {
    final response = await _apiService.get(
      ApiConstants.getMyTransactionsEndpoint,
      queryParameters: {'type': type == TransactionType.earn ? 'earn' : 'spend'},
    );
    final List<dynamic> data = response.data;
    return data.map((json) => CoinTransaction.fromJson(json)).toList();
  }
}