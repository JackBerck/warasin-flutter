import '../models/profile_model.dart';
import '../../../../core/services/supabase_client.dart';

class ProfileRepository {
  // Get user profile
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return UserProfile.fromSupabase(response);
    } catch (e) {
      print('Get profile error: $e');
      return null;
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    required String userId,
    String? name,
    int? age,
  }) async {
    try {
      await supabase
          .from('profiles')
          .update({
            'name': name,
            'age': age,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);

      return true;
    } catch (e) {
      print('Update profile error: $e');
      return false;
    }
  }

  // Delete account (optional)
  Future<bool> deleteAccount(String userId) async {
    try {
      // Delete dari profiles (cascade akan hapus semua data terkait)
      await supabase.from('profiles').delete().eq('id', userId);

      // Delete auth user
      // Note: Ini memerlukan admin privileges, untuk production
      // sebaiknya menggunakan Edge Function

      return true;
    } catch (e) {
      print('Delete account error: $e');
      return false;
    }
  }
}
