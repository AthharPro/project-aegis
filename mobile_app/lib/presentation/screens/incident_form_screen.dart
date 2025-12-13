import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/network_utils.dart';
import '../../data/local/hive_service.dart';
import '../../data/models/incident_model.dart';
import '../../data/sync_service.dart';
import '../widgets/offline_status_banner.dart';
import 'pending_reports_screen.dart';
import 'login_screen.dart';
import 'pending_reports_screen.dart';
import 'local_data_screen.dart';
import 'login_screen.dart';
import '../../data/remote/supabase_service.dart';

class IncidentFormScreen extends StatefulWidget {
  const IncidentFormScreen({super.key});

  @override
  State<IncidentFormScreen> createState() => _IncidentFormScreenState();
}

class _IncidentFormScreenState extends State<IncidentFormScreen> with WidgetsBindingObserver {
  final _hiveService = GetIt.I<HiveService>();
  final _networkUtils = GetIt.I<NetworkUtils>();
  final _syncService = GetIt.I<SyncService>();
  final _supabaseService = GetIt.I<SupabaseService>();

  IncidentType _selectedType = IncidentType.landslide;
  int _severity = 1;
  int? _victimCount;
  bool _isLoading = false;
  bool _isConnected = true;

  Position? _lastPosition;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // 1. Start Live Location Tracking (Non-blocking)
    if (!kIsWeb) {
      Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          distanceFilter: 10, // Update every 10 meters
        ),
      ).listen((position) {
        if (mounted) _lastPosition = position;
      });
    }

    _networkUtils.connectionStream.listen((connected) {
      if (mounted) setState(() => _isConnected = connected);
      if (connected) {
        // Sync immediately when connected
        _syncService.syncPendingIncidents();
      }
    });
    _checkInitialConnection();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Trigger sync when app comes to foreground
      if (_isConnected) {
        _syncService.syncPendingIncidents();
      }
    }
  }

  void _checkInitialConnection() async {
    final connected = await _networkUtils.isConnected;
    if (mounted) setState(() => _isConnected = connected);
    if (connected) _syncService.syncPendingIncidents();
  }

  Future<void> _submitReport() async {
    // 1. Immediate UI Feedback
    setState(() => _isLoading = true);

    try {
      // 2. ZERO-DELAY LOCATION STRATEGY
      // Use the cached live position. If null, try last known. If that's null, default to 0,0.
      // We DO NOT await getCurrentPosition() here because it blocks the "Instant Save".
      
      Position? finalPosition = _lastPosition;
      if (finalPosition == null && !kIsWeb) {
        finalPosition = await Geolocator.getLastKnownPosition();
      }
      
      final incident = IncidentModel(
        id: const Uuid().v4(),
        type: _selectedType,
        severity: _severity,
        latitude: finalPosition?.latitude ?? 0.0,
        longitude: finalPosition?.longitude ?? 0.0,
        createdAt: DateTime.now(),
        synced: false,
        userId: _supabaseService.currentUser?.id ?? '',
        victimCount: _victimCount,
      );

      // 3. INTERNAL HIVE SAVE (Fast)
      await _hiveService.saveIncident(incident);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Saved offline! Syncing...'),
            duration: Duration(seconds: 1),
            backgroundColor: Colors.green,
          ),
        );
        
        // Reset form immediately
        setState(() {
          _severity = 1;
          _selectedType = IncidentType.landslide;
          _victimCount = null;
        });
      }

      // 4. BACKGROUND SYNC TRIGGER
      if (_isConnected) {
         _syncService.syncPendingIncidents();
      }

    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Incident'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PendingReportsScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.storage),
            tooltip: 'View Hive Data',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LocalDataScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _supabaseService.signOut();
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          OfflineStatusBanner(isConnected: _isConnected),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Incident Type', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  DropdownButtonFormField<IncidentType>(
                    value: _selectedType,
                    items: IncidentType.values.map((type) {
                      String label;
                      switch (type) {
                        case IncidentType.landslide: label = 'Landslide'; break;
                        case IncidentType.flood: label = 'Flood'; break;
                        case IncidentType.roadBlock: label = 'Road Block'; break;
                        case IncidentType.powerLineDown: label = 'Power Line Down'; break;
                      }
                      return DropdownMenuItem(
                        value: type,
                        child: Text(label),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedType = val);
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  const Text('Severity (1-5)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Slider(
                    value: _severity.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: _severity.toString(),
                    onChanged: (val) => setState(() => _severity = val.toInt()),
                  ),

                  const SizedBox(height: 24),
                  
                  const Text('Victim Count (Optional)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Enter number of victims',
                      prefixIcon: Icon(Icons.people),
                    ),
                    onChanged: (val) => setState(() => _victimCount = int.tryParse(val)),
                  ),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _submitReport,
                      icon: const Icon(Icons.send),
                      label: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('SUBMIT REPORT'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isConnected ? Colors.red : Colors.orange,
                        padding: const EdgeInsets.all(20),
                      ),
                    ),
                  ),
                  if (!_isConnected)
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Center(
                        child: Text(
                          'Will sync automatically when online',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
