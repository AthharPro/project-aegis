import 'package:flutter/material.dart';
import '../../data/local/hive_service.dart';
import '../../data/models/incident_model.dart';
import 'package:get_it/get_it.dart';

class PendingReportsScreen extends StatefulWidget {
  const PendingReportsScreen({super.key});

  @override
  State<PendingReportsScreen> createState() => _PendingReportsScreenState();
}

class _PendingReportsScreenState extends State<PendingReportsScreen> {
  final _hiveService = GetIt.I<HiveService>();
  List<IncidentModel> _pendingIncidents = [];

  @override
  void initState() {
    super.initState();
    _loadPending();
  }

  void _loadPending() {
    setState(() {
      _pendingIncidents = _hiveService.getPendingIncidents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pending Reports')),
      body: _pendingIncidents.isEmpty
          ? const Center(child: Text('All caught up! No pending reports.'))
          : ListView.builder(
              itemCount: _pendingIncidents.length,
              itemBuilder: (context, index) {
                final incident = _pendingIncidents[index];
                return ListTile(
                  leading: const Icon(Icons.sync_problem, color: Colors.orange),
                  title: Text(incident.type.name.toUpperCase()),
                  subtitle: Text('Severity: ${incident.severity} • ${incident.createdAt.toLocal()}'),
                  trailing: const Icon(Icons.cloud_off),
                );
              },
            ),
    );
  }
}
