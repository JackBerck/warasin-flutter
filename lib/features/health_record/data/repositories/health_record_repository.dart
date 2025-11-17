import 'package:uuid/uuid.dart';
import '../models/health_record_model.dart';
import '../local/health_record_local_db.dart';
import '../../../../core/services/supabase_client.dart';

class HealthRecordRepository {
  final HealthRecordLocalDB _localDB = HealthRecordLocalDB.instance;
  final _uuid = const Uuid();

  // Create health record
  Future<HealthRecord> createRecord({
    required String userId,
    required DateTime date,
    int? bloodPressureSystolic,
    int? bloodPressureDiastolic,
    double? bloodSugar,
    String? notes,
    bool isOfflineMode = false,
  }) async {
    final now = DateTime.now();
    final record = HealthRecord(
      id: _uuid.v4(),
      userId: userId,
      date: date,
      bloodPressureSystolic: bloodPressureSystolic,
      bloodPressureDiastolic: bloodPressureDiastolic,
      bloodSugar: bloodSugar,
      notes: notes,
      createdAt: now,
      updatedAt: now,
      isSynced: false,
    );

    // Save to local DB
    await _localDB.create(record);

    // Sync to Supabase if online mode
    if (!isOfflineMode) {
      try {
        await supabase.from('health_records').insert(record.toSupabaseMap());
        await _localDB.markAsSynced(record.id);
      } catch (e) {
        print('Sync failed: $e');
      }
    }

    return record;
  }

  // Get all records
  Future<List<HealthRecord>> getRecords({
    required String userId,
    bool isOfflineMode = false,
  }) async {
    // Jika online mode, fetch dari Supabase dulu
    if (!isOfflineMode) {
      try {
        final response = await supabase
            .from('health_records')
            .select()
            .eq('user_id', userId)
            .order('date', ascending: false);

        // Sync to local DB
        for (var data in response) {
          final record = HealthRecord.fromSupabase(data);
          final existing = await _localDB.getById(record.id);

          if (existing == null) {
            await _localDB.create(record);
          } else {
            await _localDB.update(record);
          }
        }
      } catch (e) {
        print('Fetch from Supabase failed: $e');
      }
    }

    // Return data dari local DB
    return await _localDB.getAllByUser(userId);
  }

  // Get record by id
  Future<HealthRecord?> getRecordById(String id) async {
    return await _localDB.getById(id);
  }

  // Get record by date
  Future<HealthRecord?> getRecordByDate(String userId, DateTime date) async {
    return await _localDB.getByDate(userId, date);
  }

  // Get records in date range
  Future<List<HealthRecord>> getRecordsByDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return await _localDB.getByDateRange(userId, startDate, endDate);
  }

  // Update record
  Future<void> updateRecord({
    required HealthRecord record,
    bool isOfflineMode = false,
  }) async {
    final updatedRecord = record.copyWith(
      updatedAt: DateTime.now(),
      isSynced: false,
    );

    // Update local DB
    await _localDB.update(updatedRecord);

    // Sync to Supabase if online mode
    if (!isOfflineMode) {
      try {
        await supabase
            .from('health_records')
            .update(updatedRecord.toSupabaseMap())
            .eq('id', record.id);
        await _localDB.markAsSynced(record.id);
      } catch (e) {
        print('Sync failed: $e');
      }
    }
  }

  // Delete record
  Future<void> deleteRecord({
    required String id,
    bool isOfflineMode = false,
  }) async {
    // Delete from local DB
    await _localDB.delete(id);

    // Delete from Supabase if online mode
    if (!isOfflineMode) {
      try {
        await supabase.from('health_records').delete().eq('id', id);
      } catch (e) {
        print('Delete from Supabase failed: $e');
      }
    }
  }

  // Get latest record
  Future<HealthRecord?> getLatestRecord(String userId) async {
    return await _localDB.getLatest(userId);
  }

  // Get statistics
  Future<Map<String, dynamic>> getStatistics({
    required String userId,
    int days = 7,
  }) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));
    final records = await _localDB.getByDateRange(userId, startDate, endDate);

    if (records.isEmpty) {
      return {
        'totalRecords': 0,
        'avgBloodPressureSystolic': 0.0,
        'avgBloodPressureDiastolic': 0.0,
        'avgBloodSugar': 0.0,
      };
    }

    // Calculate averages
    int bpSysCount = 0;
    int bpDiaCount = 0;
    int bsCount = 0;
    double totalBpSys = 0;
    double totalBpDia = 0;
    double totalBs = 0;

    for (var record in records) {
      if (record.bloodPressureSystolic != null) {
        totalBpSys += record.bloodPressureSystolic!;
        bpSysCount++;
      }
      if (record.bloodPressureDiastolic != null) {
        totalBpDia += record.bloodPressureDiastolic!;
        bpDiaCount++;
      }
      if (record.bloodSugar != null) {
        totalBs += record.bloodSugar!;
        bsCount++;
      }
    }

    return {
      'totalRecords': records.length,
      'avgBloodPressureSystolic': bpSysCount > 0
          ? totalBpSys / bpSysCount
          : 0.0,
      'avgBloodPressureDiastolic': bpDiaCount > 0
          ? totalBpDia / bpDiaCount
          : 0.0,
      'avgBloodSugar': bsCount > 0 ? totalBs / bsCount : 0.0,
      'latestRecord': records.isNotEmpty ? records.first : null,
    };
  }
}
