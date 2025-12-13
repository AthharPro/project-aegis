// lib/widgets/loading.dart
import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  final String? message;
  
  const LoadingScreen({super.key, this.message});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            if (message != null) ...[
              const SizedBox(height: 20),
              Text(
                message!,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }
}