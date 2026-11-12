import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/datasources/analisis_datasource.dart';
import '../data/models/analisis_model.dart';

part 'analisis_event.dart';
part 'analisis_state.dart';

class AnalisisBloc extends Bloc<AnalisisEvent, AnalisisState> {
  final AnalisisDatasource _ds;

  AnalisisBloc(this._ds) : super(const AnalisisInitial()) {
    on<FetchAnalisisVariable>(_onFetchVariable);
    on<FetchRegresionAll>(_onFetchRegresion);
    on<ChangeAnalisisVariable>(_onChangeVariable);
    on<ResetAnalisis>(_onReset);
  }

  Future<void> _onFetchVariable(
    FetchAnalisisVariable event,
    Emitter<AnalisisState> emit,
  ) async {
    emit(AnalisisLoading(
      variable: event.variable,
      fechaInicio: event.fechaInicio,
      fechaFin: event.fechaFin,
    ));
    try {
      final resultado = await _ds.fetchAnalisisVariable(
        variable:    event.variable,
        fechaInicio: event.fechaInicio,
        fechaFin:    event.fechaFin,
        ventana:     event.ventana,
      );
      emit(AnalisisVariableLoaded(
        resultado:   resultado,
        variable:    event.variable,
        fechaInicio: event.fechaInicio,
        fechaFin:    event.fechaFin,
      ));
    } catch (e) {
      emit(AnalisisError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onFetchRegresion(
    FetchRegresionAll event,
    Emitter<AnalisisState> emit,
  ) async {
    emit(AnalisisLoading(
      variable: 'all',
      fechaInicio: event.fechaInicio,
      fechaFin: event.fechaFin,
    ));
    try {
      final resultado = await _ds.fetchRegresion(
        fechaInicio: event.fechaInicio,
        fechaFin:    event.fechaFin,
      );
      emit(RegresionLoaded(resultado: resultado));
    } catch (e) {
      emit(AnalisisError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _onChangeVariable(
    ChangeAnalisisVariable event,
    Emitter<AnalisisState> emit,
  ) {
    // Lanza fetch automático al cambiar variable
    add(FetchAnalisisVariable(
      variable:    event.variable,
      fechaInicio: event.fechaInicio,
      fechaFin:    event.fechaFin,
    ));
  }

  void _onReset(ResetAnalisis event, Emitter<AnalisisState> emit) {
    emit(const AnalisisInitial());
  }
}
