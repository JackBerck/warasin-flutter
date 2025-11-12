import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:warasin/core/services/supabase_client.dart';

class AuthRepository {
  // Sign up dengan email & password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: name != null ? {'name': name} : null,
      );

      return response;
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'Terjadi kesalahan saat mendaftar';
    }
  }

  // Sign in dengan email & password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      return response;
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'Terjadi kesalahan saat masuk';
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
    } catch (e) {
      throw 'Terjadi kesalahan saat keluar';
    }
  }

  // Get current user
  User? getCurrentUser() {
    return supabase.auth.currentUser;
  }

  // Stream auth state changes
  Stream<AuthState> authStateChanges() {
    return supabase.auth.onAuthStateChange;
  }
}
