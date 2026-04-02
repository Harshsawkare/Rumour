import 'package:connectivity_plus/connectivity_plus.dart';

/// Lightweight device connectivity (Wi‑Fi / cellular / ethernet vs none).
/// Does not guarantee a route to the public internet.
abstract final class NetworkConnectivity {
  static Future<bool> isDeviceOnline() async {
    final results = await Connectivity().checkConnectivity();
    if (results.isEmpty) {
      return false;
    }
    return results.any((r) => r != ConnectivityResult.none);
  }
}
