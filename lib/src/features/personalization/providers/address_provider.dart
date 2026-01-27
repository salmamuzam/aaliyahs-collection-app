import 'package:flutter/material.dart';
import 'package:aaliyahs_collection_estore/src/utils/local_storage/db_helper.dart';

/// Manages user addresses with local sqflite persistence.
class AddressProvider extends ChangeNotifier {
  final DBHelper _dbHelper = DBHelper();
  List<Map<String, dynamic>> _addresses = [];

  List<Map<String, dynamic>> get addresses => _addresses;

  AddressProvider() {
    loadAddresses();
  }

  Future<void> loadAddresses() async {
    try {
      _addresses = await _dbHelper.getAddresses();
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading addresses: $e");
    }
  }

  Future<void> addAddress(Map<String, dynamic> address) async {
    try {
      await _dbHelper.insertAddress(address);
      await loadAddresses();
    } catch (e) {
      debugPrint("Error adding address: $e");
    }
  }

  Future<void> deleteAddress(int id) async {
    try {
      await _dbHelper.deleteAddress(id);
      await loadAddresses();
    } catch (e) {
      debugPrint("Error deleting address: $e");
    }
  }
}
