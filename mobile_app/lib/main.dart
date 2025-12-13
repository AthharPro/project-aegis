import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'db/hive_db.dart';
import 'db/secure_storage.dart';
import 'api/auth_service.dart';
import 'constants.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
// import 'pages/disaster_form_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('═══════════════════════════════════════════════════════');
  print('🚀 PROJECT AEGIS - Field Responder App');
  print('═══════════════════════════════════════════════════════');

  // Set portrait mode
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  print('✅ Device orientation set to portrait');

  // Initialize Hive
  print('\n📦 Initializing Hive Database...');
  await HiveDB.init();
  print('✅ Hive Database initialized');

  // Initialize Supabase with proper storage support
  print('\n🔌 Initializing Supabase...');
  print('   URL: $SUPABASE_URL');
  print('   Auth Key: ${SUPABASE_ANON_KEY.substring(0, 20)}...');

  try {
    await Supabase.initialize(url: SUPABASE_URL, anonKey: SUPABASE_ANON_KEY);
    print('✅ Supabase initialized successfully!');

    // Set AuthService client
    AuthService.setClient(Supabase.instance.client);
    print('✅ AuthService client configured');

    // Verify connection
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      print('ℹ️  No user currently logged in');
    } else {
      print('✅ User already logged in: ${currentUser.email}');
    }

    print('\n═══════════════════════════════════════════════════════');
    print('🟢 App Ready! User is ready to register/login');
    print('═══════════════════════════════════════════════════════\n');
  } catch (e) {
    print('❌ Supabase initialization failed: $e');
    print('═══════════════════════════════════════════════════════\n');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Disaster Relief',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: FutureBuilder<bool>(
        future: SecureStorage.isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return snapshot.data == true ? const HomePage() : const LoginPage();
        },
      ),
      routes: {
        '/home': (context) => const HomePage(),
        // '/report': (context) => const DisasterFormPage(),
      },
    );
  }
}
