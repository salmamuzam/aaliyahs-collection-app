import 'package:flutter/material.dart';

class NavigationController extends ChangeNotifier {
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  // Signal for re-selection (used for Scroll-to-Top behavior)
  int _reselectedIndex = -1;
  int get reselectedIndex => _reselectedIndex;

  void setIndex(int index) {
    if (_selectedIndex == index) {
      // Trigger scroll-to-top for the active tab
      _reselectedIndex = index;
      notifyListeners();
      
      // Reset reselection index immediately so it doesn't trigger again on next rebuild
      _reselectedIndex = -1;
    } else {
      _selectedIndex = index;
      _reselectedIndex = -1;
      notifyListeners();
    }
  }

  void navigateToShop({int? categoryId}) {
    if (_selectedIndex == 1) {
      _reselectedIndex = 1;
    } else {
      _selectedIndex = 1;
      _reselectedIndex = -1;
    }
    notifyListeners();
  }
}
