import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';

class TransactionsViewModel extends ChangeNotifier {
  final TransactionService _service = TransactionService();
  List<TransactionModel> transactions = [];
  bool isLoading = true;
  String? error;
  String filterType = 'all';
  String searchQuery = '';

  Future<void> loadTransactions() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      transactions = await _service.getTransactions(type: filterType, search: searchQuery);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setFilter(String type) {
    filterType = type;
    loadTransactions();
  }

  void setSearch(String query) {
    searchQuery = query;
    loadTransactions();
  }

  Future<bool> createTransaction({
    required int categoryId,
    required String type,
    required int amount,
    required String description,
    required String date,
  }) async {
    try {
      await _service.createTransaction(
        categoryId: categoryId,
        type: type,
        amount: amount,
        description: description,
        date: date,
      );
      await loadTransactions();
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    }
  }

  Future<bool> deleteTransaction(int id) async {
    try {
      await _service.deleteTransaction(id: id);
      await loadTransactions();
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    }
  }
}