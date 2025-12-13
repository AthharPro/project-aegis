import 'package:flutter/material.dart';
import '../../data/local/hive_service.dart';
import '../../data/models/incident_model.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

class SyncStatusScreen extends StatefulWidget {
  const SyncStatusScreen({super.key});

  @override
  State<SyncStatusScreen> createState() => _SyncStatusScreenState();
}

class _SyncStatusScreenState extends State<SyncStatusScreen> {
  final _hiveService = GetIt.I<HiveService>();
  List<IncidentModel> _allIncidents = [];

  @override
  void initState() {
    super.initState();
    _loadIncidents();
  }

  void _loadIncidents() {
    setState(() {
      _allIncidents = _hiveService.getAllIncidents();
    });
  }

  Future<void> _refresh() async {
    _loadIncidents();
  }

  IconData _getIncidentIcon(IncidentType type) {
    switch (type) {
      case IncidentType.landslide:
        return Icons.landscape;
      case IncidentType.flood:
        return Icons.water_damage;
      case IncidentType.roadBlock:
        return Icons.block;
      case IncidentType.powerLineDown:
        return Icons.power_off;
    }
  }

  String _getIncidentLabel(IncidentType type) {
    switch (type) {
      case IncidentType.landslide:
        return 'Landslide';
      case IncidentType.flood:
        return 'Flood';
      case IncidentType.roadBlock:
        return 'Road Block';
      case IncidentType.powerLineDown:
        return 'Power Line Down';
    }
  }

  String _getSeverityLabel(int severity) {
    switch (severity) {
      case 1:
        return 'Low';
      case 2:
        return 'Minor';
      case 3:
        return 'Moderate';
      case 4:
        return 'Severe';
      case 5:
        return 'Critical';
      default:
        return 'Unknown';
    }
  }

  Color _getSeverityColor(int severity) {
    switch (severity) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.lightGreen;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.deepOrange;
      case 5:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync Status'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _allIncidents.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_done,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No incidents reported yet',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _allIncidents.length,
                itemBuilder: (context, index) {
                  final incident = _allIncidents[index];
                  final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Row
                          Row(
                            children: [
                              // Incident Icon
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  _getIncidentIcon(incident.type),
                                  color: Theme.of(context).primaryColor,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 12),
                              
                              // Incident Type and Time
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _getIncidentLabel(incident.type),
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      dateFormat.format(incident.createdAt.toLocal()),
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Colors.grey[600],
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Sync Status Icon
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: incident.synced
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  incident.synced
                                      ? Icons.cloud_done
                                      : Icons.cloud_upload,
                                  color: incident.synced ? Colors.green : Colors.orange,
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          const Divider(height: 1),
                          const SizedBox(height: 16),
                          
                          // Details Row
                          Row(
                            children: [
                              // Severity
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Severity',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Colors.grey[600],
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getSeverityColor(incident.severity).withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        _getSeverityLabel(incident.severity),
                                        style: TextStyle(
                                          color: _getSeverityColor(incident.severity),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Victim Count
                              if (incident.victimCount != null)
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Victims',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Colors.grey[600],
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.people,
                                            size: 18,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${incident.victimCount}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Sync Status Text
                          Row(
                            children: [
                              Icon(
                                incident.synced ? Icons.check_circle : Icons.schedule,
                                size: 16,
                                color: incident.synced ? Colors.green : Colors.orange,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                incident.synced
                                    ? 'Synced to cloud'
                                    : 'Stored locally - pending sync',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: incident.synced ? Colors.green : Colors.orange,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
