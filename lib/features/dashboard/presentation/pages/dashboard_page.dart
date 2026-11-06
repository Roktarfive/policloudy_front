import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../bloc/dashboard_bloc.dart';
import '../../bloc/dashboard_event.dart';
import '../../bloc/dashboard_state.dart';
import '../../data/datasources/upload_datasource.dart';
import '../atoms/section_title.dart';
import '../molecules/date_selector.dart';
import '../organisms/area_chart_section.dart';
import '../organisms/dashboard_navbar.dart';
import '../organisms/dashboard_skeleton.dart';
import '../organisms/empty_dashboard.dart';
import '../organisms/kpi_grid.dart';
import '../organisms/stats_footer.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _uploadService = UploadDatasource();
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(FetchDashboardData(DateTime.now()));
  }

  // ── Subida real de archivo ─────────────────────────────────────────────────

  Future<void> _pickAndUpload(BuildContext context) async {
    // Abre el selector de archivos (Excel y CSV)
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls', 'csv'],
      allowMultiple: false,
      withData: true, // garantiza file.bytes en web
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;

    // Web: bytes; móvil/desktop: path — la validación la hace el datasource
    if (file.bytes == null && file.path == null) {
      _showSnack(context, 'No se pudo acceder al archivo.', isError: true);
      return;
    }

    setState(() => _uploading = true);

    // Muestra el diálogo de progreso
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const _UploadingDialog(),
      );
    }

    final uploadResult = await _uploadService.uploadFile(file);

    setState(() => _uploading = false);

    if (context.mounted) Navigator.of(context, rootNavigator: true).pop();

    if (!context.mounted) return;

    // Log para depuración — ver en consola del navegador
    debugPrint('=== UPLOAD RESULT ===');
    debugPrint('success: ${uploadResult.success}');
    debugPrint('message: ${uploadResult.message}');
    debugPrint('filasValidas: ${uploadResult.filasValidas}');
    debugPrint('fechaInicio: ${uploadResult.fechaInicio}');

    if (uploadResult.success) {
      // Muestra resumen del resultado
      _showUploadSuccessDialog(context, uploadResult);
      // Refresca el dashboard con la fecha de inicio del nuevo dataset
      final fechaStr = uploadResult.fechaInicio;
      DateTime targetDate = DateTime.now();
      if (fechaStr != null) {
        try {
          targetDate = DateTime.parse(fechaStr);
        } catch (_) {}
      }
      context.read<DashboardBloc>().add(FetchDashboardData(targetDate));
    } else {
      _showSnack(context, uploadResult.message, isError: true);
    }
  }

  void _showSnack(BuildContext context, String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor:
            isError ? AppColors.error : AppColors.primaryDark,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showUploadSuccessDialog(BuildContext ctx, UploadResult r) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_outline,
                color: AppColors.primary, size: 26),
            SizedBox(width: 8),
            Text('Archivo cargado'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(r.message,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 12),
            if (r.nombreArchivo != null)
              _InfoRow(
                  icon: Icons.insert_drive_file_outlined,
                  label: 'Archivo',
                  value: r.nombreArchivo!),
            if (r.filasTotales != null)
              _InfoRow(
                  icon: Icons.table_rows_outlined,
                  label: 'Filas totales',
                  value: '${r.filasTotales}'),
            if (r.filasValidas != null)
              _InfoRow(
                  icon: Icons.check_outlined,
                  label: 'Filas válidas',
                  value: '${r.filasValidas}'),
            if (r.filasDescartadas != null)
              _InfoRow(
                  icon: Icons.remove_circle_outline,
                  label: 'Filas descartadas',
                  value: '${r.filasDescartadas}'),
            if (r.fechaInicio != null && r.fechaFin != null)
              _InfoRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Rango',
                  value: '${r.fechaInicio} → ${r.fechaFin}'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const DashboardNavBar(),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardInitial || state is DashboardLoading) {
            return const DashboardSkeleton();
          }

          if (state is DashboardError) {
            return EmptyDashboard(
              message: state.message,
              onUploadCsv: () => _pickAndUpload(context),
              onRetry: () => context
                  .read<DashboardBloc>()
                  .add(FetchDashboardData(DateTime.now())),
            );
          }

          if (state is DashboardLoaded) {
            return _LoadedBody(
              state: state,
              onUploadExcel: () => _pickAndUpload(context),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Diálogo de progreso de subida
// ---------------------------------------------------------------------------

class _UploadingDialog extends StatelessWidget {
  const _UploadingDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(width: 20),
            Expanded(
              child: Text(
                'Subiendo archivo al servidor…',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Fila de info en el diálogo de éxito
// ---------------------------------------------------------------------------

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 15, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text('$label: ',
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Loaded body
// ---------------------------------------------------------------------------

class _LoadedBody extends StatelessWidget {
  final DashboardLoaded state;
  final VoidCallback onUploadExcel;

  const _LoadedBody(
      {required this.state, required this.onUploadExcel});

  @override
  Widget build(BuildContext context) {
    final data = state.data;
    return Center(
      child: ConstrainedBox(
        constraints:
            const BoxConstraints(maxWidth: AppConstants.maxContentWidth),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ────────────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        _PillBadge('EMA'),
                        SizedBox(height: 6),
                        SectionTitle(
                          'Estación Monitoreo Ambiental (EMA) — Campus Principal',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.end,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      DateSelector(
                        selectedDate: state.selectedDate,
                        onDateChanged: (d) => context
                            .read<DashboardBloc>()
                            .add(FetchDashboardData(d)),
                      ),
                      _OutlineButton(
                        icon: Icons.upload_outlined,
                        label: 'Importar Excel',
                        onTap: onUploadExcel,
                      ),
                      _DownloadCsvButton(date: state.selectedDate),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),
              KpiGrid(data: data),
              const SizedBox(height: 24),
              AreaChartSection(
                data: data,
                activeMetric: state.activeMetric,
                onMetricChanged: (metric) => context
                    .read<DashboardBloc>()
                    .add(ChangeChartMetric(metric)),
              ),
              const SizedBox(height: 24),
              StatsFooter(resumen: data.resumen),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Atoms locales
// ---------------------------------------------------------------------------

class _PillBadge extends StatelessWidget {
  final String label;
  const _PillBadge(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryDark,
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _OutlineButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 15),
      label: Text(label, style: const TextStyle(fontSize: 13)),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
    );
  }
}

class _DownloadCsvButton extends StatelessWidget {
  final DateTime date;
  const _DownloadCsvButton({required this.date});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        final dateStr = DateFormat('yyyy-MM-dd').format(date);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Descargando datos del $dateStr…'),
            backgroundColor: AppColors.primaryDark,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
      icon: const Icon(Icons.download_outlined, size: 15),
      label:
          const Text('Descargar CSV', style: TextStyle(fontSize: 13)),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
    );
  }
}
