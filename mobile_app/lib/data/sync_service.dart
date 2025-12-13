import 'package:flutter/foundation.dart';
import '../core/network_utils.dart';
import 'local/hive_service.dart';
import 'remote/supabase_service.dart';

class SyncService {
  final HiveService _hiveService;
  final SupabaseService _supabaseService;
  final NetworkUtils _networkUtils;
  
  final _isSyncingNotifier = ValueNotifier<bool>(false);
  ValueListenable<bool> get isSyncing => _isSyncingNotifier;

  SyncService(this._hiveService, this._supabaseService, this._networkUtils);

  // Main sync trigger
  Future<void> syncPendingIncidents() async {
    if (_isSyncingNotifier.value) return;
    
    final isConnected = await _networkUtils.isConnected;
    if (!isConnected) {
      debugPrint('Sync skipped: No connection');
      return;
    }

    _isSyncingNotifier.value = true;
    debugPrint('Sync started...');

    try {
      final pendingEvents = _hiveService.getPendingIncidents();
      if (pendingEvents.isEmpty) {
        debugPrint('Sync: No pending items');
        return;
      }

      int successCount = 0;
      for (final incident in pendingEvents) {
        final data = incident.toSupabaseMap();
        final success = await _supabaseService.uploadIncident(data);
        
        if (success) {
          await _hiveService.markAsSynced(incident.id);
          successCount++;
        }
      }
      debugPrint('Sync completed: $successCount / ${pendingEvents.length} synced');
    } catch (e) {
      debugPrint('Sync error: $e');
    } finally {
      _isSyncingNotifier.value = false;
    }
  }
}
