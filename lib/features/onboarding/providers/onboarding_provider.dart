import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider untuk SharedPreferences instance
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

// Provider untuk check apakah sudah pernah onboarding (sync)
final hasSeenOnboardingProvider = Provider<bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getBool('has_seen_onboarding') ?? false;
});

// Provider untuk check app mode (sync)
final isOfflineModeProvider = Provider<bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getBool('is_offline_mode') ?? false;
});

// Provider untuk onboarding service
final onboardingServiceProvider = Provider<OnboardingService>((ref) {
  return OnboardingService(ref);
});

class OnboardingService {
  final Ref ref;

  OnboardingService(this.ref);

  Future<void> completeOnboarding() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool('has_seen_onboarding', true);

    // Force recompute provider so routing reacts immediately
    ref.invalidate(hasSeenOnboardingProvider);
  }

  Future<void> setAppMode(bool isOfflineMode) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool('is_offline_mode', isOfflineMode);

    // optional: refresh mode provider if you have one relying on it
    ref.invalidate(isOfflineModeProvider);
  }
}
