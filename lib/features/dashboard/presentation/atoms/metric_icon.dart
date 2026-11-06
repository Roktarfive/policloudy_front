import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Circular icon container used in the corner of KPI cards
class MetricIcon extends StatelessWidget {
  final IconData icon;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;

  const MetricIcon({
    super.key,
    required this.icon,
    this.backgroundColor,
    this.iconColor,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color:
            backgroundColor ?? AppColors.primary.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: size * 0.55,
        color: iconColor ?? AppColors.primary,
      ),
    );
  }
}
