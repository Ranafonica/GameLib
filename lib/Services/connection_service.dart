import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ConnectionService {
  // Verifica si hay conexión a internet (no solo red disponible)
  static Future<bool> hasInternetAccess() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }

    // Corrección aquí 👇
    return await InternetConnectionChecker.createInstance().hasConnection;
  }

  static Stream<bool> get onConnectionChanged {
    return Connectivity().onConnectivityChanged.asyncMap((result) async {
      if (result == ConnectivityResult.none) return false;

      // Corrección aquí también 👇
      return await InternetConnectionChecker.createInstance().hasConnection;
    });
  }
}
