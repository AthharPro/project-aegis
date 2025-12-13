import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../data/sync_service.dart';

class OfflineStatusBanner extends StatefulWidget {
  final bool isConnected;

  const OfflineStatusBanner({super.key, required this.isConnected});

  @override
  State<OfflineStatusBanner> createState() => _OfflineStatusBannerState();
}

class _OfflineStatusBannerState extends State<OfflineStatusBanner> {
  final _syncService = GetIt.I<SyncService>();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _syncService.isSyncing,
      builder: (context, isSyncing, _) {
        if (isSyncing) {
          return Container(
            width: double.infinity,
            color: Colors.blue,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                ),
                SizedBox(width: 8),
                Text(
                  'Syncing data...',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        }

        if (widget.isConnected) return const SizedBox.shrink();

        return Container(
          width: double.infinity,
          color: Colors.black87,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off, color: Colors.white, size: 16),
              SizedBox(width: 8),
              Text(
                'YOU ARE OFFLINE - Data will save locally',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }
}
