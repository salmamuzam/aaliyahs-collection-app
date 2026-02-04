import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

// ============================================================================
// CONNECTIVITY CONTROLLER - Monitors Internet Connection Status
// ============================================================================
// This controller tracks whether the device has internet connection
// It listens for changes in real-time (WiFi, Mobile Data, or No Connection)
//
// Features:
// - Checks connection when app starts
// - Monitors connection changes in real-time
// - Notifies UI when connection status changes
// - Supports WiFi, Mobile Data, Ethernet, etc.
//
// Used for:
// - Showing offline mode banner
// - Preventing API calls when offline
// - Loading local data when no internet
// ============================================================================

class ConnectivityController extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();  // connectivity_plus package
  bool _isConnected = true;  // Assume connected initially

  // Public getter - other parts of app can check connection status
  bool get isConnected => _isConnected;

  // Constructor - sets up connection monitoring when controller is created
  ConnectivityController() {
    _checkInitialConnection();  // Check connection immediately
    
    // Listen for connection changes in real-time
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      // connectivity_plus 6.0+ returns List<ConnectivityResult>
      // This can include multiple connection types (WiFi + Mobile Data)
      _updateConnectionStatus(results);
    });
  }

  // ============================================================================
  // CHECK INITIAL CONNECTION - Run Once at Startup
  // ============================================================================
  // Checks connection status when app first opens
  Future<void> _checkInitialConnection() async {
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);
  }

  // ============================================================================
  // UPDATE CONNECTION STATUS - Process Connection Changes
  // ============================================================================
  void _updateConnectionStatus(List<ConnectivityResult> results) {
    // Check if device has ANY connection (WiFi, Mobile Data, Ethernet, etc.)
    // If results contains ConnectivityResult.none, device is offline
    bool newStatus = !results.contains(ConnectivityResult.none);
    
    // Only update if status actually changed (prevents unnecessary UI rebuilds)
    if (_isConnected != newStatus) {
      _isConnected = newStatus;
      
      // Notify UI to show/hide offline banner
      notifyListeners();
      
      // Debug output
      debugPrint("Connection status changed: ${newStatus ? 'Online' : 'Offline'}");
    }
  }
}
