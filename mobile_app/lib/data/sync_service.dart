import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:cross_file/cross_file.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
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
    debugPrint('Sync started (Parallel Mode)...');

    try {
      final pendingEvents = _hiveService.getPendingIncidents();
      if (pendingEvents.isEmpty) {
        debugPrint('Sync: No pending items');
        return;
      }

      // Process all incidents in parallel
      final results = await Future.wait(
        pendingEvents.map((incident) => _processIncident(incident)),
      );

      final successCount = results.where((success) => success).length;
      debugPrint('Sync completed: $successCount / ${pendingEvents.length} synced');
    } catch (e) {
      debugPrint('Sync error: $e');
    } finally {
      _isSyncingNotifier.value = false;
    }
  }

  Future<bool> _processIncident(dynamic incident) async {
    try {
      // Step 1: Upload Image if needed
      if (incident.localImagePath != null && incident.localImagePath!.isNotEmpty) {
        if (incident.supabaseImageUrl == null || incident.supabaseImageUrl!.isEmpty) {
          try {
            final xFile = XFile(incident.localImagePath!);
            final rawBytes = await xFile.readAsBytes();
            
            if (rawBytes.isNotEmpty) {
              // Try to compress
              Uint8List uploadBytes = rawBytes;
              try {
                final compressed = await FlutterImageCompress.compressWithList(
                  rawBytes,
                  minHeight: 1080,
                  minWidth: 1080,
                  quality: 85,
                );
                if (compressed.isNotEmpty) {
                  uploadBytes = compressed;
                  debugPrint('Compressed image: ${rawBytes.length} -> ${compressed.length} bytes');
                }
              } catch (e) {
                debugPrint('Compression failed, using raw bytes: $e');
              }

              final fileName = '${incident.id}.jpg';
              debugPrint('Sync: Uploading image $fileName (${uploadBytes.length} bytes)...');
              final publicUrl = await _supabaseService.uploadImageBytes(uploadBytes, fileName);
              
              if (publicUrl != null) {
                incident.supabaseImageUrl = publicUrl; 
                await incident.save();
                debugPrint('Image uploaded for ${incident.id}: $publicUrl');
              } else {
                 debugPrint('Failed to upload image for ${incident.id}. Skipping data sync.');
                 return false;
              }
            }
          } catch (e) {
             debugPrint('Error reading/uploading image for ${incident.id}: $e');
             // Proceeding without image if read failed, preserving existing data behavior
          }
        }
      }

      // Step 2: Upload Data
      final data = incident.toSupabaseMap();
      final success = await _supabaseService.uploadIncident(data);
      
      if (success) {
        await _hiveService.markAsSynced(incident.id);
        return true;
      }
    } catch (e) {
      debugPrint('Error syncing incident ${incident.id}: $e');
    }
    return false;
  }
}
