import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../atoms/metric_icon.dart';
import '../atoms/metric_value_text.dart';

/// A KPI (Key Performance Indicator) metric card molecule.
/// Contains an icon, label, current value, and min/max or optimal range.
class KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final String subtextLine1;
  final String? subtextLine2;
  final Color? iconColor;

  const KpiCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.subtextLine1,
    this.subtextLine2,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              MetricIcon(
                icon: icon,
                iconColor: iconColor ?? AppColors.primary,
                backgroundColor:
                    (iconColor ?? AppColors.primary).withValues(alpha: 0.12),
              ),
            ],
          ),
          const SizedBox(height: 10),
          MetricValueText(value: value, unit: unit, fontSize: 26),
          const SizedBox(height: 8),
          Text(
            subtextLine1,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          if (subtextLine2 != null)
            Text(
              subtextLine2!,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
                height: 1.4,
              ),
            ),
        ],
      ),
    );
  }
}
