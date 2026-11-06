import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/dashboard_model.dart';

/// A horizontal row of tab buttons to switch the chart metric
class ChartTabBar extends StatelessWidget {
  final MetricType activeMetric;
  final ValueChanged<MetricType> onMetricChanged;

  const ChartTabBar({
    super.key,
    required this.activeMetric,
    required this.onMetricChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: MetricType.values
            .map((metric) => _TabButton(
                  label: metric.label,
                  isActive: metric == activeMetric,
                  onTap: () => onMetricChanged(metric),
                ))
            .toList(),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                isActive ? AppColors.primary : AppColors.textMuted.withValues(alpha: 0.4),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
