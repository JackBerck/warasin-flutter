import 'package:flutter/material.dart';

class DashboardStatCard extends StatelessWidget {
  final Map<String, dynamic> statistics;

  const DashboardStatCard({super.key, required this.statistics});

  @override
  Widget build(BuildContext context) {
    final avgBpSys = statistics['avgBloodPressureSystolic'] ?? 0.0;
    final avgBpDia = statistics['avgBloodPressureDiastolic'] ?? 0.0;
    final avgBs = statistics['avgBloodSugar'] ?? 0.0;

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStat(
              context,
              icon: Icons.favorite,
              label: "Avg. TDarah",
              value: avgBpSys > 0 && avgBpDia > 0
                  ? "${avgBpSys.toStringAsFixed(0)}/${avgBpDia.toStringAsFixed(0)}"
                  : "-",
              unit: "mmHg",
              color: Colors.red,
            ),
            _buildStat(
              context,
              icon: Icons.water_drop,
              label: "Avg. Gula",
              value: avgBs > 0 ? avgBs.toStringAsFixed(0) : "-",
              unit: "mg/dL",
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 26),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          unit,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade400,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}
