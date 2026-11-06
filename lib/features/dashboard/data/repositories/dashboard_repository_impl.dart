import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';
import '../models/dashboard_model.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDatasource _datasource;

  const DashboardRepositoryImpl(this._datasource);

  @override
  Future<DashboardData> getDailySummary(DateTime date) =>
      _datasource.fetchDailySummary(date);
}
