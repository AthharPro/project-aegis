// lib/pages/login_page.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import '../widgets/button.dart';
import '../widgets/input_field.dart';
import '../utils.dart';
import '../api/api_service.dart';
import '../db/secure_storage.dart';
import '../db/hive_db.dart';
import '../db/models.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // For testing
    _emailController.text = 'test@example.com';
    _passwordController.text = 'password123';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning,
                    size: 50,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 30),
                
                const Text(
                  'Disaster Relief',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Field Reporting System',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 40),

                // Email field
                InputField(
                  label: 'Email',
                  controller: _emailController,
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    }
                    if (!isValidEmail(value)) {
                      return 'Enter valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Password field
                InputField(
                  label: 'Password',
                  controller: _passwordController,
                  icon: Icons.lock,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // Login button
                AppButton(
                  text: 'Login',
                  onPressed: _login,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 20),

                // Test info
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'For Testing:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Email: test@example.com\nPassword: password123',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 5),
                        TextButton(
                          onPressed: () {
                            _emailController.text = 'test@example.com';
                            _passwordController.text = 'password123';
                          },
                          child: const Text('Fill Test Data'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final result = await ApiService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      setState(() => _isLoading = false);
      
      if (result['success'] == true) {
        final data = result['data'];
        
        // Save tokens
        await SecureStorage.saveLoginData(
          token: data['system_token'],
          refreshToken: data['refresh_token'],
          userData: jsonEncode(data['user_profile']),
        );
        
        // Save user to Hive
        final user = User.fromJson(data['user_profile']);
        await HiveDB.saveUser(user);
        
        // Show success
        showSnackbar(context, 'Login successful');
        
        // Navigate to home
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        showSnackbar(context, result['message'] ?? 'Login failed', isError: true);
      }
    }
  }
}