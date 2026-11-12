import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../data/models/analisis_model.dart';
import 'variable_selector.dart';

/// Panel de extremos: máximo/mínimo global + lista de extremos locales
class ExtremosPanel extends StatelessWidget {
  final ExtremosResult extremos;
  final String variable;

  const ExtremosPanel({
    super.key,
    required this.extremos,
    required this.variable,
  });

  @override
  Widget build(BuildContext context) {
    final cfg = configFor(variable);

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
          // Título
          Row(
            children: [
              Icon(Icons.analytics_outlined, size: 16, color: cfg.color),
              const SizedBox(width: 6),
              Text(
                'Puntos Críticos — ${cfg.label}',
                style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tarjetas de máximo y mínimo global
          Row(
            children: [
              Expanded(child: _GlobalCard(
                label: 'MÁXIMO GLOBAL',
                extremo: extremos.maximoGlobal,
                unit: cfg.unit,
                color: const Color(0xFFE74C3C),
                icon: Icons.arrow_upward,
              )),
              const SizedBox(width: 12),
              Expanded(child: _GlobalCard(
                label: 'MÍNIMO GLOBAL',
                extremo: extremos.minimoGlobal,
                unit: cfg.unit,
                color: const Color(0xFF3498DB),
                icon: Icons.arrow_downward,
              )),
            ],
          ),

          const SizedBox(height: 16),

          // Extremos locales
          if (extremos.maximosLocales.isNotEmpty || extremos.minimosLocales.isNotEmpty) ...[
            const Divider(color: Color(0xFFEEF0F3), height: 1),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (extremos.maximosLocales.isNotEmpty)
                  Expanded(child: _LocalList(
                    title: 'Máximos locales',
                    items: extremos.maximosLocales,
                    unit: cfg.unit,
                    color: const Color(0xFFE74C3C),
                  )),
                if (extremos.maximosLocales.isNotEmpty &&
                    extremos.minimosLocales.isNotEmpty)
                  const SizedBox(width: 12),
                if (extremos.minimosLocales.isNotEmpty)
                  Expanded(child: _LocalList(
                    title: 'Mínimos locales',
                    items: extremos.minimosLocales,
                    unit: cfg.unit,
                    color: const Color(0xFF3498DB),
                  )),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _GlobalCard extends StatelessWidget {
  final String label;
  final ExtremoPoint? extremo;
  final String unit;
  final Color color;
  final IconData icon;

  const _GlobalCard({
    required this.label,
    required this.extremo,
    required this.unit,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w700,
                  color: color, letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            extremo != null ? '${extremo!.valor?.toStringAsFixed(2) ?? '--'} $unit' : '--',
            style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w700, color: color,
            ),
          ),
          if (extremo != null) ...[
            const SizedBox(height: 4),
            Text(
              DateFormat('dd/MM HH:mm').format(extremo!.datetime),
              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

class _LocalList extends StatelessWidget {
  final String title;
  final List<ExtremoPoint> items;
  final String unit;
  final Color color;

  const _LocalList({
    required this.title,
    required this.items,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Mostrar máximo 6 por columna para no saturar la UI
    final visible = items.take(6).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.w700,
            color: color, letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 8),
        ...visible.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              Container(
                width: 6, height: 6,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  DateFormat('dd/MM HH:mm').format(e.datetime),
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ),
              Text(
                '${e.valor?.toStringAsFixed(1) ?? '--'} $unit',
                style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600, color: color,
                ),
              ),
            ],
          ),
        )),
        if (items.length > 6)
          Text(
            '+ ${items.length - 6} más',
            style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
          ),
      ],
    );
  }
}
