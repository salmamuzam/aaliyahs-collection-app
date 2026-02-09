import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';


// This controller tracks whether the device has internet connection
// It listens for changes in real-time (WiFi, Mobile Data, or No Connection)



class ConnectivityController extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();  
  bool _isConnected = true;  // Assume connected initially


  bool get isConnected => _isConnected;

  // sets up connection monitoring when controller is created
  ConnectivityController() {
    _checkInitialConnection();  // Check connection immediately
    
    // Listen for connection changes in real-time
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
   
      _updateConnectionStatus(results);
    });
  }


  // Checks connection status when app first opens
  Future<void> _checkInitialConnection() async {
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);
  }


  void _updateConnectionStatus(List<ConnectivityResult> results) {
    // Check if device has ANY connection (WiFi, Mobile Data, Ethernet, etc.)
    // If results contains ConnectivityResult.none, device is offline
    bool newStatus = !results.contains(ConnectivityResult.none);
    
    // Only update if status actually changed 
    if (_isConnected != newStatus) {
      _isConnected = newStatus;
      
      // Notify UI to show/hide offline banner
      notifyListeners();
      
      // Debug output
      debugPrint("Connection status changed: ${newStatus ? 'Online' : 'Offline'}");
    }
  }
}
