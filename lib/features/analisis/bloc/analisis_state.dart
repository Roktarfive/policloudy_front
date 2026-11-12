part of 'analisis_bloc.dart';

sealed class AnalisisState extends Equatable {
  const AnalisisState();
  @override
  List<Object?> get props => [];
}

class AnalisisInitial extends AnalisisState {
  const AnalisisInitial();
}

class AnalisisLoading extends AnalisisState {
  final String variable;
  final String? fechaInicio;
  final String? fechaFin;

  const AnalisisLoading({
    required this.variable,
    this.fechaInicio,
    this.fechaFin,
  });

  @override
  List<Object?> get props => [variable];
}

class AnalisisVariableLoaded extends AnalisisState {
  final AnalisisVariableModel resultado;
  final String variable;
  final String? fechaInicio;
  final String? fechaFin;

  const AnalisisVariableLoaded({
    required this.resultado,
    required this.variable,
    this.fechaInicio,
    this.fechaFin,
  });

  @override
  List<Object?> get props => [resultado, variable];
}

class RegresionLoaded extends AnalisisState {
  final RegresionVariables resultado;

  const RegresionLoaded({required this.resultado});

  @override
  List<Object?> get props => [resultado];
}

class AnalisisError extends AnalisisState {
  final String message;

  const AnalisisError(this.message);

  @override
  List<Object?> get props => [message];
}
