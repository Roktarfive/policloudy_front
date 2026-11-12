import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../bloc/analisis_bloc.dart';
import '../widgets/derivada_chart.dart';
import '../widgets/extremos_panel.dart';
import '../widgets/regresion_card.dart';
import '../widgets/variable_selector.dart';

class AnalisisPage extends StatefulWidget {
  const AnalisisPage({super.key});

  @override
  State<AnalisisPage> createState() => _AnalisisPageState();
}

class _AnalisisPageState extends State<AnalisisPage> {
  String _variable  = 'temperatura';
  DateTime _fechaInicio = DateTime.now().subtract(const Duration(days: 7));
  DateTime _fechaFin    = DateTime.now();

  static final _fmt = DateFormat('yyyy-MM-dd');
  static final _fmtDisplay = DateFormat('dd MMM yyyy', 'es');

  @override
  void initState() {
    super.initState();
    _fetchVariable();
  }

  void _fetchVariable() {
    context.read<AnalisisBloc>().add(FetchAnalisisVariable(
      variable:    _variable,
      fechaInicio: _fmt.format(_fechaInicio),
      fechaFin:    _fmt.format(_fechaFin),
    ));
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _fechaInicio : _fechaFin,
      firstDate: DateTime(2026),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _fechaInicio = picked;
        if (_fechaFin.isBefore(_fechaInicio)) _fechaFin = _fechaInicio;
      } else {
        _fechaFin = picked;
        if (_fechaInicio.isAfter(_fechaFin)) _fechaInicio = _fechaFin;
      }
    });
    _fetchVariable();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Análisis Diferencial'),
        leading: BackButton(color: AppColors.textPrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined, color: AppColors.primary),
            tooltip: 'Actualizar',
            onPressed: _fetchVariable,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppConstants.maxContentWidth),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ────────────────────────────────────────────
                _HeaderRow(
                  fechaInicio: _fechaInicio,
                  fechaFin:    _fechaFin,
                  fmtDisplay:  _fmtDisplay,
                  onPickStart: () => _pickDate(true),
                  onPickEnd:   () => _pickDate(false),
                ),
                const SizedBox(height: 20),

                // ── Selector de variable ───────────────────────────────
                VariableSelector(
                  selected:  _variable,
                  onChanged: (v) {
                    setState(() => _variable = v);
                    _fetchVariable();
                  },
                ),
                const SizedBox(height: 20),

                // ── Contenido según estado ─────────────────────────────
                BlocBuilder<AnalisisBloc, AnalisisState>(
                  builder: (context, state) {
                    if (state is AnalisisLoading) {
                      return const _LoadingBody();
                    }
                    if (state is AnalisisError) {
                      return _ErrorBody(message: state.message, onRetry: _fetchVariable);
                    }
                    if (state is AnalisisVariableLoaded) {
                      return _LoadedBody(state: state);
                    }
                    return const _EmptyBody();
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Header con selectores de fecha ──────────────────────────────────────────

class _HeaderRow extends StatelessWidget {
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final DateFormat fmtDisplay;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;

  const _HeaderRow({
    required this.fechaInicio,
    required this.fechaFin,
    required this.fmtDisplay,
    required this.onPickStart,
    required this.onPickEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'CÁLCULO',
                  style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Derivadas, Regresión y Puntos Críticos',
                style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Wrap(
          spacing: 8,
          children: [
            _DateChip(label: 'Desde', date: fmtDisplay.format(fechaInicio), onTap: onPickStart),
            _DateChip(label: 'Hasta', date: fmtDisplay.format(fechaFin),    onTap: onPickEnd),
          ],
        ),
      ],
    );
  }
}

class _DateChip extends StatelessWidget {
  final String label;
  final String date;
  final VoidCallback onTap;

  const _DateChip({required this.label, required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE0E4EA)),
          boxShadow: const [
            BoxShadow(color: AppColors.cardShadow, blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today_outlined, size: 13, color: AppColors.primary),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label,
                    style: const TextStyle(fontSize: 9, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                Text(date,
                    style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Estados del body ─────────────────────────────────────────────────────────

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(3, (_) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
          ),
        ),
      )),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBody({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}

class _EmptyBody extends StatelessWidget {
  const _EmptyBody();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Icon(Icons.functions_outlined, size: 48, color: AppColors.textMuted),
          SizedBox(height: 12),
          Text('Selecciona una variable y un rango de fechas',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }
}

class _LoadedBody extends StatelessWidget {
  final AnalisisVariableLoaded state;

  const _LoadedBody({required this.state});

  @override
  Widget build(BuildContext context) {
    final r = state.resultado;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Resumen rápido
        _SummaryBar(
          nRegistros:     r.nRegistros,
          nCriticos:      r.puntosCriticos.length,
          tendencia:      r.regresion.tendencia,
          rCuadrado:      r.regresion.rCuadrado,
        ),
        const SizedBox(height: 16),

        // Gráfica de derivada
        DerivadaChart(
          derivada:       r.derivada,
          puntosCriticos: r.puntosCriticos,
          variable:       r.variable,
        ),
        const SizedBox(height: 16),

        // Regresión lineal
        RegresionCard(variable: r.variable, reg: r.regresion),
        const SizedBox(height: 16),

        // Extremos
        ExtremosPanel(extremos: r.extremos, variable: r.variable),
      ],
    );
  }
}

// ─── Barra de resumen rápido ──────────────────────────────────────────────────

class _SummaryBar extends StatelessWidget {
  final int nRegistros;
  final int nCriticos;
  final String? tendencia;
  final double? rCuadrado;

  const _SummaryBar({
    required this.nRegistros,
    required this.nCriticos,
    required this.tendencia,
    required this.rCuadrado,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          _SumStat(
            label: 'Registros',
            value: nRegistros.toString(),
            icon: Icons.storage_outlined,
          ),
          _divider(),
          _SumStat(
            label: 'Pts. críticos',
            value: nCriticos.toString(),
            icon: Icons.scatter_plot_outlined,
          ),
          _divider(),
          _SumStat(
            label: 'Tendencia',
            value: _tendLabel(tendencia),
            icon: _tendIcon(tendencia),
            color: _tendColor(tendencia),
          ),
          _divider(),
          _SumStat(
            label: 'R²',
            value: rCuadrado != null
                ? '${(rCuadrado! * 100).toStringAsFixed(1)}%'
                : '--',
            icon: Icons.show_chart_outlined,
            color: _r2Color(rCuadrado),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        width: 1, height: 32, margin: const EdgeInsets.symmetric(horizontal: 16),
        color: const Color(0xFFEEF0F3),
      );

  String _tendLabel(String? t) => switch (t) {
        'creciente'   => '↑ Sube',
        'decreciente' => '↓ Baja',
        _             => '→ Estable',
      };

  IconData _tendIcon(String? t) => switch (t) {
        'creciente'   => Icons.trending_up,
        'decreciente' => Icons.trending_down,
        _             => Icons.trending_flat,
      };

  Color _tendColor(String? t) => switch (t) {
        'creciente'   => AppColors.success,
        'decreciente' => AppColors.error,
        _             => AppColors.textMuted,
      };

  Color _r2Color(double? r2) {
    if (r2 == null) return AppColors.textMuted;
    if (r2 >= 0.9) return AppColors.success;
    if (r2 >= 0.6) return AppColors.warning;
    return AppColors.error;
  }
}

class _SumStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const _SumStat({required this.label, required this.value, required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textPrimary;
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 14, color: c),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 10, color: AppColors.textMuted,
                      fontWeight: FontWeight.w600, letterSpacing: 0.4)),
              Text(value,
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700, color: c)),
            ],
          ),
        ],
      ),
    );
  }
}
