import '../core/api_client.dart';
import '../models/dashboard_summary_model.dart';

class DashboardService {
  Future<DashboardSummaryModel> getSummary() async {
    final response = await ApiClient.dio.get('/dashboard/summary');

    if (response.data is Map<String, dynamic>) {
      return DashboardSummaryModel.fromJson(response.data);
    }

    return DashboardSummaryModel.empty();
  }
}