import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/schedule_model.dart';
import '../data/repositories/schedule_repository.dart';
import '../../auth/providers/auth_provider.dart';
import '../../onboarding/providers/onboarding_provider.dart';

// Repository provider
final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  return ScheduleRepository();
});

// Schedule list provider
final scheduleListProvider = FutureProvider<List<Schedule>>((ref) async {
  final repository = ref.read(scheduleRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  final isOfflineMode = ref.watch(isOfflineModeProvider);

  if (user == null && !isOfflineMode) {
    return [];
  }

  final userId = user?.id ?? 'offline_user';
  return await repository.getSchedules(
    userId: userId,
    isOfflineMode: isOfflineMode,
  );
});

// Schedule controller
final scheduleControllerProvider = Provider<ScheduleController>((ref) {
  return ScheduleController(ref);
});

class ScheduleController {
  final Ref ref;

  ScheduleController(this.ref);

  Future<bool> createSchedule({
    required String medicineId,
    required TimeOfDay time,
    required List<int> days,
  }) async {
    try {
      final repository = ref.read(scheduleRepositoryProvider);
      final user = ref.read(currentUserProvider);
      final isOfflineMode = ref.read(isOfflineModeProvider);

      final userId = user?.id ?? 'offline_user';

      await repository.createSchedule(
        userId: userId,
        medicineId: medicineId,
        time: time,
        days: days,
        isOfflineMode: isOfflineMode,
      );

      ref.invalidate(scheduleListProvider);
      return true;
    } catch (e) {
      print('Create schedule error: $e');
      return false;
    }
  }

  Future<bool> updateSchedule({required Schedule schedule}) async {
    try {
      final repository = ref.read(scheduleRepositoryProvider);
      final isOfflineMode = ref.read(isOfflineModeProvider);

      await repository.updateSchedule(
        schedule: schedule,
        isOfflineMode: isOfflineMode,
      );

      ref.invalidate(scheduleListProvider);
      return true;
    } catch (e) {
      print('Update schedule error: $e');
      return false;
    }
  }

  Future<bool> toggleScheduleActive({
    required String id,
    required bool isActive,
  }) async {
    try {
      final repository = ref.read(scheduleRepositoryProvider);
      final isOfflineMode = ref.read(isOfflineModeProvider);

      await repository.toggleScheduleActive(
        id: id,
        isActive: isActive,
        isOfflineMode: isOfflineMode,
      );

      ref.invalidate(scheduleListProvider);
      return true;
    } catch (e) {
      print('Toggle schedule error: $e');
      return false;
    }
  }

  Future<bool> deleteSchedule(String id) async {
    try {
      final repository = ref.read(scheduleRepositoryProvider);
      final isOfflineMode = ref.read(isOfflineModeProvider);

      await repository.deleteSchedule(id: id, isOfflineMode: isOfflineMode);

      ref.invalidate(scheduleListProvider);
      return true;
    } catch (e) {
      print('Delete schedule error: $e');
      return false;
    }
  }
}
