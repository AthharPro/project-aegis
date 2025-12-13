// lib/constants.dart

// Supabase Configuration
const String SUPABASE_URL = 'https://uoxfbsoowkrfmanykxuh.supabase.co';
const String SUPABASE_ANON_KEY =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVveGZic29vd2tyZm1hbnlreHVoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU2MTA1OTksImV4cCI6MjA4MTE4NjU5OX0.9VcIaw1_6h-GLoI5hwVK5kKF3YxuoXYSKcGLE_4SHD4';

class Constants {
  // API
  static const String apiUrl = 'http://10.0.2.2:3000/api'; // Local backend
  // static const String apiUrl = 'https://your-backend.com/api'; // Production

  // App
  static const String appName = 'Disaster Relief';
  static const String appVersion = '1.0.0';

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String deviceIdKey = 'device_id';

  // Hive boxes
  static const String pendingReportsBox = 'pending_reports';
  static const String userBox = 'user_box';

  // Table names
  static const String profilesTable = 'profiles';
  static const String incidentReportsTable = 'incident_reports';
}
