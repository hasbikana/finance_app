import '../core/api_client.dart';
import '../models/transaction_model.dart';

class TransactionService {
  Future<List<TransactionModel>> getTransactions({
    String? type,
    String? search,
  }) async {
    final response = await ApiClient.dio.get(
      '/transactions',
      queryParameters: {
        if (type != null && type != 'all') 'type': type,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );

    final raw = response.data;

    dynamic data;

    if (raw is Map<String, dynamic>) {
      data = raw['data'] ?? raw['transactions'] ?? raw['result'];

      if (data is Map<String, dynamic> && data['data'] is List) {
        data = data['data'];
      }
    } else {
      data = raw;
    }

    if (data is List) {
      return data
          .map((item) => TransactionModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    return [];
  }

  Future<void> createTransaction({
    required int categoryId,
    required String type,
    required int amount,
    required String description,
    required String date,
  }) async {
    await ApiClient.dio.post(
      '/transactions',
      data: {
        'category_id': categoryId,
        'type': type,
        'amount': amount,
        'description': description,
        'date': date,
      },
    );
  }

  Future<void> deleteTransaction({
    required int id,
  }) async {
    await ApiClient.dio.delete('/transactions/$id');
  }
}