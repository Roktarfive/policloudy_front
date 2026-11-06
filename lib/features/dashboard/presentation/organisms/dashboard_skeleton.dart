import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../molecules/skeleton_box.dart';

/// Full skeleton layout that mirrors the dashboard structure
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints:
            const BoxConstraints(maxWidth: AppConstants.maxContentWidth),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header skeleton ────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        SkeletonBox(width: 60, height: 22, borderRadius: 20),
                        SizedBox(height: 8),
                        SkeletonBox.wide(height: 28, borderRadius: 6),
                        SizedBox(height: 6),
                        SkeletonBox(width: 200, height: 18, borderRadius: 6),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: const [
                      SkeletonBox(width: 160, height: 36, borderRadius: 10),
                      SizedBox(height: 10),
                      SkeletonBox(width: 130, height: 36, borderRadius: 10),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── KPI cards skeleton ─────────────────────────────────────
              _SkeletonGrid(),

              const SizedBox(height: 24),

              // ── Chart skeleton ─────────────────────────────────────────
              _SkeletonCard(height: 320),

              const SizedBox(height: 24),

              // ── Footer skeleton ────────────────────────────────────────
              _SkeletonCard(height: 100),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkeletonGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final columns = constraints.maxWidth > 900
          ? 6
          : constraints.maxWidth > 600
              ? 3
              : 2;
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.15,
        ),
        itemCount: 6,
        itemBuilder: (_, __) => _SkeletonKpiCard(),
      );
    });
  }
}

class _SkeletonKpiCard extends StatelessWidget {
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
        children: const [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonBox(width: 80, height: 12),
              SkeletonBox(width: 36, height: 36, borderRadius: 18),
            ],
          ),
          SizedBox(height: 12),
          SkeletonBox(width: 90, height: 28),
          SizedBox(height: 10),
          SkeletonBox.wide(height: 11),
          SizedBox(height: 5),
          SkeletonBox(width: 100, height: 11),
        ],
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  final double height;
  const _SkeletonCard({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
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
          const SkeletonBox(width: 140, height: 14),
          const SizedBox(height: 16),
          const SkeletonBox.wide(height: 12),
          const SizedBox(height: 8),
          Expanded(
            child: const SkeletonBox.wide(height: double.infinity),
          ),
        ],
      ),
    );
  }
}
