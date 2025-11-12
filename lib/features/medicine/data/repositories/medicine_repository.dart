import 'package:uuid/uuid.dart';
import 'package:warasin/core/services/supabase_client.dart';
import '../models/medicine_model.dart';
import '../local/medicine_local_db.dart';

class MedicineRepository {
  final MedicineLocalDB _localDB = MedicineLocalDB.instance;
  final _uuid = const Uuid();

  // Create medicine
  Future<Medicine> createMedicine({
    required String userId,
    required String name,
    String? dosage,
    String? description,
    int stock = 0,
    bool isOfflineMode = false,
  }) async {
    final now = DateTime.now();
    final medicine = Medicine(
      id: _uuid.v4(),
      userId: userId,
      name: name,
      dosage: dosage,
      description: description,
      stock: stock,
      createdAt: now,
      updatedAt: now,
      isSynced: false,
    );

    // Save to local DB
    await _localDB.create(medicine);

    // Sync to Supabase if online mode
    if (!isOfflineMode) {
      try {
        await supabase.from('medicines').insert(medicine.toSupabaseMap());
        await _localDB.markAsSynced(medicine.id);
      } catch (e) {
        // If sync fails, data masih tersimpan lokal
        print('Sync failed: $e');
      }
    }

    return medicine;
  }

  // Get all medicines
  Future<List<Medicine>> getMedicines({
    required String userId,
    bool isOfflineMode = false,
  }) async {
    // Jika online mode, fetch dari Supabase dulu
    if (!isOfflineMode) {
      try {
        final response = await supabase
            .from('medicines')
            .select()
            .eq('user_id', userId)
            .order('created_at', ascending: false);

        // Update local DB dengan data dari Supabase
        for (var data in response) {
          final medicine = Medicine.fromSupabase(data);
          final existing = await _localDB.getById(medicine.id);

          if (existing == null) {
            await _localDB.create(medicine);
          } else {
            await _localDB.update(medicine);
          }
        }
      } catch (e) {
        print('Fetch from Supabase failed: $e');
      }
    }

    // Return data dari local DB (sebagai single source of truth)
    return await _localDB.getAllByUser(userId);
  }

  // Get medicine by id
  Future<Medicine?> getMedicineById(String id) async {
    return await _localDB.getById(id);
  }

  // Update medicine
  Future<void> updateMedicine({
    required Medicine medicine,
    bool isOfflineMode = false,
  }) async {
    final updatedMedicine = medicine.copyWith(
      updatedAt: DateTime.now(),
      isSynced: false,
    );

    // Update local DB
    await _localDB.update(updatedMedicine);

    // Sync to Supabase if online mode
    if (!isOfflineMode) {
      try {
        await supabase
            .from('medicines')
            .update(updatedMedicine.toSupabaseMap())
            .eq('id', medicine.id);
        await _localDB.markAsSynced(medicine.id);
      } catch (e) {
        print('Sync failed: $e');
      }
    }
  }

  // Delete medicine
  Future<void> deleteMedicine({
    required String id,
    bool isOfflineMode = false,
  }) async {
    // Delete from local DB
    await _localDB.delete(id);

    // Delete from Supabase if online mode
    if (!isOfflineMode) {
      try {
        await supabase.from('medicines').delete().eq('id', id);
      } catch (e) {
        print('Delete from Supabase failed: $e');
      }
    }
  }

  // Search medicines
  Future<List<Medicine>> searchMedicines({
    required String userId,
    required String query,
  }) async {
    return await _localDB.search(userId, query);
  }

  // Sync unsynced data (untuk offline mode)
  Future<void> syncUnsyncedData(String userId) async {
    final unsyncedMedicines = await _localDB.getUnsynced(userId);

    for (var medicine in unsyncedMedicines) {
      try {
        await supabase.from('medicines').upsert(medicine.toSupabaseMap());
        await _localDB.markAsSynced(medicine.id);
      } catch (e) {
        print('Sync failed for ${medicine.name}: $e');
      }
    }
  }
}
