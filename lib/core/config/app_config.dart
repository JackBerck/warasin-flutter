import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get supabaseUrl {
    const env = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
    if (env.isNotEmpty) return env;
    return dotenv.env['SUPABASE_URL'] ?? '';
  }

  static String get supabaseAnonKey {
    const env = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
    if (env.isNotEmpty) return env;
    return dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  }
}