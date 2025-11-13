import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warasin/services/notification_service.dart';
import 'core/config/app_config.dart';
import 'services/local_database_service.dart';
import 'features/onboarding/providers/onboarding_provider.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  // Initialize Local Database
  await LocalDatabaseService.instance.init();

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  // Initialize Notifications
  await NotificationService.instance.init();

  runApp(
    ProviderScope(
      overrides: [
        // Override SharedPreferences provider dengan instance yang sudah diinit
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const WarasInApp(),
    ),
  );
}
