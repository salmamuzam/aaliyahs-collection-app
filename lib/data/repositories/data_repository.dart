import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

/// Service for reading/writing to the local file system 
class DataRepository {
  
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _recentlyViewedFile async {
    final path = await _localPath;
    return File('$path/recently_viewed.json');
  }

  Future<File> get _notesFile async {
    final path = await _localPath;
    return File('$path/product_notes.json');
  }


  /// Writes a list of product IDs to local storage.
  Future<void> saveRecentlyViewed(List<int> productIds) async {
    try {
      final file = await _recentlyViewedFile;
      await file.writeAsString(jsonEncode(productIds));
    } catch (e) {
      debugPrint('Error writing to local storage: $e');
    }
  }

  /// Reads product IDs from local storage.
  Future<List<int>> getRecentlyViewed() async {
    try {
      final file = await _recentlyViewedFile;
      if (file.existsSync()) {
        final content = await file.readAsString();
        final List<dynamic> decoded = jsonDecode(content);
        return List<int>.from(decoded);
      }
      return [];
    } catch (e) {
      debugPrint('Error reading from local storage: $e');
      return [];
    }
  }

  /// Write data to Local Data Source
  Future<void> saveProductNote(int productId, String note) async {
    try {
      final file = await _notesFile;
      Map<String, String> notes = {};
      if (file.existsSync()) {
        notes = Map<String, String>.from(jsonDecode(await file.readAsString()));
      }
      notes[productId.toString()] = note;
      await file.writeAsString(jsonEncode(notes));
    } catch (e) {
      debugPrint('Error saving note: $e');
    }
  }

  /// Read data from Local Data Source
  Future<String> getProductNote(int productId) async {
    try {
      final file = await _notesFile;
      if (file.existsSync()) {
        final Map<String, dynamic> notes = jsonDecode(await file.readAsString());
        return notes[productId.toString()] ?? '';
      }
    } catch (_) {}
    return '';
  }
  /// Clear data from Local Data Source
  Future<void> clearRecentlyViewed() async {
    try {
      final file = await _recentlyViewedFile;
      if (file.existsSync()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error clearing local storage: $e');
    }
  }
}

