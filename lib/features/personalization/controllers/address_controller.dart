import 'package:flutter/material.dart';
import 'package:aaliyahs_collection_estore/utils/local_storage/db_helper.dart';

// ============================================================================
// ADDRESS CONTROLLER - Manages User Shipping Addresses
// ============================================================================
// This controller handles all address-related operations using Provider pattern
// It stores addresses in SQLite database for persistence
//
// Features:
// - Load saved addresses from database
// - Add new shipping addresses
// - Delete addresses
// - Automatically updates UI when addresses change
// ============================================================================

class AddressController extends ChangeNotifier {
  final DBHelper _dbHelper = DBHelper();  // Database helper for SQLite operations
  
  // Private list of addresses (only this controller can modify directly)
  List<Map<String, dynamic>> _addresses = [];

  // Public getter - other parts of app can read addresses but not modify directly
  List<Map<String, dynamic>> get addresses => _addresses;

  // Constructor - automatically loads addresses when controller is created
  AddressController() {
    loadAddresses();
  }

  // Load all addresses from database
  Future<void> loadAddresses() async {
    try {
      // Get addresses from SQLite database
      _addresses = await _dbHelper.getAddresses();
      
      // Tell all listening widgets to rebuild with new data
      notifyListeners();
    } catch (e) {
      // Print error to console for debugging
      debugPrint('Error loading addresses: $e');
    }
  }

  // Add a new address to database
  Future<void> addAddress(Map<String, dynamic> address) async {
    try {
      // Insert address into SQLite database
      await _dbHelper.insertAddress(address);
      
      // Reload addresses from database to get the updated list
      await loadAddresses();
      
      // notifyListeners() is called inside loadAddresses()
    } catch (e) {
      debugPrint('Error adding address: $e');
    }
  }

  // Delete an address from database
  Future<void> deleteAddress(int id) async {
    try {
      // Remove address from SQLite database using its ID
      await _dbHelper.deleteAddress(id);
      
      // Reload addresses from database to get the updated list
      await loadAddresses();
      
      // notifyListeners() is called inside loadAddresses()
    } catch (e) {
      debugPrint('Error deleting address: $e');
    }
  }
}
