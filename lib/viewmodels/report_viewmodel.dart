import 'package:flutter/material.dart';
import '../models/monthly_report_model.dart';
import '../services/report_service.dart';

class ReportViewModel extends ChangeNotifier {
  final ReportService _service = ReportService();
  MonthlyReportModel? report;
  bool isLoading = true;
  String? error;
  int month = DateTime.now().month;
  int year = DateTime.now().year;

  void setMonth(int m) {
    month = m;
    loadReport();
  }

  void setYear(int y) {
    year = y;
    loadReport();
  }

  Future<void> loadReport() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      report = await _service.getMonthlyReport(month: month, year: year);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}