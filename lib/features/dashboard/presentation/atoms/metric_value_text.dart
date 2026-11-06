import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Large bold numeric value used inside KPI cards
class MetricValueText extends StatelessWidget {
  final String value;
  final String unit;
  final double fontSize;

  const MetricValueText({
    super.key,
    required this.value,
    required this.unit,
    this.fontSize = 28,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.1,
            ),
          ),
          TextSpan(
            text: ' $unit',
            style: TextStyle(
              fontSize: fontSize * 0.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
