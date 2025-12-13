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
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
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
        title: const Text('New Incident'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_sync),
            tooltip: 'Sync Status',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SyncStatusScreen()),
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
                _buildIncidentTypePage(),
                _buildSeverityPage(),
                _buildVictimCountPage(),
                _buildSummaryPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Page 1: Incident Type Selection
  Widget _buildIncidentTypePage() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Incident Type',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Choose the type of emergency you are reporting',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildIncidentTile(
                  type: IncidentType.landslide,
                  icon: Icons.landscape,
                  label: 'Landslide',
                  color: Colors.brown,
                ),
                _buildIncidentTile(
                  type: IncidentType.flood,
                  icon: Icons.water_damage,
                  label: 'Flood',
                  color: Colors.blue,
                ),
                _buildIncidentTile(
                  type: IncidentType.roadBlock,
                  icon: Icons.block,
                  label: 'Road Block',
                  color: Colors.orange,
                ),
                _buildIncidentTile(
                  type: IncidentType.powerLineDown,
                  icon: Icons.power_off,
                  label: 'Power Line Down',
                  color: Colors.red,
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildIncidentTile({
    required IncidentType type,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final isSelected = _selectedType == type;
    
    return InkWell(
      onTap: () {
        setState(() => _selectedType = type);
        // Auto-redirect to next page after selection
        Future.delayed(const Duration(milliseconds: 300), () {
          _nextPage();
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.secondary.withOpacity(0.1)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.secondary
                : Colors.transparent,
            width: 3,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: isSelected ? Theme.of(context).colorScheme.secondary : color,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Theme.of(context).colorScheme.secondary : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Page 2: Severity Selection with Vertical Tiles
  Widget _buildSeverityPage() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Severity Level',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Select the severity of the incident',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 16),
          
          // Vertical Severity Tiles
          Expanded(
            child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildSeverityTile(
                  level: 5,
                  label: 'Critical',
                  icon: Icons.warning,
                  color: Colors.red,
                ),
                const SizedBox(height: 10),
                _buildSeverityTile(
                  level: 4,
                  label: 'Severe',
                  icon: Icons.error_outline,
                  color: Colors.deepOrange,
                ),
                const SizedBox(height: 10),
                _buildSeverityTile(
                  level: 3,
                  label: 'Moderate',
                  icon: Icons.warning_amber,
                  color: Colors.orange,
                ),
                const SizedBox(height: 10),
                _buildSeverityTile(
                  level: 2,
                  label: 'Minor',
                  icon: Icons.info_outline,
                  color: Colors.lightGreen,
                ),
                const SizedBox(height: 10),
                _buildSeverityTile(
                  level: 1,
                  label: 'Low',
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Back Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _previousPage,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: Theme.of(context).primaryColor),
              ),
              child: const Text('BACK'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeverityTile({
    required int level,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _severity == level;
    
    return InkWell(
      onTap: () {
        setState(() => _severity = level);
        // Auto-redirect to next page after selection
        Future.delayed(const Duration(milliseconds: 300), () {
          _nextPage();
        });
      },
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.15)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 3,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? color : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Level $level',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  String _getSeverityLabel(int severity) {
    switch (severity) {
      case 1: return 'Low';
      case 2: return 'Minor';
      case 3: return 'Moderate';
      case 4: return 'Severe';
      case 5: return 'Critical';
      default: return 'Unknown';
    }
  }

  Color _getSeverityColor(int severity) {
    switch (severity) {
      case 1: return Colors.green;
      case 2: return Colors.lightGreen;
      case 3: return Colors.orange;
      case 4: return Colors.deepOrange;
      case 5: return Colors.red;
      default: return Colors.grey;
    }
  }

  // Page 3: Victim Count - Range Selection
  Widget _buildVictimCountPage() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Victim Count',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Select the approximate number of victims',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 16),
          
          // Vertical Range Tiles
          Expanded(
            child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildVictimRangeTile(
                  range: '0-10',
                  value: 5,
                  icon: Icons.person,
                  color: Colors.green,
                ),
                const SizedBox(height: 10),
                _buildVictimRangeTile(
                  range: '10-50',
                  value: 25,
                  icon: Icons.people,
                  color: Colors.orange,
                ),
                const SizedBox(height: 10),
                _buildVictimRangeTile(
                  range: '50-100',
                  value: 75,
                  icon: Icons.groups,
                  color: Colors.deepOrange,
                ),
                const SizedBox(height: 10),
                _buildVictimRangeTile(
                  range: '100+',
                  value: 105,
                  icon: Icons.group_add,
                  color: Colors.red,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Back Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _previousPage,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: Theme.of(context).primaryColor),
              ),
              child: const Text('BACK'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVictimRangeTile({
    required String range,
    required int value,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _victimCountInput == value.toString();
    
    return InkWell(
      onTap: () {
        setState(() => _victimCountInput = value.toString());
        // Auto-redirect to next page after selection
        Future.delayed(const Duration(milliseconds: 300), () {
          _nextPage();
        });
      },
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.15)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 3,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    range,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? color : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Victims',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  // Page 4: Summary
  Widget _buildSummaryPage() {
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
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 16),
          
          // Summary Cards
          _buildSummaryCard(
            title: 'Incident Type',
            value: _getIncidentLabel(_selectedType ?? IncidentType.landslide),
            icon: _getIncidentIcon(_selectedType ?? IncidentType.landslide),
            onEdit: () => _goToPage(0),
          ),
          const SizedBox(height: 12),
          
          _buildSummaryCard(
            title: 'Severity',
            value: _getSeverityLabel(_severity),
            icon: Icons.warning_amber,
            color: _getSeverityColor(_severity),
            onEdit: () => _goToPage(1),
          ),
          const SizedBox(height: 12),
          
          _buildSummaryCard(
            title: 'Victim Count',
            value: _victimCountInput.isEmpty ? 'Not specified' : _getVictimCountLabel(_victimCountInput),
            icon: Icons.people,
            onEdit: () => _goToPage(2),
          ),
          
          const Spacer(),
          
          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitReport,
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : const Text('SUBMIT REPORT'),
            ),
          ),
          
          const SizedBox(height: 12),
          
          if (!_isConnected)
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

  Widget _buildSummaryCard({
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
                color: (color ?? Theme.of(context).primaryColor).withOpacity(0.1),
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
      case IncidentType.landslide: return Icons.landscape;
      case IncidentType.flood: return Icons.water_damage;
      case IncidentType.roadBlock: return Icons.block;
      case IncidentType.powerLineDown: return Icons.power_off;
    }
  }

  String _getIncidentLabel(IncidentType type) {
    switch (type) {
      case IncidentType.landslide: return 'Landslide';
      case IncidentType.flood: return 'Flood';
      case IncidentType.roadBlock: return 'Road Block';
      case IncidentType.powerLineDown: return 'Power Line Down';
    }
  }

  String _getVictimCountLabel(String value) {
    final intValue = int.tryParse(value);
    if (intValue == null) return value;
    
    switch (intValue) {
      case 5: return '0-10';
      case 25: return '10-50';
      case 75: return '50-100';
      case 105: return '100+';
      default: return value;
    }
  }
}
