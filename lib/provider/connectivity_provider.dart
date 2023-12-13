import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityProvider with ChangeNotifier {
  bool _isConnected = true; // Assume connected initially

  bool get isConnected => _isConnected;

  ConnectivityProvider() {
    _initConnectivity();
    _setupConnectivityListener();
  }

  Future<void> _initConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    _updateConnectivityStatus(connectivityResult);
  }

  void _setupConnectivityListener() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      _updateConnectivityStatus(result);
    });
  }

  void _updateConnectivityStatus(ConnectivityResult result) {
    bool isConnected = result != ConnectivityResult.none;
    if (_isConnected != isConnected) {
      _isConnected = isConnected;
      notifyListeners();
    }
  }
}
