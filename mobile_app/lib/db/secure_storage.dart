// lib/db/secure_storage.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants.dart';

class SecureStorage {
  static final _storage = FlutterSecureStorage();
  
  // Save login data
  static Future<void> saveLoginData({
    required String token,
    required String refreshToken,
    required String userData,
  }) async {
    await Future.wait([
      _storage.write(key: Constants.tokenKey, value: token),
      _storage.write(key: Constants.refreshTokenKey, value: refreshToken),
      _storage.write(key: Constants.userKey, value: userData),
    ]);
  }
  
  // Get token
  static Future<String?> getToken() async {
    return await _storage.read(key: Constants.tokenKey);
  }
  
  // Get refresh token
  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: Constants.refreshTokenKey);
  }
  
  // Get user data
  static Future<String?> getUserData() async {
    return await _storage.read(key: Constants.userKey);
  }
  
  // Check if logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
  
  // Clear all data (logout)
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
  
  // Get device ID
  static Future<String> getDeviceId() async {
    String? deviceId = await _storage.read(key: Constants.deviceIdKey);
    if (deviceId == null) {
      deviceId = 'device_${DateTime.now().millisecondsSinceEpoch}';
      await _storage.write(key: Constants.deviceIdKey, value: deviceId);
    }
    return deviceId;
  }
}