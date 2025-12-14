import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../../data/models/incident_model.dart';

class SummaryPage extends StatelessWidget {
  final IncidentType? selectedType;
  final int severity;
  final String victimCountInput;
  final bool isLoading;
  final bool isConnected;
  final VoidCallback onSubmit;
  final VoidCallback onEditType;
  final VoidCallback onEditSeverity;
  final VoidCallback onEditVictimCount;
  final VoidCallback onCancel;

  const SummaryPage({
    super.key,
    required this.selectedType,
    required this.severity,
    required this.victimCountInput,
    required this.isLoading,
    required this.isConnected,
    required this.onSubmit,
    required this.onEditType,
    required this.onEditSeverity,
    required this.onEditVictimCount,

    required this.onCancel,
    this.imagePath,
  });

  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review & Submit',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Please review your incident report',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.green[600],
                ),
          ),
          const SizedBox(height: 10),

          // Summary Cards
          _buildSummaryCard(
            context,
            title: 'Incident Type',
            value: _getIncidentLabel(selectedType ?? IncidentType.landslide),
            icon: _getIncidentIcon(selectedType ?? IncidentType.landslide),
            onEdit: onEditType,
          ),
          const SizedBox(height: 8),

          _buildSummaryCard(
            context,
            title: 'Severity',
            value: _getSeverityLabel(severity),
            icon: Icons.warning_amber,
            color: _getSeverityColor(severity),
            onEdit: onEditSeverity,
          ),
          const SizedBox(height: 8),

          _buildSummaryCard(
            context,
            title: 'Victim Count',
            value: victimCountInput.isEmpty
                ? 'Not specified'
                : _getVictimCountLabel(victimCountInput),
            icon: Icons.people,
            onEdit: onEditVictimCount,
          ),
          const SizedBox(height: 8),

          if (imagePath != null)
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Attached Image',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        height: 200,
                        width: double.infinity,
                        child: kIsWeb
                            ? Image.network(
                                imagePath!,
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                File(imagePath!),
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const Spacer(),

          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Theme.of(context).primaryColor),
                      foregroundColor: Theme.of(context).primaryColor,
                    ),
                    child: const Text('CANCEL', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : const Text('SUBMIT', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),

          // const SizedBox(height: 12),

          if (!isConnected)
            Center(
              child: Text(
                'Will sync automatically when online',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    Color? color,
    required VoidCallback onEdit,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color:
                    (color ?? Theme.of(context).primaryColor).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color ?? Theme.of(context).primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
              color: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
    );
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

  String _getVictimCountLabel(String value) {
    final intValue = int.tryParse(value);
    if (intValue == null) return value;

    switch (intValue) {
      case 5:
        return '0-10';
      case 25:
        return '10-50';
      case 75:
        return '50-100';
      case 105:
        return '100+';
      default:
        return value;
    }
  }
}
