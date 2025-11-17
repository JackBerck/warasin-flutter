import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/health_record_model.dart';
import '../data/repositories/health_record_repository.dart';
import '../../auth/providers/auth_provider.dart';
import '../../onboarding/providers/onboarding_provider.dart';

// Repository provider
final healthRecordRepositoryProvider = Provider<HealthRecordRepository>((ref) {
  return HealthRecordRepository();
});

// Health record list provider
final healthRecordListProvider = FutureProvider<List<HealthRecord>>((
  ref,
) async {
  final repository = ref.read(healthRecordRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  final isOfflineMode = ref.watch(isOfflineModeProvider);

  if (user == null && !isOfflineMode) {
    return [];
  }

  final userId = user?.id ?? 'offline_user';
  return await repository.getRecords(
    userId: userId,
    isOfflineMode: isOfflineMode,
  );
});

// Statistics provider (last 7 days)
final healthRecordStatisticsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final repository = ref.read(healthRecordRepositoryProvider);
  final user = ref.watch(currentUserProvider);

  if (user == null) {
    return {
      'totalRecords': 0,
      'avgBloodPressureSystolic': 0.0,
      'avgBloodPressureDiastolic': 0.0,
      'avgBloodSugar': 0.0,
    };
  }

  return await repository.getStatistics(userId: user.id, days: 7);
});

// Health record controller
final healthRecordControllerProvider = Provider<HealthRecordController>((ref) {
  return HealthRecordController(ref);
});

class HealthRecordController {
  final Ref ref;

  HealthRecordController(this.ref);

  Future<bool> createRecord({
    required DateTime date,
    int? bloodPressureSystolic,
    int? bloodPressureDiastolic,
    double? bloodSugar,
    String? notes,
  }) async {
    try {
      final repository = ref.read(healthRecordRepositoryProvider);
      final user = ref.read(currentUserProvider);
      final isOfflineMode = ref.read(isOfflineModeProvider);

      final userId = user?.id ?? 'offline_user';

      await repository.createRecord(
        userId: userId,
        date: date,
        bloodPressureSystolic: bloodPressureSystolic,
        bloodPressureDiastolic: bloodPressureDiastolic,
        bloodSugar: bloodSugar,
        notes: notes,
        isOfflineMode: isOfflineMode,
      );

      ref.invalidate(healthRecordListProvider);
      ref.invalidate(healthRecordStatisticsProvider);
      return true;
    } catch (e) {
      print('Create health record error: $e');
      return false;
    }
  }

  Future<bool> updateRecord({required HealthRecord record}) async {
    try {
      final repository = ref.read(healthRecordRepositoryProvider);
      final isOfflineMode = ref.read(isOfflineModeProvider);

      await repository.updateRecord(
        record: record,
        isOfflineMode: isOfflineMode,
      );

      ref.invalidate(healthRecordListProvider);
      ref.invalidate(healthRecordStatisticsProvider);
      return true;
    } catch (e) {
      print('Update health record error: $e');
      return false;
    }
  }

  Future<bool> deleteRecord(String id) async {
    try {
      final repository = ref.read(healthRecordRepositoryProvider);
      final isOfflineMode = ref.read(isOfflineModeProvider);

      await repository.deleteRecord(id: id, isOfflineMode: isOfflineMode);

      ref.invalidate(healthRecordListProvider);
      ref.invalidate(healthRecordStatisticsProvider);
      return true;
    } catch (e) {
      print('Delete health record error: $e');
      return false;
    }
  }

  Future<HealthRecord?> getRecordByDate(DateTime date) async {
    final repository = ref.read(healthRecordRepositoryProvider);
    final user = ref.read(currentUserProvider);
    final userId = user?.id ?? 'offline_user';

    return await repository.getRecordByDate(userId, date);
  }
}
