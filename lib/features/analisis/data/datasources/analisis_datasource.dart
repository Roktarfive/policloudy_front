import 'package:dio/dio.dart';

import '../../../../core/constants/app_constants.dart';
import '../models/analisis_model.dart';

abstract class AnalisisDatasource {
  Future<AnalisisVariableModel> fetchAnalisisVariable({
    required String variable,
    String? fechaInicio,
    String? fechaFin,
    int ventana = 5,
  });

  Future<RegresionVariables> fetchRegresion({
    String? fechaInicio,
    String? fechaFin,
  });
}

class AnalisisDatasourceImpl implements AnalisisDatasource {
  final Dio _dio;

  AnalisisDatasourceImpl({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: AppConstants.baseUrl,
              connectTimeout:
                  const Duration(milliseconds: AppConstants.connectTimeoutMs),
              receiveTimeout:
                  const Duration(milliseconds: AppConstants.receiveTimeoutMs),
            ));

  @override
  Future<AnalisisVariableModel> fetchAnalisisVariable({
    required String variable,
    String? fechaInicio,
    String? fechaFin,
    int ventana = 5,
  }) async {
    try {
      final resp = await _dio.get(
        '/analisis/variable',
        queryParameters: {
          'variable': variable,
          'ventana': ventana,
          if (fechaInicio != null) 'fecha_inicio': fechaInicio,
          if (fechaFin    != null) 'fecha_fin':    fechaFin,
        },
      );
      return AnalisisVariableModel.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<RegresionVariables> fetchRegresion({
    String? fechaInicio,
    String? fechaFin,
  }) async {
    try {
      final resp = await _dio.get(
        '/analisis/regresion',
        queryParameters: {
          if (fechaInicio != null) 'fecha_inicio': fechaInicio,
          if (fechaFin    != null) 'fecha_fin':    fechaFin,
        },
      );
      return RegresionVariables.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Exception _mapError(DioException e) {
    if (e.response?.statusCode == 404) {
      return Exception('No hay datos en el rango seleccionado.');
    }
    if (e.response?.statusCode == 503) {
      return Exception('No hay dataset cargado. Sube un CSV primero.');
    }
    final detail = e.response?.data;
    if (detail is Map && detail['detail'] != null) {
      return Exception(detail['detail'].toString());
    }
    return Exception(e.message ?? 'Error de red desconocido.');
  }
}
