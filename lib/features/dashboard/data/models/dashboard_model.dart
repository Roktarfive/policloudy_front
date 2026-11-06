import 'package:equatable/equatable.dart';

// ---------------------------------------------------------------------------
// MetricType — coincide con las columnas del Excel de la estación
// ---------------------------------------------------------------------------

enum MetricType {
  temperature,   // Temp - °C
  humidity,      // Hum - %
  solarRadiation,// Rad Solar - W/m²
  windSpeed,     // Velocidad del Viento Media - m/s
  barometer,     // Barómetro - mm Hg
  uvIndex,       // Índice UV
}

extension MetricTypeLabel on MetricType {
  String get label {
    switch (this) {
      case MetricType.temperature:    return 'Temperatura (°C)';
      case MetricType.humidity:       return 'Humedad (%)';
      case MetricType.solarRadiation: return 'Radiación Solar (W/m²)';
      case MetricType.windSpeed:      return 'Velocidad Viento (m/s)';
      case MetricType.barometer:      return 'Barómetro (mm Hg)';
      case MetricType.uvIndex:        return 'Índice UV';
    }
  }

  String get unit {
    switch (this) {
      case MetricType.temperature:    return '°C';
      case MetricType.humidity:       return '%';
      case MetricType.solarRadiation: return 'W/m²';
      case MetricType.windSpeed:      return 'm/s';
      case MetricType.barometer:      return 'mm Hg';
      case MetricType.uvIndex:        return 'UV';
    }
  }
}

// ---------------------------------------------------------------------------
// EstadisticaVariable — schema del backend: { promedio, maximo, minimo, moda }
// ---------------------------------------------------------------------------

class EstadisticaVariable extends Equatable {
  final double? promedio;
  final double? maximo;
  final double? minimo;
  final double? moda;

  const EstadisticaVariable({
    this.promedio,
    this.maximo,
    this.minimo,
    this.moda,
  });

  factory EstadisticaVariable.fromJson(Map<String, dynamic> json) =>
      EstadisticaVariable(
        promedio: (json['promedio'] as num?)?.toDouble(),
        maximo:   (json['maximo']   as num?)?.toDouble(),
        minimo:   (json['minimo']   as num?)?.toDouble(),
        moda:     (json['moda']     as num?)?.toDouble(),
      );

  @override
  List<Object?> get props => [promedio, maximo, minimo, moda];
}

// ---------------------------------------------------------------------------
// ResumenDiario — ResumenDiarioResponse del backend
// ---------------------------------------------------------------------------

class ResumenDiario extends Equatable {
  final String fecha;
  final int totalRegistros;
  final EstadisticaVariable temperatura;
  final EstadisticaVariable humedad;
  final EstadisticaVariable vientoVelocidad;
  final EstadisticaVariable lluvia;
  final EstadisticaVariable radiacionSolar;
  final EstadisticaVariable indiceUv;
  final EstadisticaVariable barometro;

  const ResumenDiario({
    required this.fecha,
    required this.totalRegistros,
    required this.temperatura,
    required this.humedad,
    required this.vientoVelocidad,
    required this.lluvia,
    required this.radiacionSolar,
    required this.indiceUv,
    required this.barometro,
  });

  factory ResumenDiario.fromJson(Map<String, dynamic> json) => ResumenDiario(
        fecha:           json['fecha']           as String,
        totalRegistros:  json['total_registros'] as int,
        temperatura:     EstadisticaVariable.fromJson(json['temperatura']     as Map<String, dynamic>),
        humedad:         EstadisticaVariable.fromJson(json['humedad']         as Map<String, dynamic>),
        vientoVelocidad: EstadisticaVariable.fromJson(json['viento_velocidad'] as Map<String, dynamic>),
        lluvia:          EstadisticaVariable.fromJson(json['lluvia']          as Map<String, dynamic>),
        radiacionSolar:  EstadisticaVariable.fromJson(json['radiacion_solar'] as Map<String, dynamic>),
        indiceUv:        EstadisticaVariable.fromJson(json['indice_uv']       as Map<String, dynamic>),
        barometro:       EstadisticaVariable.fromJson(json['barometro']       as Map<String, dynamic>),
      );

  @override
  List<Object?> get props => [fecha, totalRegistros];
}

// ---------------------------------------------------------------------------
// ChartDataPoint — punto genérico de serie temporal
// ---------------------------------------------------------------------------

class ChartDataPoint extends Equatable {
  final DateTime timestamp;
  final double value;

  const ChartDataPoint({required this.timestamp, required this.value});

  @override
  List<Object?> get props => [timestamp, value];
}

// ---------------------------------------------------------------------------
// DashboardData — agregado construido por el repositorio
// ---------------------------------------------------------------------------

class DashboardData extends Equatable {
  final DateTime date;
  final ResumenDiario resumen;
  final List<ChartDataPoint> temperatureSeries;
  final List<ChartDataPoint> humiditySeries;
  final List<ChartDataPoint> solarRadiationSeries;
  final List<ChartDataPoint> windSpeedSeries;
  final List<ChartDataPoint> barometerSeries;
  final List<ChartDataPoint> uvIndexSeries;

  const DashboardData({
    required this.date,
    required this.resumen,
    required this.temperatureSeries,
    required this.humiditySeries,
    required this.solarRadiationSeries,
    required this.windSpeedSeries,
    required this.barometerSeries,
    required this.uvIndexSeries,
  });

  List<ChartDataPoint> seriesFor(MetricType metric) {
    switch (metric) {
      case MetricType.temperature:    return temperatureSeries;
      case MetricType.humidity:       return humiditySeries;
      case MetricType.solarRadiation: return solarRadiationSeries;
      case MetricType.windSpeed:      return windSpeedSeries;
      case MetricType.barometer:      return barometerSeries;
      case MetricType.uvIndex:        return uvIndexSeries;
    }
  }

  @override
  List<Object?> get props => [date, resumen];
}
