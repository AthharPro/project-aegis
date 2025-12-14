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
import 'sync_status_screen.dart';

import 'login_screen.dart';
import '../../data/remote/supabase_service.dart';
import '../widgets/incident_type_page.dart';
import '../widgets/severity_page.dart';
import '../widgets/victim_count_page.dart';
import '../widgets/summary_page.dart';

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
  final PageController _pageController = PageController();

  int _currentPage = 0;
  IncidentType? _selectedType;
  int _severity = 3; // Default to moderate
  String _victimCountInput = '';
  bool _isLoading = false;
  bool _isConnected = true;

  Position? _lastPosition;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Start Live Location Tracking (Non-blocking)
    if (!kIsWeb) {
      Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          distanceFilter: 10,
        ),
      ).listen((position) {
        if (mounted) _lastPosition = position;
      });
    }

    _networkUtils.connectionStream.listen((connected) {
      if (mounted) setState(() => _isConnected = connected);
      if (connected) {
        _syncService.syncPendingIncidents();
      }
    });
    _checkInitialConnection();
    _requestPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
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

  Future<void> _requestPermission() async {
    if (!kIsWeb) {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location denied forever');
      }
    }
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.jumpToPage(_currentPage + 1);
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.jumpToPage(_currentPage - 1);
    }
  }

  void _goToPage(int page) {
    _pageController.jumpToPage(page);
  }

  Future<void> _submitReport() async {
    setState(() => _isLoading = true);

    try {
      Position? finalPosition = _lastPosition;
      if (finalPosition == null && !kIsWeb) {
        finalPosition = await Geolocator.getLastKnownPosition();
      }
      
      final incident = IncidentModel(
        id: const Uuid().v4(),
        type: _selectedType!,
        severity: _severity,
        latitude: finalPosition?.latitude ?? 0.0,
        longitude: finalPosition?.longitude ?? 0.0,
        createdAt: DateTime.now(),
        synced: false,
        userId: _supabaseService.currentUser?.id ?? '',
        victimCount: _victimCountInput.isNotEmpty ? int.tryParse(_victimCountInput) : null,
      );

      await _hiveService.saveIncident(incident);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Saved offline! Syncing...'),
            duration: Duration(seconds: 1),
            backgroundColor: Colors.green,
          ),
        );
        
        // Reset form
        setState(() {
          _severity = 3;
          _selectedType = null;
          _victimCountInput = '';
          _currentPage = 0;
        });
        _pageController.jumpToPage(0);
      }

      if (_isConnected) {
         _syncService.syncPendingIncidents();
      }

    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index
                ? Theme.of(context).colorScheme.secondary
                : Colors.grey[300],
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             
            Text(
              _supabaseService.currentUser?.userMetadata?['full_name'] ?? 'Responder',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_sync),
            tooltip: 'Sync Status',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SyncStatusScreen()),
            ),
          ),

          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('CANCEL'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('LOGOUT'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                await _supabaseService.signOut();
                if (mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          OfflineStatusBanner(isConnected: _isConnected),
          
          // Page Indicator
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: _buildPageIndicator(),
          ),
          
          // Page View
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (page) {
                setState(() => _currentPage = page);
              },
              children: [
                IncidentTypePage(
                  selectedType: _selectedType,
                  onTypeSelected: (type) {
                    setState(() => _selectedType = type);
                    _nextPage();
                  },
                ),
                SeverityPage(
                  severity: _severity,
                  onSeveritySelected: (level) {
                    setState(() => _severity = level);
                    _nextPage();
                  },
                  onBack: _previousPage,
                ),
                VictimCountPage(
                  victimCountInput: _victimCountInput,
                  onVictimCountSelected: (value) {
                    setState(() => _victimCountInput = value);
                    _nextPage();
                  },
                  onBack: _previousPage,
                ),
                SummaryPage(
                  selectedType: _selectedType,
                  severity: _severity,
                  victimCountInput: _victimCountInput,
                  isLoading: _isLoading,
                  isConnected: _isConnected,
                  onSubmit: _submitReport,
                  onEditType: () => _goToPage(0),
                  onEditSeverity: () => _goToPage(1),
                  onEditVictimCount: () => _goToPage(2),
                  onCancel: () => _goToPage(0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


}
