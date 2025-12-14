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

  Future<void> _confirmClearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History?'),
        content: const Text('This will delete all local history of your reports. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('CLEAR ALL'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _hiveService.clearAll();
      _loadIncidents();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('History cleared')),
        );
      }
    }
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
        return 'High';
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
    final pendingCount = _allIncidents.where((i) => !i.synced).length;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Report History'),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (_allIncidents.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Clear History',
              onPressed: _confirmClearHistory,
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Column(
          children: [
            // Status Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: pendingCount > 0 ? Colors.orange[50] : Colors.green[50],
              child: Row(
                children: [
                   Icon(
                    pendingCount > 0 ? Icons.sync_problem : Icons.check_circle,
                    color: pendingCount > 0 ? Colors.orange : Colors.green,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    pendingCount > 0 
                      ? '$pendingCount reports waiting to sync'
                      : 'All reports synced',
                    style: TextStyle(
                      color: pendingCount > 0 ? Colors.orange[800] : Colors.green[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: _allIncidents.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No reports history',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                        final dateFormat = DateFormat('MMM dd, hh:mm a');

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: Border.all(
                              color: incident.synced ? Colors.transparent : Colors.orange.withOpacity(0.3),
                            )
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getIncidentIcon(incident.type),
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            title: Text(
                              _getIncidentLabel(incident.type),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text(
                                      dateFormat.format(incident.createdAt.toLocal()),
                                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: _getSeverityColor(incident.severity).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        _getSeverityLabel(incident.severity),
                                        style: TextStyle(
                                          color: _getSeverityColor(incident.severity),
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  incident.synced ? Icons.cloud_done : Icons.cloud_upload,
                                  color: incident.synced ? Colors.green : Colors.orange,
                                  size: 20,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  incident.synced ? 'Synced' : 'Pending',
                                  style: TextStyle(
                                    color: incident.synced ? Colors.green : Colors.orange,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
