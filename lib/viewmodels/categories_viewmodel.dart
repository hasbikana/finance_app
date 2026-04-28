import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../services/category_service.dart';

class CategoriesViewModel extends ChangeNotifier {
  final CategoryService _service = CategoryService();
  List<CategoryModel> categories = [];
  bool isLoading = true;
  String? error;

  Future<void> loadCategories() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      categories = await _service.getCategories();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createCategory(String name) async {
    try {
      await _service.createCategory(name: name);
      await loadCategories();
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    }
  }

  Future<bool> updateCategory(int id, String name) async {
    try {
      await _service.updateCategory(id: id, name: name);
      await loadCategories();
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    }
  }

  Future<bool> deleteCategory(int id) async {
    try {
      await _service.deleteCategory(id: id);
      await loadCategories();
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    }
  }
}