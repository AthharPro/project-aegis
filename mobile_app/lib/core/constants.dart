import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // Supabase Configuration
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  // Hive Boxes
  static const String incidentBoxName = 'incidents';
  static const String profileBoxName = 'profile';

  // Timeout
  static const Duration connectionTimeout = Duration(seconds: 10);
}
