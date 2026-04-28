import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../models/monthly_report_model.dart';

class ReportService {
  Future<MonthlyReportModel> getMonthlyReport({required int month, required int year}) async {
    try {
      final res = await ApiClient.dio.get('/reports/monthly', queryParameters: {
        'month': month,
        'year': year,
      });
      return MonthlyReportModel.fromJson(res.data);
    } on DioException {
      rethrow;
    }
  }
}