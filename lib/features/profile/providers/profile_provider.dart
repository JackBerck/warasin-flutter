import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/profile_model.dart';
import '../data/repositories/profile_repository.dart';
import '../../auth/providers/auth_provider.dart';

// Repository provider
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

// Profile provider
final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  final repository = ref.read(profileRepositoryProvider);
  return await repository.getUserProfile(user.id);
});

// Profile controller
final profileControllerProvider = Provider<ProfileController>((ref) {
  return ProfileController(ref);
});

class ProfileController {
  final Ref ref;

  ProfileController(this.ref);

  Future<bool> updateProfile({String? name, int? age}) async {
    try {
      final user = ref.read(currentUserProvider);
      if (user == null) return false;

      final repository = ref.read(profileRepositoryProvider);
      final success = await repository.updateProfile(
        userId: user.id,
        name: name,
        age: age,
      );

      if (success) {
        ref.invalidate(userProfileProvider);
      }

      return success;
    } catch (e) {
      print('Update profile error: $e');
      return false;
    }
  }
}
