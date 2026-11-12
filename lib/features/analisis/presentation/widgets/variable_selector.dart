import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';

/// Configuración de cada variable analizable
class VariableConfig {
  final String key;
  final String label;
  final String unit;
  final Color color;
  final IconData icon;

  const VariableConfig({
    required this.key,
    required this.label,
    required this.unit,
    required this.color,
    required this.icon,
  });
}

const kVariables = <VariableConfig>[
  VariableConfig(key: 'temperatura',    label: 'Temperatura',   unit: '°C',    color: Color(0xFFE67E22), icon: Icons.thermostat_outlined),
  VariableConfig(key: 'humedad',        label: 'Humedad',       unit: '%',     color: Color(0xFF3498DB), icon: Icons.water_drop_outlined),
  VariableConfig(key: 'barometro',      label: 'Barómetro',     unit: 'mmHg',  color: Color(0xFF9B59B6), icon: Icons.speed_outlined),
  VariableConfig(key: 'viento_velocidad', label: 'Viento',      unit: 'm/s',   color: Color(0xFF1ABC9C), icon: Icons.air_outlined),
  VariableConfig(key: 'lluvia',         label: 'Lluvia',        unit: 'mm',    color: Color(0xFF2980B9), icon: Icons.water_outlined),
  VariableConfig(key: 'radiacion_solar',label: 'Radiación',     unit: 'W/m²',  color: Color(0xFFF1C40F), icon: Icons.wb_sunny_outlined),
  VariableConfig(key: 'indice_uv',      label: 'Índice UV',     unit: 'UV',    color: Color(0xFFE74C3C), icon: Icons.light_mode_outlined),
  VariableConfig(key: 'indice_calor',   label: 'Índice Calor',  unit: '°C',    color: Color(0xFFE74C3C), icon: Icons.local_fire_department_outlined),
  VariableConfig(key: 'dosis_uv',       label: 'Dosis UV',      unit: 'MEDs',  color: Color(0xFFE91E63), icon: Icons.flash_on_outlined),
];

VariableConfig configFor(String key) =>
    kVariables.firstWhere((v) => v.key == key,
        orElse: () => const VariableConfig(
              key: 'unknown', label: 'Desconocida', unit: '',
              color: AppColors.textMuted, icon: Icons.help_outline,
            ));

/// Selector horizontal de variable — mismo estilo que ChartTabBar del dashboard
class VariableSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const VariableSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: kVariables.map((v) {
          final isActive = v.key == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onChanged(v.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? v.color : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive
                        ? v.color
                        : AppColors.textMuted.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(v.icon,
                        size: 13,
                        color: isActive ? Colors.white : AppColors.textSecondary),
                    const SizedBox(width: 5),
                    Text(
                      v.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isActive ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
