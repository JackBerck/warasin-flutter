import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:warasin/core/services/supabase_client.dart';
import 'package:warasin/core/utils/helpers.dart';
import '../models/schedule_model.dart';
import '../local/schedule_local_db.dart';
import '../../../medicine/data/local/medicine_local_db.dart';
import '../../../../services/notification_service.dart';

class ScheduleRepository {
  final ScheduleLocalDB _localDB = ScheduleLocalDB.instance;
  final MedicineLocalDB _medicineDB = MedicineLocalDB.instance;
  final NotificationService _notificationService = NotificationService.instance;
  final _uuid = const Uuid();

  int _notifId(String id) => stringIdTo32(id);

  // Create schedule
  Future<Schedule> createSchedule({
    required String userId,
    required String medicineId,
    required TimeOfDay time,
    required List<int> days,
    bool isOfflineMode = false,
  }) async {
    final now = DateTime.now();
    final schedule = Schedule(
      id: _uuid.v4(),
      userId: userId,
      medicineId: medicineId,
      time: time,
      days: days,
      isActive: true,
      createdAt: now,
      updatedAt: now,
      isSynced: false,
    );

    // Save to local DB
    await _localDB.create(schedule);

    // Get medicine untuk notif title
    final medicine = await _medicineDB.getById(medicineId);

    // Schedule notification
    if (medicine != null) {
      await _notificationService.scheduleDailyNotification(
        id: _notifId(schedule.id),
        title: 'Waktunya Minum Obat!',
        body: '${medicine.name} - ${medicine.dosage ?? ""}',
        time: time,
        days: days,
      );
    }

    // Sync to Supabase if online mode
    if (!isOfflineMode) {
      try {
        await supabase.from('schedules').insert(schedule.toSupabaseMap());
        await _localDB.markAsSynced(schedule.id);
      } catch (e) {
        print('Sync failed: $e');
      }
    }

    return schedule;
  }

  // Get all schedules with medicine details
  Future<List<Schedule>> getSchedules({
    required String userId,
    bool isOfflineMode = false,
  }) async {
    // Jika online mode, fetch dari Supabase dulu
    if (!isOfflineMode) {
      try {
        final response = await supabase
            .from('schedules')
            .select()
            .eq('user_id', userId)
            .order('time', ascending: true);

        // Sync to local DB
        for (var data in response) {
          final schedule = Schedule(
            id: data['id'],
            userId: data['user_id'],
            medicineId: data['medicine_id'],
            time: Schedule.stringToTime(data['time']),
            days: (data['days'] as List).map((d) {
              // Convert day name to number
              const dayMap = {
                'senin': 1,
                'selasa': 2,
                'rabu': 3,
                'kamis': 4,
                'jumat': 5,
                'sabtu': 6,
                'minggu': 7,
              };
              return dayMap[d.toString().toLowerCase()] ?? 1;
            }).toList(),
            isActive: data['is_active'],
            createdAt: DateTime.parse(data['created_at']),
            updatedAt: DateTime.parse(data['updated_at']),
            isSynced: true,
          );

          final existing = await _localDB.getById(schedule.id);
          if (existing == null) {
            await _localDB.create(schedule);
          } else {
            await _localDB.update(schedule);
          }
        }
      } catch (e) {
        print('Fetch from Supabase failed: $e');
      }
    }

    // Get from local DB
    final schedules = await _localDB.getAllByUser(userId);

    // Attach medicine details
    for (var i = 0; i < schedules.length; i++) {
      final medicine = await _medicineDB.getById(schedules[i].medicineId);
      schedules[i] = schedules[i].copyWith(medicine: medicine);
    }

    return schedules;
  }

  // Get schedule by id
  Future<Schedule?> getScheduleById(String id) async {
    final schedule = await _localDB.getById(id);
    if (schedule != null) {
      final medicine = await _medicineDB.getById(schedule.medicineId);
      return schedule.copyWith(medicine: medicine);
    }
    return null;
  }

  // Update schedule
  Future<void> updateSchedule({
    required Schedule schedule,
    bool isOfflineMode = false,
  }) async {
    final updatedSchedule = schedule.copyWith(
      updatedAt: DateTime.now(),
      isSynced: false,
    );

    // Update local DB
    await _localDB.update(updatedSchedule);

    // Cancel old notifications
    await _notificationService.cancelNotification(
      _notifId(schedule.id),
      schedule.days,
    );

    // Reschedule if active
    if (updatedSchedule.isActive && updatedSchedule.medicine != null) {
      await _notificationService.scheduleDailyNotification(
        id: _notifId(updatedSchedule.id),
        title: 'Waktunya Minum Obat!',
        body:
            '${updatedSchedule.medicine!.name} - ${updatedSchedule.medicine!.dosage ?? ""}',
        time: updatedSchedule.time,
        days: updatedSchedule.days,
      );
    }

    // Sync to Supabase if online mode
    if (!isOfflineMode) {
      try {
        await supabase
            .from('schedules')
            .update(updatedSchedule.toSupabaseMap())
            .eq('id', schedule.id);
        await _localDB.markAsSynced(schedule.id);
      } catch (e) {
        print('Sync failed: $e');
      }
    }
  }

  // Toggle schedule active status
  Future<void> toggleScheduleActive({
    required String id,
    required bool isActive,
    bool isOfflineMode = false,
  }) async {
    await _localDB.toggleActive(id, isActive);

    final schedule = await _localDB.getById(id);
    if (schedule != null) {
      if (isActive) {
        // Schedule notification
        final medicine = await _medicineDB.getById(schedule.medicineId);
        if (medicine != null) {
          await _notificationService.scheduleDailyNotification(
            id: _notifId(schedule.id),
            title: 'Waktunya Minum Obat!',
            body: '${medicine.name} - ${medicine.dosage ?? ""}',
            time: schedule.time,
            days: schedule.days,
          );
        }
      } else {
        // Cancel notification
        await _notificationService.cancelNotification(
          _notifId(schedule.id),
          schedule.days,
        );
      }

      // Sync to Supabase
      if (!isOfflineMode) {
        try {
          await supabase
              .from('schedules')
              .update({'is_active': isActive})
              .eq('id', id);
          await _localDB.markAsSynced(id);
        } catch (e) {
          print('Sync failed: $e');
        }
      }
    }
  }

  // Delete schedule
  Future<void> deleteSchedule({
    required String id,
    bool isOfflineMode = false,
  }) async {
    final schedule = await _localDB.getById(id);

    // Cancel notifications
    if (schedule != null) {
      await _notificationService.cancelNotification(
        _notifId(schedule.id),
        schedule.days,
      );
    }

    // Delete from local DB
    await _localDB.delete(id);

    // Delete from Supabase if online mode
    if (!isOfflineMode) {
      try {
        await supabase.from('schedules').delete().eq('id', id);
      } catch (e) {
        print('Delete from Supabase failed: $e');
      }
    }
  }
}
