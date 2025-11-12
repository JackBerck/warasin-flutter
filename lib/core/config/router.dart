import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/medicine/presentation/pages/medicine_list_page.dart';
import '../../features/medicine/presentation/pages/add_medicine_page.dart';
import '../../features/schedule/presentation/pages/schedule_list_page.dart';
import '../../features/health_record/presentation/pages/health_record_page.dart';
import '../../features/health_record/presentation/pages/add_health_record_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/auth/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Route names constants
class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/';
  static const String medicineList = '/medicines';
  static const String addMedicine = '/medicines/add';
  static const String editMedicine = '/medicines/edit';
  static const String scheduleList = '/schedules';
  static const String healthRecords = '/health-records';
  static const String addHealthRecord = '/health-records/add';
  static const String profile = '/profile';
}

// GoRouter Provider
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.onboarding,
    debugLogDiagnostics: true,

    // Redirect logic untuk authentication
    redirect: (BuildContext context, GoRouterState state) async {
      final isOnboarding = state.matchedLocation == AppRoutes.onboarding;
      final isAuth =
          state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register;

      // Cek apakah user sudah pernah onboarding
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
      final isOfflineMode = prefs.getBool('is_offline_mode') ?? false;

      // Cek apakah user sudah login (untuk mode online)
      final isLoggedIn = authState.asData?.value != null;

      // Jika belum pernah onboarding, paksa ke onboarding
      if (!hasSeenOnboarding && !isOnboarding) {
        return AppRoutes.onboarding;
      }

      // Jika sudah onboarding tapi mode offline, langsung ke dashboard
      if (hasSeenOnboarding && isOfflineMode && !isLoggedIn && !isAuth) {
        return AppRoutes.dashboard;
      }

      // Jika sudah onboarding mode online tapi belum login, ke login
      if (hasSeenOnboarding && !isOfflineMode && !isLoggedIn && !isAuth) {
        return AppRoutes.login;
      }

      // Jika sudah login tapi masih di auth pages, redirect ke dashboard
      if (isLoggedIn && isAuth) {
        return AppRoutes.dashboard;
      }

      return null;
    },

    routes: [
      // Onboarding Route
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),

      // Auth Routes
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        // builder: (context, state) => const LoginPage(),
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Login Page - Coming Soon')),
        ),
      ),

      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        // builder: (context, state) => const RegisterPage(),
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Register Page - Coming Soon')),
        ),
      ),

      // Main App Routes with Bottom Navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return DashboardPage(navigationShell: navigationShell);
        },
        branches: [
          // Branch 1: Home/Dashboard
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                name: 'home',
                // pageBuilder: (context, state) =>
                //     const NoTransitionPage(child: HomePage()),
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: Scaffold(
                    body: Center(child: Text('Home Page - Coming Soon')),
                  ),
                ),
              ),
            ],
          ),

          // Branch 2: Medicines
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.medicineList,
                name: 'medicines',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: MedicineListPage()),
                routes: [
                  // Nested route untuk add medicine
                  GoRoute(
                    path: 'add',
                    name: 'add-medicine',
                    builder: (context, state) => const AddMedicinePage(),
                  ),
                  // Nested route untuk edit medicine
                  GoRoute(
                    path: 'edit/:id',
                    name: 'edit-medicine',
                    builder: (context, state) {
                      final medicineId = state.pathParameters['id']!;
                      return AddMedicinePage(medicineId: medicineId);
                    },
                  ),
                ],
              ),
            ],
          ),

          // Branch 3: Schedules
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.scheduleList,
                name: 'schedules',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: ScheduleListPage()),
              ),
            ],
          ),

          // Branch 4: Health Records
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.healthRecords,
                name: 'health-records',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: HealthRecordPage()),
                routes: [
                  GoRoute(
                    path: 'add',
                    name: 'add-health-record',
                    builder: (context, state) => const AddHealthRecordPage(),
                  ),
                ],
              ),
            ],
          ),

          // Branch 5: Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                name: 'profile',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: ProfilePage()),
              ),
            ],
          ),
        ],
      ),
    ],

    // Error handling
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Error: ${state.error}'))),
  );
});

// Provider untuk tracking onboarding status
final hasSeenOnboardingProvider = StateProvider<bool>((ref) => false);
