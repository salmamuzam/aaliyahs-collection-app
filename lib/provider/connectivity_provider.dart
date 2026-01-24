import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

// Provider to manage Connectivity status
class ConnectivityProvider extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  bool _isConnected = true; 

  bool get isConnected => _isConnected;

  ConnectivityProvider() {
    _checkInitialConnection();
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
       // connectivity_plus 6.0+ returns List<ConnectivityResult>
       _updateConnectionStatus(results);
    });
  }

  Future<void> _checkInitialConnection() async {
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.none)) {
      _isConnected = false;
    } else {
      _isConnected = true;
    }
    notifyListeners();
  }
}
