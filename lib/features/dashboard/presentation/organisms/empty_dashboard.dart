import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';

/// Dashboard vacío — muestra el layout con opacidad baja y un banner
/// central pidiendo que se suba un Excel. Se muestra cuando el backend
/// devuelve error o no hay datos para la fecha seleccionada.
class EmptyDashboard extends StatelessWidget {
  final String? message;
  final VoidCallback onUploadCsv;
  final VoidCallback onRetry;

  const EmptyDashboard({
    super.key,
    this.message,
    required this.onUploadCsv,
    required this.onRetry,
  });

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
              // ── Banner de subida CSV ───────────────────────────────────
              _UploadBanner(onUploadCsv: onUploadCsv),

              const SizedBox(height: 20),

              // ── 6 KPI cards vacías ─────────────────────────────────────
              _EmptyGrid(),

              const SizedBox(height: 24),

              // ── Gráfico vacío ──────────────────────────────────────────
              _EmptyCard(
                height: 320,
                label: 'No se han encontrado datos registrados',
                icon: Icons.show_chart_rounded,
              ),

              const SizedBox(height: 24),

              // ── Footer vacío ───────────────────────────────────────────
              _EmptyCard(
                height: 110,
                label: 'No se han encontrado datos registrados',
                icon: Icons.analytics_outlined,
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Banner de subida
// ---------------------------------------------------------------------------

class _UploadBanner extends StatelessWidget {
  final VoidCallback onUploadCsv;

  const _UploadBanner({required this.onUploadCsv});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.30),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.upload_file_outlined,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Sin datos cargados',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Sube un archivo Excel para comenzar a visualizar los datos ambientales.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          ElevatedButton.icon(
            onPressed: onUploadCsv,
            icon: const Icon(Icons.upload_outlined, size: 15),
            label: const Text('Cargar Excel'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              textStyle: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Grid de 6 cards vacías
// ---------------------------------------------------------------------------

class _EmptyGrid extends StatelessWidget {
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
        itemBuilder: (_, __) => const _EmptyKpiCard(),
      );
    });
  }
}

class _EmptyKpiCard extends StatelessWidget {
  const _EmptyKpiCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart_outlined,
              size: 28,
              color: AppColors.textSecondary.withValues(alpha: 0.5)),
          const SizedBox(height: 8),
          const Text(
            'No se han encontrado\ndatos registrados',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tarjeta genérica vacía (chart / footer)
// ---------------------------------------------------------------------------

class _EmptyCard extends StatelessWidget {
  final double height;
  final String label;
  final IconData icon;

  const _EmptyCard({
    required this.height,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,
              size: 36,
              color: AppColors.textSecondary.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
