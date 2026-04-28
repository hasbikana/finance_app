import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../models/category_model.dart';

class CategoryService {
  Future<List<CategoryModel>> getCategories() async {
    try {
      final res = await ApiClient.dio.get('/categories');
      final list = res.data['data'] ?? res.data['categories'] ?? [];
      return (list as List).map((e) => CategoryModel.fromJson(e)).toList();
    } on DioException {
      rethrow;
    }
  }

  Future<void> createCategory({required String name}) async {
    await ApiClient.dio.post('/categories', data: {'name': name});
  }

  Future<void> updateCategory({required int id, required String name}) async {
    await ApiClient.dio.put('/categories/$id', data: {'name': name});
  }

  Future<void> deleteCategory({required int id}) async {
    await ApiClient.dio.delete('/categories/$id');
  }
}