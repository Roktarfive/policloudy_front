import 'package:equatable/equatable.dart';

import '../data/models/dashboard_model.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered to load (or refresh) data for a specific date
class FetchDashboardData extends DashboardEvent {
  final DateTime date;

  const FetchDashboardData(this.date);

  @override
  List<Object?> get props => [date];
}

/// Triggered when the user taps a different chart metric tab
class ChangeChartMetric extends DashboardEvent {
  final MetricType metric;

  const ChangeChartMetric(this.metric);

  @override
  List<Object?> get props => [metric];
}
