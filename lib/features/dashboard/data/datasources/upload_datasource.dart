import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';

import '../../../../core/constants/app_constants.dart';

class UploadResult {
  final bool success;
  final String message;
  final String? nombreArchivo;
  final int? filasTotales;
  final int? filasValidas;
  final int? filasDescartadas;
  final String? fechaInicio;
  final String? fechaFin;

  const UploadResult({
    required this.success,
    required this.message,
    this.nombreArchivo,
    this.filasTotales,
    this.filasValidas,
    this.filasDescartadas,
    this.fechaInicio,
    this.fechaFin,
  });
}

class UploadDatasource {
  final Dio _dio;

  UploadDatasource({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: AppConstants.baseUrl,
                connectTimeout: const Duration(
                    milliseconds: AppConstants.connectTimeoutMs),
                receiveTimeout: const Duration(seconds: 120),
              ),
            );

  /// Sube un [PlatformFile] al endpoint POST /upload-csv.
  /// Solo valida que el archivo no esté vacío; el backend se encarga del resto.
  Future<UploadResult> uploadFile(PlatformFile file) async {
    try {
      // 1. Obtener bytes del archivo
      Uint8List rawBytes;

      if (file.bytes != null) {
        rawBytes = file.bytes!;
      } else if (file.path != null) {
        rawBytes = await File(file.path!).readAsBytes();
      } else {
        return const UploadResult(
          success: false,
          message: 'No se pudo acceder al contenido del archivo.',
        );
      }

      // 2. Validar que el archivo no esté vacío
      if (rawBytes.isEmpty) {
        return const UploadResult(
          success: false,
          message: 'El archivo está vacío.',
        );
      }

      debugPrint('[Upload] Enviando "${file.name}" (${rawBytes.length} bytes)…');

      // 3. Construir multipart y enviar directamente al backend
      final multipart = MultipartFile.fromBytes(
        rawBytes,
        filename: file.name,
        contentType: MediaType('application', 'octet-stream'),
      );

      final response = await _dio.post(
        '/upload-csv',
        data: FormData.fromMap({'file': multipart}),
        options: Options(
          receiveTimeout: const Duration(seconds: 120),
          validateStatus: (status) => status != null && status < 600,
        ),
      );

      debugPrint('[Upload] status=${response.statusCode} data=${response.data}');

      if (response.statusCode != null && response.statusCode! >= 400) {
        final detail = response.data;
        String msg = 'Error al procesar el archivo (${response.statusCode}).';
        if (detail is Map) {
          final d = detail['detail'];
          if (d is String) {
            msg = d;
          } else if (d is Map) {
            if (d['error'] != null) {
              msg = d['error'].toString();
            } else if (d['detalles'] is List) {
              final detalles = (d['detalles'] as List).join('\n');
              msg = d['error']?.toString() ?? 'Error de validación:\n$detalles';
            }
          }
        }
        return UploadResult(success: false, message: msg);
      }

      final data = response.data as Map<String, dynamic>;
      return UploadResult(
        success:          true,
        message:          data['mensaje']           as String? ?? 'Archivo cargado.',
        nombreArchivo:    data['nombre_archivo']    as String?,
        filasTotales:     data['filas_totales']     as int?,
        filasValidas:     data['filas_validas']     as int?,
        filasDescartadas: data['filas_descartadas'] as int?,
        fechaInicio:      data['fecha_inicio']      as String?,
        fechaFin:         data['fecha_fin']         as String?,
      );
    } on DioException catch (e) {
      final detail = e.response?.data;
      debugPrint('[Upload] DioException type=${e.type} '
          'status=${e.response?.statusCode} detail=$detail');
      String msg = 'Error al subir el archivo.';
      if (detail is Map) {
        final d = detail['detail'];
        if (d is String) {
          msg = d;
        } else if (d is Map) {
          if (d['error'] != null) msg = d['error'].toString();
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        msg = 'Tiempo de espera agotado. Intenta de nuevo.';
      } else if (e.type == DioExceptionType.connectionError) {
        msg = 'No se pudo conectar al servidor. '
            'Verifica que el backend esté corriendo en ${AppConstants.baseUrl}.';
      }
      return UploadResult(success: false, message: msg);
    } catch (e) {
      debugPrint('[Upload] catch genérico: $e');
      return UploadResult(
          success: false, message: 'Error inesperado: ${e.toString()}');
    }
  }
}
