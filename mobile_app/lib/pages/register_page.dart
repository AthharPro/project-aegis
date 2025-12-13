// lib/pages/register_page.dart
import 'package:flutter/material.dart';
import '../api/auth_service.dart';
import '../utils.dart';
import '../widgets/input_field.dart';
import '../widgets/button.dart' as widgets;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _nicController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Form validation
  bool _validateEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+').hasMatch(email);
  }

  bool _validatePassword(String password) {
    // At least 6 characters, 1 uppercase, 1 number
    return password.length >= 6 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password);
  }

  bool _validateNIC(String nic) {
    // Sri Lanka NIC format: 123456789V or 12345678901
    return RegExp(r'^\d{9}[V|v]$|^\d{12}$').hasMatch(nic);
  }

  bool _validatePhone(String phone) {
    // 10-15 digits
    return RegExp(
      r'^\d{10,15}$',
    ).hasMatch(phone.replaceAll(RegExp(r'[^\d]'), ''));
  }

  bool _validateForm() {
    if (_fullNameController.text.isEmpty) {
      showSnackbar(context, 'Please enter your full name', isError: true);
      return false;
    }

    if (_emailController.text.isEmpty) {
      showSnackbar(context, 'Please enter your email', isError: true);
      return false;
    }

    if (!_validateEmail(_emailController.text)) {
      showSnackbar(context, 'Please enter a valid email', isError: true);
      return false;
    }

    if (_nicController.text.isEmpty) {
      showSnackbar(context, 'Please enter your NIC', isError: true);
      return false;
    }

    if (!_validateNIC(_nicController.text)) {
      showSnackbar(
        context,
        'Invalid NIC format (e.g., 123456789V or 12345678901)',
        isError: true,
      );
      return false;
    }

    if (_phoneController.text.isEmpty) {
      showSnackbar(context, 'Please enter your phone number', isError: true);
      return false;
    }

    if (!_validatePhone(_phoneController.text)) {
      showSnackbar(
        context,
        'Please enter a valid phone number (10-15 digits)',
        isError: true,
      );
      return false;
    }

    if (_passwordController.text.isEmpty) {
      showSnackbar(context, 'Please enter a password', isError: true);
      return false;
    }

    if (!_validatePassword(_passwordController.text)) {
      showSnackbar(
        context,
        'Password must be at least 6 characters with 1 uppercase letter and 1 number',
        isError: true,
      );
      return false;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      showSnackbar(context, 'Passwords do not match', isError: true);
      return false;
    }

    return true;
  }

  Future<void> _register() async {
    if (!_validateForm()) {
      return;
    }

    setState(() => _isLoading = true);

    final result = await AuthService.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      fullName: _fullNameController.text.trim(),
      nic: _nicController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      showSnackbar(context, 'Registration successful! Please log in.');

      // Clear fields
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
      _fullNameController.clear();
      _nicController.clear();
      _phoneController.clear();

      // Navigate to login
      if (mounted) {
        Navigator.of(context).pop();
      }
    } else {
      showSnackbar(context, result['message'], isError: true);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _nicController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Create Account',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Fill in your details to register',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),

            // Full Name
            InputField(
              label: 'Full Name',
              controller: _fullNameController,
              icon: Icons.person,
            ),
            const SizedBox(height: 16),

            // Email
            InputField(
              label: 'Email',
              controller: _emailController,
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            // NIC
            InputField(
              label: 'NIC (National ID Card)',
              controller: _nicController,
              icon: Icons.credit_card,
            ),
            const SizedBox(height: 8),
            Text(
              'Format: 9 digits + V (e.g., 123456789V or 12345678901)',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
            const SizedBox(height: 16),

            // Phone Number
            InputField(
              label: 'Phone Number',
              controller: _phoneController,
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            // Password
            InputField(
              label: 'Password',
              controller: _passwordController,
              icon: Icons.lock,
              obscureText: _obscurePassword,
            ),
            const SizedBox(height: 8),
            Text(
              'Min 6 characters, 1 uppercase, 1 number',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
            const SizedBox(height: 16),

            // Confirm Password
            InputField(
              label: 'Confirm Password',
              controller: _confirmPasswordController,
              icon: Icons.lock,
              obscureText: _obscureConfirmPassword,
            ),
            const SizedBox(height: 32),

            // Register Button
            widgets.AppButton(
              text: _isLoading ? 'Creating Account...' : 'Register',
              onPressed: _isLoading ? () {} : _register,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 16),

            // Login Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account? ',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  child: const Text('Login'),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
