import 'package:flutter/material.dart';
import '../models/dashboard_summary_model.dart';
import '../services/dashboard_service.dart';

class DashboardViewModel extends ChangeNotifier {
  final DashboardService _service = DashboardService();
  DashboardSummaryModel? summary;
  bool isLoading = true;
  String? error;

  Future<void> loadSummary() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      summary = await _service.getSummary();
    } catch (e) {
      error = e.toString();
      summary = DashboardSummaryModel.empty();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}