// lib/api/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/db/hive_db.dart';
import '../constants.dart';
import '../db/secure_storage.dart';
import '../db/models.dart';

class ApiService {
  static final _client = http.Client();
  
  // Login
  static Future<Map<String, dynamic>> login(
    String email, 
    String password
  ) async {
    try {
      final deviceId = await SecureStorage.getDeviceId();
      
      final response = await _client.post(
        Uri.parse('${Constants.apiUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'device_id': deviceId,
          'device_info': {
            'platform': 'flutter',
            'app_version': Constants.appVersion,
          },
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': 'Login failed: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
  
  // Submit disaster report (with offline support)
  static Future<Map<String, dynamic>> submitDisasterReport(
    DisasterReport report,
  ) async {
    try {
      final token = await SecureStorage.getToken();
      
      if (token == null) {
        return {'success': false, 'message': 'Not logged in'};
      }
      
      final response = await _client.post(
        Uri.parse('${Constants.apiUrl}/disaster-reports'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'type': report.type,
          'severity': report.severity,
          'lat': report.lat,
          'lng': report.lng,
          'description': report.description,
          'people_affected': report.peopleAffected,
          'photos': report.photos,
        }),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true};
      } else {
        return {
          'success': false,
          'message': 'Failed to submit: ${response.statusCode}',
        };
      }
    } catch (e) {
      // Save to Hive for offline sync
      report.status = 'pending';
      await HiveDB.savePendingReport(report);
      
      return {
        'success': false,
        'message': 'Saved offline: ${e.toString()}',
      };
    }
  }
  
  // Sync pending reports
  static Future<void> syncPendingReports() async {
    final pending = HiveDB.getPendingReports();
    
    for (final report in pending) {
      final result = await submitDisasterReport(report);
      if (result['success'] == true) {
        await HiveDB.deleteReport(report.id);
      }
    }
  }
}