import '../../data/models/dashboard_model.dart';

abstract class DashboardRepository {
  Future<DashboardData> getDailySummary(DateTime date);
}
