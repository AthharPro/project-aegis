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
      appBar: AppBar(title: const Text('Field Responder Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
             TextField(
               controller: _emailController,
               decoration: const InputDecoration(labelText: 'Email'),
               keyboardType: TextInputType.emailAddress,
             ),
             const SizedBox(height: 16),
             TextField(
               controller: _passwordController,
               decoration: const InputDecoration(labelText: 'Password'),
               obscureText: true,
             ),
             const SizedBox(height: 24),
             SizedBox(
               width: double.infinity,
               child: ElevatedButton(
                 onPressed: _isLoading ? null : _login,
                 child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text('LOGIN'),
               ),
             ),
             const SizedBox(height: 12),
             TextButton(
               onPressed: _isLoading ? null : _signUp,
               child: const Text('Create Account'),
             )
          ],
        ),
      ),
    );
  }
}
