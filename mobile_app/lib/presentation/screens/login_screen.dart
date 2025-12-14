import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/remote/supabase_service.dart';
import 'incident_form_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _supabaseService = GetIt.I<SupabaseService>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  void _checkSession() {
    if (_supabaseService.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const IncidentFormScreen()),
        );
      });
    }
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      final response = await _supabaseService.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (response.user != null) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const IncidentFormScreen()),
          );
        }
      }
    } on AuthException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login failed')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signUp() async {
    setState(() => _isLoading = true);
    try {
      final response = await _supabaseService.signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (response.user != null) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account created! Please log in.')),
          );
        }
      }
    } on AuthException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sign up failed')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              
              // Medical Icon/Logo
              Icon(
                Icons.medical_services_rounded,
                size: 64,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 16),
              
              // Title
              Text(
                'Emergency Response',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              // Subtitle
              Text(
                'Field Responder Portal',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              
              // Email Field
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              
              // Password Field
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 24),
              
              // Login Button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading 
                     ? const SizedBox(
                         height: 24,
                         width: 24,
                         child: CircularProgressIndicator(
                           color: Colors.white,
                           strokeWidth: 3,
                         ),
                       )
                     : const Text('LOGIN'),
                ),
              ),
              
              
              const SizedBox(height: 16),
              
              // Info Text
              Text(
                'Secure access for authorized field responders only',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                ),
              ),
              
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
