import 'package:equatable/equatable.dart';

import '../data/models/dashboard_model.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  final DashboardData data;
  final MetricType activeMetric;
  final DateTime selectedDate;

  const DashboardLoaded({
    required this.data,
    required this.activeMetric,
    required this.selectedDate,
  });

  DashboardLoaded copyWith({
    DashboardData? data,
    MetricType? activeMetric,
    DateTime? selectedDate,
  }) =>
      DashboardLoaded(
        data: data ?? this.data,
        activeMetric: activeMetric ?? this.activeMetric,
        selectedDate: selectedDate ?? this.selectedDate,
      );

  @override
  List<Object?> get props => [data, activeMetric, selectedDate];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
