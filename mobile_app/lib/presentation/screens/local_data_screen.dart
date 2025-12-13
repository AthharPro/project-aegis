import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants.dart';
import '../../data/models/incident_model.dart';

class LocalDataScreen extends StatelessWidget {
  const LocalDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Hive Data'),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<IncidentModel>(AppConstants.incidentBoxName).listenable(),
        builder: (context, Box<IncidentModel> box, _) {
          final incidents = box.values.toList().cast<IncidentModel>();

          if (incidents.isEmpty) {
            return const Center(child: Text('No local data found'));
          }

          // Sort by newest first
          incidents.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return ListView.builder(
            itemCount: incidents.length,
            itemBuilder: (context, index) {
              final incident = incidents[index];
              return Card(
                color: incident.synced ? Colors.green[50] : Colors.orange[50],
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(incident.type.name.toUpperCase()),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ID: ${incident.id.substring(0, 8)}...'),
                      Text('Time: ${incident.createdAt}'),
                      Text('Severity: ${incident.severity}'),
                      Text('User: ${incident.userId}'),
                    ],
                  ),
                  trailing: Icon(
                    incident.synced ? Icons.cloud_done : Icons.cloud_off,
                    color: incident.synced ? Colors.green : Colors.orange,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
