import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/dashboard_model.dart';
import '../molecules/chart_tab_bar.dart';

/// Full chart section: tab bar + spline area chart with gradient fill and tooltip
class AreaChartSection extends StatefulWidget {
  final DashboardData data;
  final MetricType activeMetric;
  final ValueChanged<MetricType> onMetricChanged;

  const AreaChartSection({
    super.key,
    required this.data,
    required this.activeMetric,
    required this.onMetricChanged,
  });

  @override
  State<AreaChartSection> createState() => _AreaChartSectionState();
}

class _AreaChartSectionState extends State<AreaChartSection> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final series = widget.data.seriesFor(widget.activeMetric);
    final unit = widget.activeMetric.unit;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Interval label + tab bar
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'Intervalo 15 min',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ChartTabBar(
            activeMetric: widget.activeMetric,
            onMetricChanged: widget.onMetricChanged,
          ),
          const SizedBox(height: 20),

          // Chart
          if (series.isEmpty)
            const SizedBox(
              height: 200,
              child: Center(
                child: Text(
                  'Sin datos para el período seleccionado',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
            )
          else
            SizedBox(
              height: 220,
              child: LineChart(
                _buildChartData(series, unit),
                duration: const Duration(milliseconds: 400),
              ),
            ),
        ],
      ),
    );
  }

  LineChartData _buildChartData(
      List<ChartDataPoint> series, String unit) {
    final spots = series
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.value))
        .toList();

    final minY = series.map((p) => p.value).reduce((a, b) => a < b ? a : b);
    final maxY = series.map((p) => p.value).reduce((a, b) => a > b ? a : b);
    final padding = (maxY - minY) * 0.15;

    return LineChartData(
      minY: (minY - padding).floorToDouble(),
      maxY: (maxY + padding).ceilToDouble(),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (_) => const FlLine(
          color: Color(0xFFEEF0F3),
          strokeWidth: 1,
        ),
      ),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 42,
            getTitlesWidget: (value, meta) => Text(
              value.toStringAsFixed(0),
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            interval: (series.length / 5).ceilToDouble(),
            getTitlesWidget: (value, meta) {
              final idx = value.toInt();
              if (idx < 0 || idx >= series.length) {
                return const SizedBox.shrink();
              }
              return Text(
                DateFormat('HH:mm').format(series[idx].timestamp),
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textMuted,
                ),
              );
            },
          ),
        ),
      ),
      lineTouchData: LineTouchData(
        enabled: true,
        touchCallback: (event, response) {
          setState(() {
            _touchedIndex =
                response?.lineBarSpots?.first.x.toInt() ?? -1;
          });
        },
        getTouchLineStart: (_, __) => 0,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => AppColors.textPrimary,
          tooltipRoundedRadius: 10,
          getTooltipItems: (spots) => spots.map((spot) {
            final idx = spot.x.toInt();
            final point = series[idx];
            final timeStr =
                DateFormat('hh:mm a').format(point.timestamp).toUpperCase();

            // Find max in series
            final maxVal = series
                .map((p) => p.value)
                .reduce((a, b) => a > b ? a : b);
            final isMax = (point.value - maxVal).abs() < 0.01;

            return LineTooltipItem(
              '$timeStr\n${isMax ? "MÁXIMO DÍA " : ""}${point.value.toStringAsFixed(1)} $unit',
              const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 1.5,
              ),
            );
          }).toList(),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.35,
          color: AppColors.primary,
          barWidth: 2.5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            checkToShowDot: (spot, _) => spot.x.toInt() == _touchedIndex,
            getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
              radius: 5,
              color: AppColors.primary,
              strokeWidth: 2,
              strokeColor: Colors.white,
            ),
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: const LinearGradient(
              colors: [
                AppColors.chartFillTop,
                AppColors.chartFillBottom,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }
}
