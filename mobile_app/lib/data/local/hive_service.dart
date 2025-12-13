import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants.dart';
import '../models/incident_model.dart';

class HiveService {
  late Box<IncidentModel> _incidentBox;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(IncidentTypeAdapter());
    Hive.registerAdapter(IncidentModelAdapter());
    _incidentBox = await Hive.openBox<IncidentModel>(AppConstants.incidentBoxName);
  }

  // Save or Update Incident
  Future<void> saveIncident(IncidentModel incident) async {
    await _incidentBox.put(incident.id, incident);
  }

  // Get Incidents waiting for sync
  List<IncidentModel> getPendingIncidents() {
    return _incidentBox.values.where((incident) => !incident.synced).toList();
  }

  // Get All Incidents (sorted by date desc)
  List<IncidentModel> getAllIncidents() {
    final incidents = _incidentBox.values.toList();
    incidents.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return incidents;
  }

  // Mark incident as synced
  Future<void> markAsSynced(String id) async {
    final incident = _incidentBox.get(id);
    if (incident != null) {
      incident.synced = true;
      await incident.save(); // HiveObject method
    }
  }

  // Delete incident (optional, for cleanup)
  Future<void> deleteIncident(String id) async {
    await _incidentBox.delete(id);
  }
  
  // Clear all (for logout or debug)
  Future<void> clearAll() async {
    await _incidentBox.clear();
  }
}
