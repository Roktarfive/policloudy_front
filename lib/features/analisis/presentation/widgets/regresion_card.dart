import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../data/models/analisis_model.dart';
import 'variable_selector.dart';

/// Tarjeta compacta con el resumen de la regresión lineal de una variable.
/// Se usa tanto en la página de análisis como en las tarjetas de tendencia del dashboard.
class RegresionCard extends StatelessWidget {
  final String variable;
  final RegresionLineal reg;

  const RegresionCard({
    super.key,
    required this.variable,
    required this.reg,
  });

  @override
  Widget build(BuildContext context) {
    final cfg = configFor(variable);
    final tendencia = reg.tendencia ?? 'estable';

    return Container(
      padding: const EdgeInsets.all(16),
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
          // Header — icono + nombre variable
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: cfg.color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(cfg.icon, size: 16, color: cfg.color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  cfg.label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              _TendenciaBadge(tendencia: tendencia),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(color: Color(0xFFEEF0F3), height: 1),
          const SizedBox(height: 12),

          // Métricas en 2 columnas
          Row(
            children: [
              Expanded(child: _Stat(label: 'Pendiente', value: _fmtPendiente(reg.pendiente, cfg.unit))),
              Expanded(child: _Stat(label: 'R²', value: _fmtR2(reg.rCuadrado))),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _Stat(label: 'Predicción +1h', value: _fmtPred(reg.prediccionProximaHora, cfg.unit))),
              Expanded(child: _Stat(label: 'Ajuste', value: _ajusteLabel(reg.rCuadrado))),
            ],
          ),

          if (reg.ecuacion != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                reg.ecuacion!,
                style: const TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _fmtPendiente(double? v, String unit) {
    if (v == null) return '--';
    final sign = v >= 0 ? '+' : '';
    return '$sign${v.toStringAsFixed(3)} $unit/h';
  }

  String _fmtR2(double? v) => v != null ? '${(v * 100).toStringAsFixed(1)}%' : '--';

  String _fmtPred(double? v, String unit) =>
      v != null ? '${v.toStringAsFixed(2)} $unit' : '--';

  String _ajusteLabel(double? r2) {
    if (r2 == null) return '--';
    if (r2 >= 0.9) return 'Excelente';
    if (r2 >= 0.7) return 'Bueno';
    if (r2 >= 0.5) return 'Moderado';
    return 'Débil';
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.textMuted,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _TendenciaBadge extends StatelessWidget {
  final String tendencia;

  const _TendenciaBadge({required this.tendencia});

  @override
  Widget build(BuildContext context) {
    final (color, icon, label) = switch (tendencia) {
      'creciente'   => (AppColors.success,  Icons.trending_up,   'Sube'),
      'decreciente' => (AppColors.error,    Icons.trending_down, 'Baja'),
      _             => (AppColors.textMuted, Icons.trending_flat, 'Estable'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
