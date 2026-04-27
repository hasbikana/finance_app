import '../core/api_client.dart';
import '../models/monthly_report_model.dart';

class ReportService {
  Future<MonthlyReportModel> getMonthlyReport({
    required int month,
    required int year,
  }) async {
  final response = await ApiClient.dio.get(
    '/reports/monthly',
    queryParameters: {
      'month': month,
      'year': year,
    },
  );

    return MonthlyReportModel.fromJson(response.data);
  }

  Future<String> getExportUrl({
    required int month,
    required int year,
  }) async {
    return '${ApiClient.baseUrl}/reports/export?month=$month&year=$year';
  }
}