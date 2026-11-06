import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/dashboard_model.dart';
import '../molecules/stat_block.dart';

/// Footer con 4 bloques estadísticos derivados del ResumenDiario
class StatsFooter extends StatelessWidget {
  final ResumenDiario resumen;

  const StatsFooter({super.key, required this.resumen});

  @override
  Widget build(BuildContext context) {
    final t    = resumen.temperatura;
    final baro = resumen.barometro;

    // Rango térmico del día
    final thermalRange = (t.minimo != null && t.maximo != null)
        ? '${t.minimo!.toStringAsFixed(1)} – ${t.maximo!.toStringAsFixed(1)} °C'
        : '--';
    final gradiente = (t.minimo != null && t.maximo != null)
        ? '${(t.maximo! - t.minimo!).toStringAsFixed(1)} °C'
        : '--';

    // Integridad basada en registros esperados (96 por día a intervalos de 15 min)
    final expected = 96;
    final actual   = resumen.totalRegistros;
    final pct      = actual > 0
        ? ((actual / expected) * 100).clamp(0, 100).toStringAsFixed(0)
        : '0';
    final integrity = '$actual / $expected ($pct %)';

    // Barómetro
    final baroVal = baro.promedio != null
        ? '${baro.promedio!.toStringAsFixed(1)} mm Hg'
        : '--';
    final baroRange = (baro.minimo != null && baro.maximo != null)
        ? '${baro.minimo!.toStringAsFixed(1)} – ${baro.maximo!.toStringAsFixed(1)}'
        : '--';

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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 480;
          final blocks = [
            StatBlock(
              label: 'Media Aritmética (°C)',
              value: t.promedio != null
                  ? t.promedio!.toStringAsFixed(2)
                  : '--',
              subtext: 'Moda: ${t.moda?.toStringAsFixed(1) ?? '--'} °C',
            ),
            StatBlock(
              label: 'Desviación Estándar (σ)',
              value: _calcStdDev(t),
              subtext: 'Estimación rango / 4',
            ),
            StatBlock(
              label: 'Integridad Telemetría',
              value: integrity,
              subtext: 'Registros del día (intervalos 15 min)',
            ),
            StatBlock(
              label: 'Rango Térmico Diario',
              value: thermalRange,
              subtext: 'Gradiente: $gradiente',
            ),
          ];

          return isNarrow
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: blocks
                      .map((b) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: b,
                          ))
                      .toList(),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: blocks.map((b) => Expanded(child: b)).toList(),
                );
        },
      ),
    );
  }

  String _calcStdDev(EstadisticaVariable t) {
    if (t.maximo == null || t.minimo == null) return '--';
    return ((t.maximo! - t.minimo!) / 4.0).toStringAsFixed(2);
  }
}
