/// Central constants for the application
class AppConstants {
  AppConstants._();

  // API
  static const String baseUrl = 'http://localhost:8000';
  static const String resumenDiarioEndpoint = '/resumen-diario';
  static const String historicoEndpoint = '/historico';
  static const int connectTimeoutMs = 10000;
  static const int receiveTimeoutMs = 15000;

  // Layout
  static const double maxContentWidth = 1280.0;
  static const double pagePadding = 24.0;
  static const double cardBorderRadius = 16.0;
  static const double cardSpacing = 16.0;

  // Chart
  static const int chartIntervalMinutes = 15;
}
