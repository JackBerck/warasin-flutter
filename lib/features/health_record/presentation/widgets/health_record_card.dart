import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../data/models/health_record_model.dart';
import '../../providers/health_record_provider.dart';

class HealthRecordCard extends ConsumerWidget {
  final HealthRecord record;

  const HealthRecordCard({super.key, required this.record});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('EEEE, dd MMM yyyy', 'id_ID');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    dateFormat.format(record.date),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            size: 20,
                            color: Colors.grey.shade700,
                          ),
                          const SizedBox(width: 12),
                          const Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: Colors.red.shade700,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Hapus',
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      context.pushNamed('add-health-record', extra: record);
                    } else if (value == 'delete') {
                      _showDeleteDialog(context, ref);
                    }
                  },
                ),
              ],
            ),

            const Divider(height: 20),

            // Health metrics
            Row(
              children: [
                // Blood Pressure
                if (record.bloodPressureSystolic != null &&
                    record.bloodPressureDiastolic != null)
                  Expanded(
                    child: _buildMetricItem(
                      context: context,
                      icon: Icons.favorite,
                      iconColor: _getBloodPressureColor(record),
                      label: 'Tekanan Darah',
                      value: record.bloodPressureFormatted!,
                      status: record.bloodPressureStatus,
                      statusColor: _getBloodPressureColor(record),
                    ),
                  ),

                // Blood Sugar
                if (record.bloodSugar != null) ...[
                  if (record.bloodPressureSystolic != null)
                    const SizedBox(width: 16),
                  Expanded(
                    child: _buildMetricItem(
                      context: context,
                      icon: Icons.water_drop,
                      iconColor: _getBloodSugarColor(record),
                      label: 'Gula Darah',
                      value: '${record.bloodSugar!.toStringAsFixed(0)} mg/dL',
                      status: record.bloodSugarStatus,
                      statusColor: _getBloodSugarColor(record),
                    ),
                  ),
                ],
              ],
            ),

            // Notes
            if (record.notes != null && record.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.notes, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        record.notes!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Sync status
            if (!record.isSynced) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.cloud_off,
                    size: 14,
                    color: Colors.orange.shade700,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Belum tersinkron',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getBloodPressureColor(HealthRecord record) {
    if (record.bloodPressureSystolic == null) return Colors.grey;

    if (record.bloodPressureSystolic! < 120) {
      return Colors.green;
    } else if (record.bloodPressureSystolic! < 130) {
      return Colors.blue;
    } else if (record.bloodPressureSystolic! < 140) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Color _getBloodSugarColor(HealthRecord record) {
    if (record.bloodSugar == null) return Colors.grey;

    if (record.bloodSugar! < 70) {
      return Colors.orange;
    } else if (record.bloodSugar! <= 140) {
      return Colors.green;
    } else if (record.bloodSugar! <= 200) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Catatan'),
        content: Text(
          'Apakah Anda yakin ingin menghapus catatan tanggal ${dateFormat.format(record.date)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              final controller = ref.read(healthRecordControllerProvider);
              final success = await controller.deleteRecord(record.id);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Catatan berhasil dihapus'
                          : 'Gagal menghapus catatan',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
