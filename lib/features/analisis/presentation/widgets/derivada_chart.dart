import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../data/models/analisis_model.dart';
import 'variable_selector.dart';

/// Gráfica de línea de la derivada (dy/dt) — mismo estilo que AreaChartSection
class DerivadaChart extends StatefulWidget {
  final List<PuntoDerivada> derivada;
  final List<PuntoCritico> puntosCriticos;
  final String variable;

  const DerivadaChart({
    super.key,
    required this.derivada,
    required this.puntosCriticos,
    required this.variable,
  });

  @override
  State<DerivadaChart> createState() => _DerivadaChartState();
}

class _DerivadaChartState extends State<DerivadaChart> {
  int _touchedIdx = -1;

  @override
  Widget build(BuildContext context) {
    final cfg = configFor(widget.variable);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 10, height: 10,
                decoration: BoxDecoration(color: cfg.color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                'Razón de Cambio dy/dt — ${cfg.label} (${cfg.unit}/hora)',
                style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Leyenda puntos críticos
          Row(
            children: const [
              _LegendDot(color: Color(0xFF27AE60), label: 'Mín local'),
              SizedBox(width: 12),
              _LegendDot(color: Color(0xFFE74C3C), label: 'Máx local'),
              SizedBox(width: 12),
              _LegendDot(color: Color(0xFFF39C12), label: 'Inflexión'),
            ],
          ),
          const SizedBox(height: 16),

          if (widget.derivada.isEmpty)
            const SizedBox(
              height: 180,
              child: Center(
                child: Text('Sin datos', style: TextStyle(color: AppColors.textMuted)),
              ),
            )
          else
            SizedBox(height: 220, child: _buildChart(cfg)),
        ],
      ),
    );
  }

  Widget _buildChart(VariableConfig cfg) {
    final pts = widget.derivada;
    final spots = pts.asMap().entries.map((e) {
      final dy = e.value.dyDt ?? 0.0;
      return FlSpot(e.key.toDouble(), dy);
    }).toList();

    // Línea cero para referencia
    final zeroSpots = [FlSpot(0, 0), FlSpot((pts.length - 1).toDouble(), 0)];

    // Marcar puntos críticos
    final criticos = {
      for (final pc in widget.puntosCriticos)
        pts.indexWhere((p) => p.datetime == pc.datetime || 
            (p.datetime.difference(pc.datetime).inMinutes.abs() < 8)): pc,
    };

    final vals = spots.map((s) => s.y).toList();
    final minY = vals.isEmpty ? -1.0 : vals.reduce((a, b) => a < b ? a : b);
    final maxY = vals.isEmpty ?  1.0 : vals.reduce((a, b) => a > b ? a : b);
    final pad  = ((maxY - minY) * 0.2).clamp(0.1, double.infinity);

    return LineChart(
      LineChartData(
        minY: minY - pad,
        maxY: maxY + pad,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: Color(0xFFEEF0F3), strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 48,
              getTitlesWidget: (v, _) => Text(
                v.toStringAsFixed(2),
                style: const TextStyle(fontSize: 9, color: AppColors.textMuted),
              ),
            ),
          ),
          rightTitles:  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: (pts.length / 5).ceilToDouble(),
              getTitlesWidget: (v, _) {
                final i = v.toInt();
                if (i < 0 || i >= pts.length) return const SizedBox.shrink();
                return Text(
                  DateFormat('HH:mm').format(pts[i].datetime),
                  style: const TextStyle(fontSize: 9, color: AppColors.textMuted),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          enabled: true,
          touchCallback: (_, r) => setState(() {
            _touchedIdx = r?.lineBarSpots?.first.x.toInt() ?? -1;
          }),
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.textPrimary,
            tooltipRoundedRadius: 10,
            getTooltipItems: (spots) => spots.map((s) {
              if (s.barIndex == 1) return null; // línea cero
              final i = s.x.toInt();
              if (i < 0 || i >= pts.length) return null;
              final pt = pts[i];
              return LineTooltipItem(
                '${DateFormat('HH:mm').format(pt.datetime)}\n'
                'dy/dt: ${(pt.dyDt ?? 0).toStringAsFixed(3)} ${cfg.unit}/h',
                const TextStyle(fontSize: 11, color: Colors.white, height: 1.5),
              );
            }).toList(),
          ),
        ),
        lineBarsData: [
          // Derivada
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: cfg.color,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              checkToShowDot: (spot, _) {
                final i = spot.x.toInt();
                return i == _touchedIdx || criticos.containsKey(i);
              },
              getDotPainter: (spot, _, __, ___) {
                final i = spot.x.toInt();
                final pc = criticos[i];
                if (pc != null) {
                  final c = pc.tipo == 'minimo_local'
                      ? const Color(0xFF27AE60)
                      : pc.tipo == 'maximo_local'
                          ? const Color(0xFFE74C3C)
                          : const Color(0xFFF39C12);
                  return FlDotCirclePainter(
                    radius: 5, color: c,
                    strokeWidth: 2, strokeColor: Colors.white,
                  );
                }
                return FlDotCirclePainter(
                  radius: 4, color: cfg.color,
                  strokeWidth: 2, strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [cfg.color.withValues(alpha: 0.2), cfg.color.withValues(alpha: 0.0)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Línea cero
          LineChartBarData(
            spots: zeroSpots,
            isCurved: false,
            color: AppColors.textMuted.withValues(alpha: 0.5),
            barWidth: 1,
            dotData: const FlDotData(show: false),
            dashArray: [4, 4],
          ),
        ],
      ),
      duration: const Duration(milliseconds: 300),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      ],
    );
  }
}
