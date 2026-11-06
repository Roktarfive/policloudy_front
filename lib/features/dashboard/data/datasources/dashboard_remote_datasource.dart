import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../models/dashboard_model.dart';

abstract class DashboardRemoteDatasource {
  Future<DashboardData> fetchDailySummary(DateTime date);
}

// ---------------------------------------------------------------------------
// Real — habla con el backend FastAPI
// ---------------------------------------------------------------------------

class DashboardRemoteDatasourceImpl implements DashboardRemoteDatasource {
  final Dio _dio;
  static final _fmt = DateFormat('yyyy-MM-dd');

  DashboardRemoteDatasourceImpl({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: AppConstants.baseUrl,
                connectTimeout:
                    const Duration(milliseconds: AppConstants.connectTimeoutMs),
                receiveTimeout:
                    const Duration(milliseconds: AppConstants.receiveTimeoutMs),
                headers: {'Content-Type': 'application/json'},
              ),
            );

  @override
  Future<DashboardData> fetchDailySummary(DateTime date) async {
    final fechaStr = _fmt.format(date);

    try {
      // 6 llamadas en paralelo: resumen + 5 series históricas
      final results = await Future.wait([
        _dio.get(AppConstants.resumenDiarioEndpoint,
            queryParameters: {'fecha': fechaStr}),
        _dio.get('/temperatura',
            queryParameters: {'fecha_inicio': fechaStr, 'fecha_fin': fechaStr}),
        _dio.get('/humedad',
            queryParameters: {'fecha_inicio': fechaStr, 'fecha_fin': fechaStr}),
        _dio.get('/radiacion',
            queryParameters: {'fecha_inicio': fechaStr, 'fecha_fin': fechaStr}),
        _dio.get('/viento',
            queryParameters: {'fecha_inicio': fechaStr, 'fecha_fin': fechaStr}),
        // barometro y UV vienen del endpoint /radiacion (mismo response incluye indice_uv)
        // Para barometro no hay endpoint dedicado → usamos resumen
      ]);

      final resumen = ResumenDiario.fromJson(
          results[0].data as Map<String, dynamic>);
      final tempSeries  = _parseSeries(results[1].data, 'temperatura');
      final humSeries   = _parseSeries(results[2].data, 'humedad');
      final radSeries   = _parseSeries(results[3].data, 'radiacion_solar');
      final uvSeries    = _parseSeries(results[3].data, 'indice_uv');
      final windSeries  = _parseSeries(results[4].data, 'viento_velocidad');

      // Barómetro: no tiene endpoint propio — se construye con el valor del resumen
      // como una serie plana (valor constante del promedio del día)
      final baroSeries = _buildFlatSeries(
        date: date,
        value: resumen.barometro.promedio,
        count: tempSeries.isNotEmpty ? tempSeries.length : 1,
      );

      return DashboardData(
        date: date,
        resumen: resumen,
        temperatureSeries:    tempSeries,
        humiditySeries:       humSeries,
        solarRadiationSeries: radSeries,
        windSpeedSeries:      windSeries,
        barometerSeries:      baroSeries,
        uvIndexSeries:        uvSeries,
      );
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  /// Parser genérico: extrae el campo [field] de cada registro en datos[]
  List<ChartDataPoint> _parseSeries(dynamic json, String field) {
    if (json is! Map<String, dynamic>) return [];
    final datos = json['datos'] as List<dynamic>? ?? [];
    return datos
        .map((e) {
          final map = e as Map<String, dynamic>;
          final val = (map[field] as num?)?.toDouble();
          if (val == null) return null;
          return ChartDataPoint(
            timestamp: DateTime.parse(map['datetime'] as String),
            value: val,
          );
        })
        .whereType<ChartDataPoint>()
        .toList();
  }

  /// Construye una serie plana (valor único repetido) para variables sin endpoint propio
  List<ChartDataPoint> _buildFlatSeries({
    required DateTime date,
    required double? value,
    required int count,
  }) {
    if (value == null || count == 0) return [];
    final start = DateTime(date.year, date.month, date.day);
    return List.generate(
      count,
      (i) => ChartDataPoint(
        timestamp: start.add(Duration(minutes: 15 * i)),
        value: value,
      ),
    );
  }

  Exception _mapDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return Exception('Tiempo de espera agotado. Revisa tu conexión.');
    }
    final detail = e.response?.data;
    if (detail is Map && detail['detail'] != null) {
      return Exception(detail['detail'].toString());
    }
    if (e.response?.statusCode == 404) {
      return Exception('No hay datos para la fecha seleccionada.');
    }
    if (e.response?.statusCode != null && e.response!.statusCode! >= 500) {
      return Exception('Error en el servidor. Intenta más tarde.');
    }
    return Exception(e.message ?? 'Error de red desconocido.');
  }
}

// ---------------------------------------------------------------------------
// Mock — datos basados en el Excel real (10/7/28, estación Politécnico)
// ---------------------------------------------------------------------------

class DashboardMockDatasource implements DashboardRemoteDatasource {
  @override
  Future<DashboardData> fetchDailySummary(DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _buildMock(date);
  }

  DashboardData _buildMock(DateTime date) {
    // Valores extraídos del Excel de la estación EMA Politécnico
    const temp  = EstadisticaVariable(promedio: 12.8, maximo: 18.3, minimo: 10.3, moda: 11.9);
    const hum   = EstadisticaVariable(promedio: 80.0, maximo: 94.0, minimo: 65.0, moda: 85.0);
    const wind  = EstadisticaVariable(promedio: 0.0,  maximo: 0.4,  minimo: 0.0,  moda: 0.0);
    const rain  = EstadisticaVariable(promedio: 0.0,  maximo: 0.0,  minimo: 0.0,  moda: 0.0);
    const rad   = EstadisticaVariable(promedio: 52.0, maximo: 334.0,minimo: 0.0,  moda: 0.0);
    const uv    = EstadisticaVariable(promedio: 0.5,  maximo: 3.8,  minimo: 0.0,  moda: 0.0);
    const baro  = EstadisticaVariable(promedio: 795.2,maximo: 796.2,minimo: 794.1,moda: 795.5);

    final resumen = ResumenDiario(
      fecha:           date.toIso8601String().substring(0, 10),
      totalRegistros:  96,
      temperatura:     temp,
      humedad:         hum,
      vientoVelocidad: wind,
      lluvia:          rain,
      radiacionSolar:  rad,
      indiceUv:        uv,
      barometro:       baro,
    );

    return DashboardData(
      date:                 date,
      resumen:              resumen,
      temperatureSeries:    _tempSeries(date),
      humiditySeries:       _humSeries(date),
      solarRadiationSeries: _radSeries(date),
      windSpeedSeries:      _windSeries(date),
      barometerSeries:      _baroSeries(date),
      uvIndexSeries:        _uvSeries(date),
    );
  }

  // Series basadas en los valores del Excel (intervalo de 15 min desde medianoche)
  List<ChartDataPoint> _tempSeries(DateTime date) {
    final start = DateTime(date.year, date.month, date.day, 0);
    // 12:00 AM → 11:45 PM  (valores reales del archivo)
    const v = <double>[
      11.3, 11.1, 11.1, 11.0, 10.9, 10.8, 10.7, 10.6, 10.5, 10.4,
      10.3, 10.3, 10.4, 10.5, 10.6, 10.7, 10.9, 11.1, 11.3, 11.6,
      12.0, 12.4, 12.8, 13.2, 13.6, 14.0, 14.5, 15.0, 15.5, 15.9,
      16.3, 16.6, 16.9, 17.2, 17.5, 17.7, 17.9, 18.0, 18.2, 18.3,
      18.2, 18.0, 17.7, 17.3, 16.8, 16.2, 15.7, 15.2, 14.7, 14.3,
      13.9, 13.5, 13.2, 13.0, 12.8, 12.6, 12.4, 12.3, 12.2, 12.1,
      12.0, 11.9, 11.9, 11.8, 11.8, 11.8, 11.7, 11.7, 11.6, 11.5,
      11.4, 11.3, 11.2, 11.1, 11.0, 11.0, 10.9, 10.9, 10.8, 10.8,
      10.8, 10.8, 10.9, 10.9, 11.0, 11.0, 11.1, 11.2, 11.2, 11.3,
      11.3, 11.3, 11.3, 11.2, 11.2, 11.1,
    ];
    return _toSeries(start, v);
  }

  List<ChartDataPoint> _humSeries(DateTime date) {
    final start = DateTime(date.year, date.month, date.day, 0);
    const v = <double>[
      88, 89, 90, 91, 91, 91, 92, 92, 93, 93, 94, 94, 93, 93, 92, 91,
      90, 89, 88, 86, 84, 82, 80, 78, 76, 74, 72, 70, 68, 67, 66, 65,
      65, 65, 66, 66, 67, 68, 69, 70, 71, 72, 73, 75, 77, 79, 81, 83,
      84, 85, 86, 87, 88, 89, 89, 90, 90, 91, 91, 91, 92, 92, 92, 92,
      92, 92, 92, 92, 92, 93, 93, 93, 93, 93, 93, 93, 93, 93, 93, 93,
      93, 93, 93, 93, 93, 92, 92, 92, 91, 91, 90, 90, 89, 89, 88, 88,
    ];
    return _toSeries(start, v);
  }

  List<ChartDataPoint> _radSeries(DateTime date) {
    final start = DateTime(date.year, date.month, date.day, 0);
    const v = <double>[
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 4, 19, 45, 80, 117, 155, 195, 228, 258, 284, 304,
      318, 325, 327, 326, 320, 311, 296, 278, 256, 232, 206, 178, 150,
      122, 95, 70, 49, 31, 17, 7, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    ];
    return _toSeries(start, v);
  }

  List<ChartDataPoint> _windSeries(DateTime date) {
    final start = DateTime(date.year, date.month, date.day, 0);
    const v = <double>[
      0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
      0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
      0.1, 0.1, 0.2, 0.2, 0.2, 0.3, 0.3, 0.4, 0.3, 0.3, 0.2, 0.2,
      0.2, 0.1, 0.1, 0.1, 0.1, 0.1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
      0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
      0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
      0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
      0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
    ];
    return _toSeries(start, v);
  }

  List<ChartDataPoint> _baroSeries(DateTime date) {
    final start = DateTime(date.year, date.month, date.day, 0);
    const v = <double>[
      795.9, 795.8, 795.7, 795.6, 795.6, 795.5, 795.4, 795.3, 795.2,
      795.1, 795.0, 794.9, 794.8, 794.8, 794.7, 794.6, 794.5, 794.5,
      794.4, 794.4, 794.3, 794.3, 794.3, 794.2, 794.2, 794.2, 794.1,
      794.2, 794.2, 794.3, 794.4, 794.5, 794.6, 794.8, 795.0, 795.1,
      795.2, 795.3, 795.4, 795.5, 795.6, 795.6, 795.7, 795.7, 795.7,
      795.8, 795.8, 795.8, 795.8, 795.9, 795.9, 795.9, 796.0, 796.0,
      796.0, 796.1, 796.1, 796.1, 796.1, 796.2, 796.2, 796.2, 796.1,
      796.1, 796.1, 796.0, 796.0, 795.9, 795.9, 795.8, 795.8, 795.7,
      795.7, 795.6, 795.6, 795.6, 795.5, 795.5, 795.5, 795.4, 795.4,
      795.4, 795.4, 795.3, 795.3, 795.3, 795.3, 795.3, 795.2, 795.2,
      795.2, 795.2, 795.2, 795.2, 795.1, 795.1,
    ];
    return _toSeries(start, v);
  }

  List<ChartDataPoint> _uvSeries(DateTime date) {
    final start = DateTime(date.year, date.month, date.day, 0);
    const v = <double>[
      0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
      0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
      0.1, 0.3, 0.6, 0.9, 1.3, 1.7, 2.1, 2.5, 2.9, 3.2, 3.5, 3.7,
      3.8, 3.8, 3.7, 3.6, 3.4, 3.2, 2.9, 2.6, 2.3, 1.9, 1.6, 1.3,
      1.0, 0.7, 0.5, 0.3, 0.2, 0.1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
      0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
      0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
      0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
    ];
    return _toSeries(start, v);
  }

  List<ChartDataPoint> _toSeries(DateTime start, List<double> values) =>
      List.generate(
        values.length,
        (i) => ChartDataPoint(
          timestamp: start.add(Duration(minutes: 15 * i)),
          value: values[i],
        ),
      );
}
