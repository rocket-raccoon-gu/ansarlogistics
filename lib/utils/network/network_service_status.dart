import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

enum NetworkStatus { Online, Offline }

class NetworkStatusService {
  static NetworkStatus currentStatus = NetworkStatus.Online;
  static StreamController<NetworkStatus> networkStatusController =
      StreamController<NetworkStatus>.broadcast();

  // Constructor
  NetworkStatusService() {
    checkInternetAccess().then((NetworkStatus stat) {
      currentStatus = stat;
      // Listening to connectivity changes
      Connectivity()
          .onConnectivityChanged
          .listen((List<ConnectivityResult> results) {
        for (var result in results) {
          _handleConnectivityChange(result);
        }
      });
    });
  }

  // Method to handle connectivity change
  void _handleConnectivityChange(ConnectivityResult result) async {
    // Perform an actual internet check after connectivity change
    NetworkStatus stat = await checkInternetAccess();
    if (currentStatus != stat) {
      currentStatus = stat;
      networkStatusController.add(stat);
    }
  }

  // Method to check if internet access is available
  static Future<NetworkStatus> checkInternetAccess({String? domain}) async {
    try {
      final result = await InternetAddress.lookup(domain ?? 'google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return NetworkStatus.Online;
      }
      return NetworkStatus.Offline;
    } on SocketException catch (_) {
      return NetworkStatus.Offline;
    }
  }

  // Method to map connectivity result to network status
  NetworkStatus _getNetworkStatus(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.mobile:
      case ConnectivityResult.wifi:
        return NetworkStatus.Online;
      case ConnectivityResult.none:
        return NetworkStatus.Offline;
      default:
        return NetworkStatus.Offline;
    }
  }

  // Method to close StreamController when no longer needed
  void dispose() {
    networkStatusController.close();
  }
}
