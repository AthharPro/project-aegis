// lib/db/hive_db.dart
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../constants.dart';
import 'models.dart';

class HiveDB {
  static late Box<User> userBox;
  static late Box<DisasterReport> pendingReportsBox;
  
  // Initialize Hive
  static Future<void> init() async {
    final appDir = await getApplicationDocumentsDirectory();
    Hive.init(appDir.path);
    
    // Register adapters
    // Hive.registerAdapter(UserAdapter());
    // Hive.registerAdapter(DisasterReportAdapter());
    
    // Open boxes
    userBox = await Hive.openBox<User>(Constants.userBox);
    pendingReportsBox = await Hive.openBox<DisasterReport>(Constants.pendingReportsBox);
  }
  
  // User operations
  static Future<void> saveUser(User user) async {
    await userBox.put('current', user);
  }
  
  static User? getCurrentUser() {
    return userBox.get('current');
  }
  
  // Disaster report operations
  static Future<void> savePendingReport(DisasterReport report) async {
    await pendingReportsBox.put(report.id, report);
  }
  
  static List<DisasterReport> getPendingReports() {
    return pendingReportsBox.values
        .where((report) => report.status == 'pending')
        .toList();
  }
  
  static Future<void> deleteReport(String id) async {
    await pendingReportsBox.delete(id);
  }
  
  static Future<void> clearAll() async {
    await userBox.clear();
    await pendingReportsBox.clear();
  }
}