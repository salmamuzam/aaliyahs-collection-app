import 'package:flutter/material.dart';
import 'package:aaliyahs_collection_estore/services/database_service.dart';

class AddressProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  List<Map<String, dynamic>> _addresses = [];

  List<Map<String, dynamic>> get addresses => _addresses;

  AddressProvider() {
    loadAddresses();
  }

  Future<void> loadAddresses() async {
    _addresses = await _dbService.getAddresses();
    notifyListeners();
  }

  Future<void> addAddress(Map<String, dynamic> address) async {
    await _dbService.addAddress(address);
    await loadAddresses();
  }

  Future<void> deleteAddress(int id) async {
    await _dbService.deleteAddress(id);
    await loadAddresses();
  }
}
