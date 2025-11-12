import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider untuk check apakah sudah pernah onboarding
final hasSeenOnboardingProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('has_seen_onboarding') ?? false;
});

// Provider untuk set onboarding status
final onboardingServiceProvider = Provider<OnboardingService>((ref) {
  return OnboardingService();
});

class OnboardingService {
  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
  }

  Future<void> setAppMode(bool isOfflineMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_offline_mode', isOfflineMode);
  }

  Future<bool> getAppMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_offline_mode') ?? false;
  }
}
