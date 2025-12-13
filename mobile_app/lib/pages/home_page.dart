// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:mobile_app/db/models.dart';
import '../widgets/button.dart';
import '../utils.dart';
import '../db/secure_storage.dart';
import '../db/hive_db.dart';
import '../api/api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late User? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    _user = HiveDB.getCurrentUser();
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Disaster Relief'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome
            Text(
              'Welcome, ${_user?.name ?? 'User'}!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              _user?.email ?? '',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Text(
              'Role: ${_user?.role ?? ''}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),

            // Actions
            AppButton(
              text: 'Report Disaster',
              onPressed: () {
                Navigator.pushNamed(context, '/report');
              },
            ),
            const SizedBox(height: 15),

            AppButton(
              text: 'Pending Reports',
              onPressed: () {
                final pending = HiveDB.getPendingReports();
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Pending Reports'),
                    content: Text('${pending.length} reports pending sync'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
              color: Colors.orange,
            ),
            const SizedBox(height: 15),

            AppButton(
              text: 'Sync Now',
              onPressed: () async {
                // TODO: Implement sync
                showSnackbar(context, 'Syncing...');
              },
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    await SecureStorage.clearAll();
    await HiveDB.clearAll();
    Navigator.pushReplacementNamed(context, '/');
  }
}