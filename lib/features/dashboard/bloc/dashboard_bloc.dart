import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/dashboard_model.dart';
import '../domain/repositories/dashboard_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository _repository;

  DashboardBloc(this._repository) : super(const DashboardInitial()) {
    on<FetchDashboardData>(_onFetchDashboardData);
    on<ChangeChartMetric>(_onChangeChartMetric);
  }

  Future<void> _onFetchDashboardData(
    FetchDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());
    try {
      final data = await _repository.getDailySummary(event.date);
      emit(DashboardLoaded(
        data: data,
        activeMetric: MetricType.temperature,
        selectedDate: event.date,
      ));
    } catch (e) {
      emit(DashboardError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _onChangeChartMetric(
    ChangeChartMetric event,
    Emitter<DashboardState> emit,
  ) {
    if (state is DashboardLoaded) {
      emit((state as DashboardLoaded).copyWith(activeMetric: event.metric));
    }
  }
}
