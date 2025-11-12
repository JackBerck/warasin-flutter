import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/medicine_model.dart';
import '../data/repositories/medicine_repository.dart';
import '../../auth/providers/auth_provider.dart';
import '../../onboarding/providers/onboarding_provider.dart';

// Repository provider
final medicineRepositoryProvider = Provider<MedicineRepository>((ref) {
  return MedicineRepository();
});

// Medicine list provider
final medicineListProvider = FutureProvider<List<Medicine>>((ref) async {
  final repository = ref.read(medicineRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  final isOfflineMode = ref.watch(isOfflineModeProvider);

  if (user == null && !isOfflineMode) {
    return [];
  }

  final userId = user?.id ?? 'offline_user';
  return await repository.getMedicines(
    userId: userId,
    isOfflineMode: isOfflineMode,
  );
});

// Medicine controller
final medicineControllerProvider = Provider<MedicineController>((ref) {
  return MedicineController(ref);
});

class MedicineController {
  final Ref ref;

  MedicineController(this.ref);

  Future<bool> createMedicine({
    required String name,
    String? dosage,
    String? description,
    int stock = 0,
  }) async {
    try {
      final repository = ref.read(medicineRepositoryProvider);
      final user = ref.read(currentUserProvider);
      final isOfflineMode = ref.read(isOfflineModeProvider);

      final userId = user?.id ?? 'offline_user';

      await repository.createMedicine(
        userId: userId,
        name: name,
        dosage: dosage,
        description: description,
        stock: stock,
        isOfflineMode: isOfflineMode,
      );

      // Refresh list
      ref.invalidate(medicineListProvider);
      return true;
    } catch (e) {
      print('Create medicine error: $e');
      return false;
    }
  }

  Future<bool> updateMedicine({
    required Medicine medicine,
  }) async {
    try {
      final repository = ref.read(medicineRepositoryProvider);
      final isOfflineMode = ref.read(isOfflineModeProvider);

      await repository.updateMedicine(
        medicine: medicine,
        isOfflineMode: isOfflineMode,
      );

      // Refresh list
      ref.invalidate(medicineListProvider);
      return true;
    } catch (e) {
      print('Update medicine error: $e');
      return false;
    }
  }

  Future<bool> deleteMedicine(String id) async {
    try {
      final repository = ref.read(medicineRepositoryProvider);
      final isOfflineMode = ref.read(isOfflineModeProvider);

      await repository.deleteMedicine(
        id: id,
        isOfflineMode: isOfflineMode,
      );

      // Refresh list
      ref.invalidate(medicineListProvider);
      return true;
    } catch (e) {
      print('Delete medicine error: $e');
      return false;
    }
  }

  Future<List<Medicine>> searchMedicines(String query) async {
    final repository = ref.read(medicineRepositoryProvider);
    final user = ref.read(currentUserProvider);
    final userId = user?.id ?? 'offline_user';

    return await repository.searchMedicines(
      userId: userId,
      query: query,
    );
  }
}
