import 'package:equatable/equatable.dart';

// ─── Derivada ─────────────────────────────────────────────────────────────────

class PuntoDerivada extends Equatable {
  final DateTime datetime;
  final double? valor;
  final double? dyDt; // [unidad/hora]

  const PuntoDerivada({required this.datetime, this.valor, this.dyDt});

  factory PuntoDerivada.fromJson(Map<String, dynamic> j) => PuntoDerivada(
        datetime: DateTime.parse(j['datetime'] as String),
        valor:    (j['valor'] as num?)?.toDouble(),
        dyDt:     (j['dy_dt'] as num?)?.toDouble(),
      );

  @override
  List<Object?> get props => [datetime];
}

// ─── Puntos críticos ──────────────────────────────────────────────────────────

class PuntoCritico extends Equatable {
  final DateTime datetime;
  final double? valor;
  /// 'maximo_local' | 'minimo_local' | 'inflexion'
  final String tipo;
  final double? derivadaAntes;
  final double? derivadaDespues;

  const PuntoCritico({
    required this.datetime,
    this.valor,
    required this.tipo,
    this.derivadaAntes,
    this.derivadaDespues,
  });

  factory PuntoCritico.fromJson(Map<String, dynamic> j) => PuntoCritico(
        datetime:        DateTime.parse(j['datetime'] as String),
        valor:           (j['valor'] as num?)?.toDouble(),
        tipo:            j['tipo'] as String,
        derivadaAntes:   (j['derivada_antes'] as num?)?.toDouble(),
        derivadaDespues: (j['derivada_despues'] as num?)?.toDouble(),
      );

  @override
  List<Object?> get props => [datetime, tipo];
}

// ─── Extremos ─────────────────────────────────────────────────────────────────

class ExtremoPoint extends Equatable {
  final DateTime datetime;
  final double? valor;

  const ExtremoPoint({required this.datetime, this.valor});

  factory ExtremoPoint.fromJson(Map<String, dynamic> j) => ExtremoPoint(
        datetime: DateTime.parse(j['datetime'] as String),
        valor:    (j['valor'] as num?)?.toDouble(),
      );

  @override
  List<Object?> get props => [datetime];
}

class ExtremosResult extends Equatable {
  final ExtremoPoint? maximoGlobal;
  final ExtremoPoint? minimoGlobal;
  final List<ExtremoPoint> maximosLocales;
  final List<ExtremoPoint> minimosLocales;

  const ExtremosResult({
    this.maximoGlobal,
    this.minimoGlobal,
    this.maximosLocales = const [],
    this.minimosLocales = const [],
  });

  factory ExtremosResult.fromJson(Map<String, dynamic> j) => ExtremosResult(
        maximoGlobal: j['maximo_global'] != null
            ? ExtremoPoint.fromJson(j['maximo_global'] as Map<String, dynamic>)
            : null,
        minimoGlobal: j['minimo_global'] != null
            ? ExtremoPoint.fromJson(j['minimo_global'] as Map<String, dynamic>)
            : null,
        maximosLocales: (j['maximos_locales'] as List<dynamic>? ?? [])
            .map((e) => ExtremoPoint.fromJson(e as Map<String, dynamic>))
            .toList(),
        minimosLocales: (j['minimos_locales'] as List<dynamic>? ?? [])
            .map((e) => ExtremoPoint.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  @override
  List<Object?> get props => [maximoGlobal, minimoGlobal];
}

// ─── Regresión lineal ─────────────────────────────────────────────────────────

class RegresionLineal extends Equatable {
  final double? pendiente;       // [unidad/hora]
  final double? intercepto;
  final double? rCuadrado;       // 0–1
  final String? tendencia;       // 'creciente' | 'decreciente' | 'estable'
  final double? prediccionProximaHora;
  final String? ecuacion;

  const RegresionLineal({
    this.pendiente,
    this.intercepto,
    this.rCuadrado,
    this.tendencia,
    this.prediccionProximaHora,
    this.ecuacion,
  });

  factory RegresionLineal.fromJson(Map<String, dynamic> j) => RegresionLineal(
        pendiente:             (j['pendiente']               as num?)?.toDouble(),
        intercepto:            (j['intercepto']              as num?)?.toDouble(),
        rCuadrado:             (j['r_cuadrado']              as num?)?.toDouble(),
        tendencia:             j['tendencia']                as String?,
        prediccionProximaHora: (j['prediccion_proxima_hora'] as num?)?.toDouble(),
        ecuacion:              j['ecuacion']                 as String?,
      );

  @override
  List<Object?> get props => [pendiente, rCuadrado];
}

// ─── Análisis de una variable ─────────────────────────────────────────────────

class AnalisisVariableModel extends Equatable {
  final String variable;
  final int nRegistros;
  final List<PuntoDerivada> derivada;
  final List<PuntoCritico> puntosCriticos;
  final ExtremosResult extremos;
  final RegresionLineal regresion;

  const AnalisisVariableModel({
    required this.variable,
    required this.nRegistros,
    required this.derivada,
    required this.puntosCriticos,
    required this.extremos,
    required this.regresion,
  });

  factory AnalisisVariableModel.fromJson(Map<String, dynamic> j) =>
      AnalisisVariableModel(
        variable:       j['variable'] as String,
        nRegistros:     j['n_registros'] as int,
        derivada: (j['derivada'] as List<dynamic>)
            .map((e) => PuntoDerivada.fromJson(e as Map<String, dynamic>))
            .toList(),
        puntosCriticos: (j['puntos_criticos'] as List<dynamic>)
            .map((e) => PuntoCritico.fromJson(e as Map<String, dynamic>))
            .toList(),
        extremos:  ExtremosResult.fromJson(j['extremos'] as Map<String, dynamic>),
        regresion: RegresionLineal.fromJson(j['regresion'] as Map<String, dynamic>),
      );

  @override
  List<Object?> get props => [variable, nRegistros];
}

// ─── Regresión de todas las variables (endpoint ligero) ──────────────────────

class RegresionVariables extends Equatable {
  final String fechaInicio;
  final String fechaFin;
  final int nRegistros;
  final Map<String, RegresionLineal> variables;

  const RegresionVariables({
    required this.fechaInicio,
    required this.fechaFin,
    required this.nRegistros,
    required this.variables,
  });

  factory RegresionVariables.fromJson(Map<String, dynamic> j) {
    final vars = (j['variables'] as Map<String, dynamic>).map(
      (k, v) => MapEntry(k, RegresionLineal.fromJson(v as Map<String, dynamic>)),
    );
    return RegresionVariables(
      fechaInicio: j['fecha_inicio'] as String,
      fechaFin:    j['fecha_fin']    as String,
      nRegistros:  j['n_registros']  as int,
      variables:   vars,
    );
  }

  @override
  List<Object?> get props => [fechaInicio, fechaFin];
}
