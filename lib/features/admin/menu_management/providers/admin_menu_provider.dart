import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../shared/enums/food_category.dart';
import '../../../../shared/models/menu_item_model.dart';
import '../data/services/mock_menu_service.dart';

class AdminMenuProvider with ChangeNotifier {
  final MockMenuService _menuService = MockMenuService();

  List<MenuItemModel> _menuItems = [];
  FoodCategory? _categoryFilter;
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _menuSubscription;

  // Getters
  List<MenuItemModel> get menuItems => _menuItems;
  bool get isLoading => _isLoading;
  String? get error => _error;
  FoodCategory? get categoryFilter => _categoryFilter;

  /// Get filtered menu items based on category
  List<MenuItemModel> get filteredMenuItems {
    if (_categoryFilter == null) {
      return _menuItems;
    }
    return _menuItems.where((item) => item.category == _categoryFilter).toList();
  }

  /// Get available items count
  int get availableItemsCount {
    return _menuItems.where((item) => item.isAvailable).length;
  }

  /// Get unavailable items count
  int get unavailableItemsCount {
    return _menuItems.where((item) => !item.isAvailable).length;
  }

  AdminMenuProvider() {
    // Subscribe to menu updates
    _menuSubscription = _menuService.menuStream.listen((items) {
      _menuItems = items;
      notifyListeners();
    });
  }

  /// Fetch all menu items
  Future<void> fetchMenuItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _menuItems = await _menuService.getAllMenuItems();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a new menu item
  Future<bool> addMenuItem(MenuItemModel item) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _menuService.addMenuItem(item);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update an existing menu item
  Future<bool> updateMenuItem(MenuItemModel item) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _menuService.updateMenuItem(item);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete a menu item
  Future<bool> deleteMenuItem(String itemId) async {
    try {
      final success = await _menuService.deleteMenuItem(itemId);
      if (!success) {
        _error = 'Failed to delete menu item';
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Toggle menu item availability
  Future<bool> toggleAvailability(String itemId, bool isAvailable) async {
    try {
      final success = await _menuService.toggleAvailability(itemId, isAvailable);
      if (!success) {
        _error = 'Failed to update availability';
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Filter by category
  void filterByCategory(FoodCategory? category) {
    _categoryFilter = category;
    notifyListeners();
  }

  /// Clear category filter
  void clearFilter() {
    _categoryFilter = null;
    notifyListeners();
  }

  /// Get menu item by ID
  Future<MenuItemModel?> getMenuItemById(String itemId) async {
    return await _menuService.getMenuItemById(itemId);
  }

  /// Get items by category
  List<MenuItemModel> getItemsByCategory(FoodCategory category) {
    return _menuItems.where((item) => item.category == category).toList();
  }

  /// Get item count by category
  int getItemCountByCategory(FoodCategory category) {
    return _menuItems.where((item) => item.category == category).length;
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _menuSubscription?.cancel();
    super.dispose();
  }
}
