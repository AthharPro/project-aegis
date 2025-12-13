import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../core/constants.dart';
import 'models/incident_model.dart';
import '../core/secure_storage_adapter.dart';

// Task Name
const simplePeriodicTask = "simplePeriodicTask";

// 1. Top-Level Entry Point
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint("Native called background task: $task");

    try {
      // 2. Initialize necessary dependencies (Isolate is empty)
      
      // Load Env (assuming .env is an asset)
      await dotenv.load(fileName: ".env");
      
      // Init Hive
      if (!kIsWeb) {
        final appDocumentDir = await getApplicationDocumentsDirectory();
        Hive.init(appDocumentDir.path);
      }
      
      // Register Adapter
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(IncidentTypeAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(IncidentModelAdapter());
      }

      // Open Box
      final box = await Hive.openBox<IncidentModel>(AppConstants.incidentBoxName);

      // Init Supabase
      // Note: We might not have a session in background if strictly relying on memory, 
      // but SecureStorageAdapter should handle it if implemented correctly.
      // However, for pure data upload, we often assume we might need to refresh token or just try.
      await Supabase.initialize(
        url: AppConstants.supabaseUrl,
        anonKey: AppConstants.supabaseAnonKey,
        authOptions: FlutterAuthClientOptions(
           authFlowType: AuthFlowType.implicit,
           localStorage: SecureStorageAdapter(),
        ),
      );

      final supabase = Supabase.instance.client;

      // 3. Perform Sync
      final pendingEvents = box.values.where((e) => !e.synced).toList();
      
      if (pendingEvents.isEmpty) {
        debugPrint("Background Sync: No pending items");
        return Future.value(true);
      }

      debugPrint("Background Sync: Found ${pendingEvents.length} pending items");

      int successCount = 0;
      for (final incident in pendingEvents) {
        try {
          final data = incident.toSupabaseMap();
          await supabase.from('incident_reports').insert(data);
          
          // Mark synced
          incident.synced = true;
          await incident.save();
          successCount++;
        } catch (e) {
          debugPrint("Background Sync Failed for ${incident.id}: $e");
        }
      }

      debugPrint("Background Sync Completed: $successCount synced");

    } catch (e) {
      debugPrint("Background Task Error: $e");
      return Future.value(false);
    }

    return Future.value(true);
  });
}
