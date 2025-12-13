// lib/constants.dart
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
}