import '../core/api_client.dart';
import '../models/category_model.dart';

class CategoryService {
  Future<List<CategoryModel>> getCategories() async {
    final response = await ApiClient.dio.get('/categories');

    final raw = response.data;

    dynamic data;

    if (raw is Map<String, dynamic>) {
      data = raw['data'] ?? raw['categories'] ?? raw['result'];
    } else {
      data = raw;
    }

    if (data is List) {
      return data.map((item) {
        return CategoryModel.fromJson(Map<String, dynamic>.from(item));
      }).toList();
    }

    return [];
  }

  Future<void> createCategory({
    required String name,
  }) async {
    await ApiClient.dio.post(
      '/categories',
      data: {'name': name},
    );
  }

  Future<void> updateCategory({
    required int id,
    required String name,
  }) async {
    await ApiClient.dio.put(
      '/categories/$id',
      data: {'name': name},
    );
  }

  Future<void> deleteCategory({
    required int id,
  }) async {
    await ApiClient.dio.delete('/categories/$id');
  }
}