import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../models/transaction_model.dart';

class TransactionService {
  Future<List<TransactionModel>> getTransactions({String type = 'all', String search = ''}) async {
    try {
      final res = await ApiClient.dio.get('/transactions', queryParameters: {
        if (type != 'all') 'type': type,
        if (search.isNotEmpty) 'search': search,
      });
      final list = res.data['data'] ?? res.data['transactions'] ?? [];
      return (list as List).map((e) => TransactionModel.fromJson(e)).toList();
    } on DioException {
      rethrow;
    }
  }

  Future<void> createTransaction({
    required int categoryId,
    required String type,
    required int amount,
    required String description,
    required String date,
  }) async {
    await ApiClient.dio.post('/transactions', data: {
      'category_id': categoryId,
      'type': type,
      'amount': amount,
      'description': description,
      'date': date,
    });
  }

  Future<void> deleteTransaction({required int id}) async {
    await ApiClient.dio.delete('/transactions/$id');
  }
}