import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get_it/get_it.dart';

import 'core/constants.dart';
import 'core/theme.dart';
import 'core/network_utils.dart';
import 'data/local/hive_service.dart';
import 'data/remote/supabase_service.dart';
import 'data/sync_service.dart';
import 'core/secure_storage_adapter.dart';
import 'presentation/screens/splash_screen.dart';

import 'package:workmanager/workmanager.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'data/background_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 0. Init Workmanager (Mobile Only)
  if (!kIsWeb) {
    try {
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: true, // TODO: Set false for production
      );
      // Register immediate or periodic task
      await Workmanager().registerPeriodicTask(
        "1", 
        simplePeriodicTask, 
        frequency: const Duration(minutes: 15),
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
      );
    } catch (e) {
      debugPrint('Workmanager init failed: $e');
    }
  }

  // 1. Load Env
  await dotenv.load(fileName: ".env");

  // 2. Init Supabase
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
    authOptions: FlutterAuthClientOptions(
      authFlowType: AuthFlowType.implicit,
      localStorage: SecureStorageAdapter(),
    ),
  );

  // 3. Init Services & DI
  final hiveService = HiveService();
  await hiveService.init();
  GetIt.I.registerSingleton<HiveService>(hiveService);

  final supabaseService = SupabaseService();
  GetIt.I.registerSingleton<SupabaseService>(supabaseService);

  final networkUtils = NetworkUtils();
  GetIt.I.registerSingleton<NetworkUtils>(networkUtils);

  final syncService = SyncService(hiveService, supabaseService, networkUtils);
  GetIt.I.registerSingleton<SyncService>(syncService);

  // 4. Run App
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Disaster Responder',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
