import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:warasin/core/config/app_config.dart';
import 'package:warasin/services/local_database_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

  // Initialize Notifications
  // await NotificationService.instance.init();

  runApp(const ProviderScope(child: WarasInApp()));
}
