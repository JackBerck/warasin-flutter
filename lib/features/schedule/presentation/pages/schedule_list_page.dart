import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warasin/services/notification_service.dart';
import '../../providers/schedule_provider.dart';
import '../../data/models/schedule_model.dart';
import '../widgets/schedule_card.dart';
import '../widgets/empty_schedule_state.dart';
import '../widgets/add_schedule_bottom_sheet.dart';

class ScheduleListPage extends ConsumerWidget {
  const ScheduleListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedulesAsync = ref.watch(scheduleListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Obat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active),
            onPressed: () async {
              await NotificationService.instance.showImmediateNotification(
                id: 99999,
                title: 'Test Notifikasi Langsung',
                body: 'Jika ini muncul, notifikasi bekerja! ✅',
              );
            },
          ),
          // Tambahkan di AppBar actions
          IconButton(
            icon: const Icon(Icons.pending_actions),
            onPressed: () async {
              final pending = await NotificationService.instance
                  .getPendingNotifications();

              if (context.mounted) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Pending Notifications (${pending.length})'),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...pending.map((notif) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ID: ${notif.id}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    'Title: ${notif.title}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  Text(
                                    'Body: ${notif.body}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const Divider(),
                                ],
                              ),
                            );
                          }),
                          if (pending.isEmpty)
                            const Text('Tidak ada notifikasi yang dijadwalkan'),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
          // Diagnostic button
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () async {
              final canSchedule = await NotificationService.instance
                  .isBatteryOptimizationDisabled();

              if (context.mounted) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Diagnostic Notifikasi'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          canSchedule
                              ? '✅ Exact Alarm: Diizinkan'
                              : '❌ Exact Alarm: Tidak diizinkan',
                          style: TextStyle(
                            color: canSchedule ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (!canSchedule) ...[
                          const Text(
                            'Untuk notifikasi bekerja dengan baik:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '1. Buka Settings > Apps > Warasin\n'
                            '2. Pilih "Alarms & reminders"\n'
                            '3. Aktifkan "Allow setting alarms and reminders"\n'
                            '4. Nonaktifkan Battery Optimization',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: schedulesAsync.when(
        data: (schedules) {
          if (schedules.isEmpty) {
            return const EmptyScheduleState();
          }

          // Group schedules by time
          final groupedSchedules = _groupSchedulesByTime(schedules);

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(scheduleListProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: groupedSchedules.length,
              itemBuilder: (context, index) {
                final timeKey = groupedSchedules.keys.elementAt(index);
                final timeSchedules = groupedSchedules[timeKey]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (index == 0) const SizedBox(height: 8),

                    // Time header
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 4,
                        bottom: 12,
                        top: 8,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 18,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            timeKey,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Divider(
                              color: Colors.grey.shade300,
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Schedule cards
                    ...timeSchedules.map((schedule) {
                      return ScheduleCard(
                        schedule: schedule,
                        key: ValueKey(schedule.id),
                      );
                    }),
                  ],
                );
              },
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
                onPressed: () => ref.invalidate(scheduleListProvider),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddScheduleSheet(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Map<String, List<Schedule>> _groupSchedulesByTime(List<Schedule> schedules) {
    final Map<String, List<Schedule>> grouped = {};

    for (var schedule in schedules) {
      final timeKey = Schedule.timeToString(schedule.time);
      if (!grouped.containsKey(timeKey)) {
        grouped[timeKey] = [];
      }
      grouped[timeKey]!.add(schedule);
    }

    return grouped;
  }

  void _showAddScheduleSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddScheduleBottomSheet(),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Tentang Jadwal'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Jadwal akan mengirim notifikasi sesuai waktu yang ditentukan.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 12),
            Text(
              '• Pastikan izin notifikasi sudah diaktifkan\n'
              '• Jadwal yang tidak aktif tidak akan mengirim notifikasi\n'
              '• Anda bisa mengatur hari-hari tertentu untuk setiap jadwal',
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
