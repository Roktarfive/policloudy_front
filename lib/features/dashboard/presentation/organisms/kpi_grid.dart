import 'package:flutter/material.dart';

import '../../data/models/dashboard_model.dart';
import '../molecules/kpi_card.dart';

/// Grid responsivo de 6 tarjetas KPI — variables del Excel de la EMA Politécnico
class KpiGrid extends StatelessWidget {
  final DashboardData data;

  const KpiGrid({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final cards = _buildCards(data.resumen);
    return LayoutBuilder(
      builder: (context, constraints) {
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
          itemCount: cards.length,
          itemBuilder: (_, i) => cards[i],
        );
      },
    );
  }

  List<Widget> _buildCards(ResumenDiario r) {
    final t    = r.temperatura;
    final h    = r.humedad;
    final w    = r.vientoVelocidad;
    final p    = r.lluvia;
    final s    = r.radiacionSolar;
    final uv   = r.indiceUv;
    final baro = r.barometro;

    return [
      // 1 ── Temperatura
      KpiCard(
        title: 'TEMPERATURA (°C)',
        value: _fmt(t.promedio),
        unit: '°C',
        icon: Icons.thermostat_outlined,
        subtextLine1: '↑ Máx: ${_fmt(t.maximo)} °C  ↓ Mín: ${_fmt(t.minimo)} °C',
        subtextLine2: 'Moda: ${_fmt(t.moda)} °C',
        iconColor: const Color(0xFFE67E22),
      ),

      // 2 ── Humedad
      KpiCard(
        title: 'HUMEDAD REL. (%)',
        value: _fmt0(h.promedio),
        unit: '%',
        icon: Icons.water_drop_outlined,
        subtextLine1: '↑ Máx: ${_fmt0(h.maximo)} %  ↓ Mín: ${_fmt0(h.minimo)} %',
        subtextLine2: 'Moda: ${_fmt0(h.moda)} %',
        iconColor: const Color(0xFF3498DB),
      ),

      // 3 ── Viento
      KpiCard(
        title: 'VIENTO (m/s)',
        value: _fmt(w.promedio),
        unit: 'm/s',
        icon: Icons.air_outlined,
        subtextLine1: _windLabel(w.promedio),
        subtextLine2: 'Pico: ${_fmt(w.maximo)} m/s',
        iconColor: const Color(0xFF9B59B6),
      ),

      // 4 ── Precipitación
      KpiCard(
        title: 'PRECIPITACIÓN (mm)',
        value: _fmt(p.promedio),
        unit: 'mm',
        icon: Icons.water_outlined,
        subtextLine1: 'Máx: ${_fmt(p.maximo)} mm',
        subtextLine2: 'Mín: ${_fmt(p.minimo)} mm',
        iconColor: const Color(0xFF1ABC9C),
      ),

      // 5 ── Radiación Solar
      KpiCard(
        title: 'RADIACIÓN SOLAR (W/m²)',
        value: _fmt0(s.promedio),
        unit: 'W/m²',
        icon: Icons.wb_sunny_outlined,
        subtextLine1: 'Pico: ${_fmt0(s.maximo)} W/m²',
        subtextLine2: 'Mín: ${_fmt0(s.minimo)} W/m²',
        iconColor: const Color(0xFFF1C40F),
      ),

      // 6 ── Índice UV
      KpiCard(
        title: 'ÍNDICE UV',
        value: _fmt(uv.promedio),
        unit: 'UV',
        icon: Icons.light_mode_outlined,
        subtextLine1: _uvLabel(uv.promedio),
        subtextLine2: 'Máx: ${_fmt(uv.maximo)} UV',
        iconColor: const Color(0xFFE74C3C),
      ),
    ];
  }

  String _fmt(double? v)  => v != null ? v.toStringAsFixed(1) : '--';
  String _fmt0(double? v) => v != null ? v.toStringAsFixed(0) : '--';

  String _windLabel(double? v) {
    if (v == null) return '--';
    if (v < 0.3)  return 'Calma';
    if (v < 1.6)  return 'Brisa muy ligera';
    if (v < 3.4)  return 'Brisa ligera';
    if (v < 5.5)  return 'Brisa leve';
    if (v < 8.0)  return 'Brisa moderada';
    return 'Viento fuerte';
  }

  String _uvLabel(double? v) {
    if (v == null) return '--';
    if (v <= 2)  return 'Exposición baja';
    if (v <= 5)  return 'Exposición moderada';
    if (v <= 7)  return 'Exposición alta';
    if (v <= 10) return 'Exposición muy alta';
    return 'Exposición extrema';
  }
}
