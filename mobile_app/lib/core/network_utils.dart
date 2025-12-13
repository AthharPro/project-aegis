import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkUtils {
  final Connectivity _connectivity = Connectivity();

  Stream<bool> get connectionStream {
    return _connectivity.onConnectivityChanged.map((results) {
       // Since connectivity_plus 6.0.0, it returns List<ConnectivityResult>
       // We consider connected if list contains mobile, wifi or ethernet
       return results.any((result) => 
         result == ConnectivityResult.mobile ||
         result == ConnectivityResult.wifi ||
         result == ConnectivityResult.ethernet);
    });
  }

  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return results.any((result) => 
      result == ConnectivityResult.mobile ||
      result == ConnectivityResult.wifi ||
      result == ConnectivityResult.ethernet);
  }
}
