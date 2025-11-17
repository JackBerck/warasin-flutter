import 'package:flutter/material.dart';

class HealthStatisticsCard extends StatelessWidget {
  final Map<String, dynamic> statistics;

  const HealthStatisticsCard({super.key, required this.statistics});

  @override
  Widget build(BuildContext context) {
    final totalRecords = statistics['totalRecords'] ?? 0;
    final avgBpSys = statistics['avgBloodPressureSystolic'] ?? 0.0;
    final avgBpDia = statistics['avgBloodPressureDiastolic'] ?? 0.0;
    final avgBs = statistics['avgBloodSugar'] ?? 0.0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.analytics_outlined,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Statistik 7 Hari Terakhir',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Statistics
          if (totalRecords > 0) ...[
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.favorite_outline,
                    label: 'Tekanan Darah',
                    value: avgBpSys > 0 && avgBpDia > 0
                        ? '${avgBpSys.toStringAsFixed(0)}/${avgBpDia.toStringAsFixed(0)}'
                        : '-',
                    unit: 'mmHg',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.water_drop_outlined,
                    label: 'Gula Darah',
                    value: avgBs > 0 ? avgBs.toStringAsFixed(0) : '-',
                    unit: 'mg/dL',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '$totalRecords catatan dalam 7 hari terakhir',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ] else ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Belum ada data statistik',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  unit,
                  style: const TextStyle(fontSize: 10, color: Colors.white70),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
