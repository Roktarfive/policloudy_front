part of 'analisis_bloc.dart';

sealed class AnalisisEvent extends Equatable {
  const AnalisisEvent();
  @override
  List<Object?> get props => [];
}

class FetchAnalisisVariable extends AnalisisEvent {
  final String variable;
  final String? fechaInicio;
  final String? fechaFin;
  final int ventana;

  const FetchAnalisisVariable({
    required this.variable,
    this.fechaInicio,
    this.fechaFin,
    this.ventana = 5,
  });

  @override
  List<Object?> get props => [variable, fechaInicio, fechaFin];
}

class FetchRegresionAll extends AnalisisEvent {
  final String? fechaInicio;
  final String? fechaFin;

  const FetchRegresionAll({this.fechaInicio, this.fechaFin});

  @override
  List<Object?> get props => [fechaInicio, fechaFin];
}

class ChangeAnalisisVariable extends AnalisisEvent {
  final String variable;
  final String? fechaInicio;
  final String? fechaFin;

  const ChangeAnalisisVariable({
    required this.variable,
    this.fechaInicio,
    this.fechaFin,
  });

  @override
  List<Object?> get props => [variable];
}

class ResetAnalisis extends AnalisisEvent {
  const ResetAnalisis();
}
