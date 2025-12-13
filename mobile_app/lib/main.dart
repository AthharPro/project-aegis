import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'db/hive_db.dart';
import 'db/secure_storage.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
// import 'pages/disaster_form_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  
  // Initialize Hive
  await HiveDB.init();
  
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
        '/': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        // '/report': (context) => const DisasterFormPage(),
      },
    );
  }
}