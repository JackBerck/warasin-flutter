import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(ref);
});

class AuthController {
  final Ref ref;

  AuthController(this.ref);

  // Sign up
  Future<bool> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      ref.read(authLoadingProvider.notifier).state = true;
      ref.read(authErrorProvider.notifier).state = null;

      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.signUp(email: email, password: password, name: name);

      return true;
    } catch (e) {
      ref.read(authErrorProvider.notifier).state = e.toString();
      return false;
    } finally {
      ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  // Sign in
  Future<bool> signIn({required String email, required String password}) async {
    try {
      ref.read(authLoadingProvider.notifier).state = true;
      ref.read(authErrorProvider.notifier).state = null;

      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.signIn(email: email, password: password);

      return true;
    } catch (e) {
      ref.read(authErrorProvider.notifier).state = e.toString();
      return false;
    } finally {
      ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    final authRepo = ref.read(authRepositoryProvider);
    await authRepo.signOut();
  }
}
