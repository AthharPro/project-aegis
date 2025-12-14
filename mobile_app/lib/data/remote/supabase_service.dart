import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // Auth getters
  User? get currentUser => _client.auth.currentUser;
  Session? get currentSession => _client.auth.currentSession;
  bool get isAuthenticated => currentSession != null;

  // Sign In
  Future<AuthResponse> signIn(String email, String password) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign Up
  Future<AuthResponse> signUp(String email, String password) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  // Sign Out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Upload Incident
  // Returns true if successful
  Future<bool> uploadIncident(Map<String, dynamic> incidentData) async {
    try {
      await _client.from('incident_reports').insert(incidentData);
      return true;
    } catch (e) {
      // In a real app, log error to Crashlytics
      print('Sync Error: $e');
      return false;
    }
  }

  // Upload Image to Storage
  // Returns public URL if successful, null otherwise
  // Upload Image Bytes to Storage (works for Web & Mobile)
  // Returns public URL if successful, null otherwise
  Future<String?> uploadImageBytes(Uint8List bytes, String fileName) async {
    try {
      const bucketName = 'incident_images';
      final path = 'uploads/$fileName';
      
      await _client.storage.from(bucketName).uploadBinary(
        path,
        bytes,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );

      final publicUrl = _client.storage.from(bucketName).getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      print('Image Upload Error: $e');
      return null;
    }
  }

  // Check connection to Supabase (simple ping)
  Future<bool> checkConnection() async {
    try {
      final response = await _client.from('incident_reports').select('id').limit(1).maybeSingle();
      return true;
    } catch (e) {
      return false;
    }
  }
}
