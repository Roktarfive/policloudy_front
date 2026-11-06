import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// A single statistic block used in the footer stats row
class StatBlock extends StatelessWidget {
  final String label;
  final String value;
  final String? subtext;

  const StatBlock({
    super.key,
    required this.label,
    required this.value,
    this.subtext,
  });

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
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        if (subtext != null)
          Text(
            subtext!,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
      ],
    );
  }
}
