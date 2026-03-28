import 'package:flutter/material.dart';

class NavigationProvider extends ChangeNotifier {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void switchToCart() {
    _selectedIndex = 2; // Cart is at index 2
    notifyListeners();
  }

  void switchToHome() {
    _selectedIndex = 0; // Home is at index 0
    notifyListeners();
  }

  void switchToOrders() {
    _selectedIndex = 1; // Orders is at index 1
    notifyListeners();
  }

  void switchToProfile() {
    _selectedIndex = 3; // Profile is at index 3
    notifyListeners();
  }
}
