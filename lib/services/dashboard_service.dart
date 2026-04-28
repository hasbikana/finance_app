import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../models/dashboard_summary_model.dart';

class DashboardService {
  Future<DashboardSummaryModel> getSummary() async {
    try {
      final res = await ApiClient.dio.get('/dashboard/summary');
      return DashboardSummaryModel.fromJson(res.data);
    } on DioException {
      rethrow;
    }
  }
}