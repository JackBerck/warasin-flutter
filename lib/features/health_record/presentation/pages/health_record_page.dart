import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/health_record_provider.dart';
import '../widgets/health_record_card.dart';
import '../widgets/health_statistics_card.dart';
import '../widgets/empty_health_record_state.dart';

class HealthRecordPage extends ConsumerWidget {
  const HealthRecordPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(healthRecordListProvider);
    final statsAsync = ref.watch(healthRecordStatisticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Kesehatan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showInfoDialog(context);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(healthRecordListProvider);
          ref.invalidate(healthRecordStatisticsProvider);
        },
        child: recordsAsync.when(
          data: (records) {
            if (records.isEmpty) {
              return const EmptyHealthRecordState();
            }

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Statistics card
                  statsAsync.when(
                    data: (stats) => HealthStatisticsCard(statistics: stats),
                    loading: () => const SizedBox(),
                    error: (_, __) => const SizedBox(),
                  ),

                  const SizedBox(height: 8),

                  // Records list
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Riwayat Catatan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      return HealthRecordCard(
                        record: records[index],
                        key: ValueKey(records[index].id),
                      );
                    },
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(
                  'Terjadi kesalahan',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    ref.invalidate(healthRecordListProvider);
                  },
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.pushNamed('add-health-record');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Tentang Catatan Kesehatan'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Catat kesehatan Anda setiap hari untuk memantau kondisi tubuh.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 12),
            Text(
              '📊 Statistik menampilkan rata-rata 7 hari terakhir\n'
              '🩺 Tekanan darah normal: <120/80 mmHg\n'
              '🍬 Gula darah normal: 70-140 mg/dL',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }
}
