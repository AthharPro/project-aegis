// lib/api/auth_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants.dart';
import '../db/models.dart';

class AuthService {
  static late SupabaseClient _client;

  // Initialize Supabase client
  static void setClient(SupabaseClient client) {
    _client = client;
  }

  static SupabaseClient get client => _client;

  // Register user with email and password
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
    required String nic,
    required String phoneNumber,
  }) async {
    try {
      // 1. Create auth user
      final authResponse = await client.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        return {'success': false, 'message': 'Failed to create account'};
      }

      final userId = authResponse.user!.id;

      // 2. Create profile in profiles table
      await client.from('profiles').insert({
        'id': userId,
        'full_name': fullName,
        'nic': nic,
        'phone_number': phoneNumber,
        'role': 'responder', // Default role
      });

      print('✅ User registered successfully: $email');
      return {
        'success': true,
        'message': 'Registration successful',
        'userId': userId,
      };
    } catch (e) {
      print('❌ Registration error: $e');
      return {
        'success': false,
        'message': 'An error occurred. Please try again.',
      };
    }
  }

  // Login user
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      print('✅ Login successful: $email');
      return {
        'success': true,
        'message': 'Login successful',
        'user': response.user,
      };
    } catch (e) {
      print('❌ Login error: $e');
      return {
        'success': false,
        'message': 'An error occurred. Please try again.',
      };
    }
  }

  // Get current user profile
  static Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    try {
      final user = client.auth.currentUser;
      if (user == null) return null;

      final response = await client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      return Map<String, dynamic>.from(response);
    } catch (e) {
      print('❌ Error fetching profile: $e');
      return null;
    }
  }

  // Logout
  static Future<void> logout() async {
    try {
      await client.auth.signOut();
      print('✅ Logout successful');
    } catch (e) {
      print('❌ Logout error: $e');
    }
  }

  // Check if user is logged in
  static bool isLoggedIn() {
    return client.auth.currentUser != null;
  }

  // Get current auth user
  static dynamic getCurrentAuthUser() {
    return client.auth.currentUser;
  }

  // Update profile
  static Future<bool> updateProfile({
    required String fullName,
    required String phoneNumber,
  }) async {
    try {
      final user = client.auth.currentUser;
      if (user == null) return false;

      await client
          .from('profiles')
          .update({'full_name': fullName, 'phone_number': phoneNumber})
          .eq('id', user.id);

      print('✅ Profile updated');
      return true;
    } catch (e) {
      print('❌ Error updating profile: $e');
      return false;
    }
  }
}
