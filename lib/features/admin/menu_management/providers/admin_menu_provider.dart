import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../shared/enums/food_category.dart';
import '../../../../shared/models/menu_item_model.dart';
import '../data/services/mock_menu_service.dart';

class AdminMenuProvider with ChangeNotifier {
  final MockMenuService _menuService = MockMenuService();

  List<MenuItemModel> _menuItems = [];
  FoodCategory? _categoryFilter;
  String _searchQuery = '';
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _menuSubscription;

  // Getters
  List<MenuItemModel> get menuItems => _menuItems;
  bool get isLoading => _isLoading;
  String? get error => _error;
  FoodCategory? get categoryFilter => _categoryFilter;
  String get searchQuery => _searchQuery;

  /// Combined Search and Category Filter
  List<MenuItemModel> get filteredMenuItems {
    return _menuItems.where((item) {
      final matchesCategory = _categoryFilter == null || item.category == _categoryFilter;
      final matchesSearch = _searchQuery.isEmpty || 
          item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  int get availableItemsCount => _menuItems.where((item) => item.isAvailable).length;
  int get outOfStockCount => _menuItems.where((item) => !item.isAvailable).length;

  AdminMenuProvider() {
    _menuSubscription = _menuService.menuStream.listen((items) {
      _menuItems = items;
      notifyListeners();
    });
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> fetchMenuItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _menuItems = await _menuService.getAllMenuItems();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addMenuItem(MenuItemModel item) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _menuService.addMenuItem(item);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateMenuItem(MenuItemModel item) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _menuService.updateMenuItem(item);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteMenuItem(String itemId) async {
    try {
      return await _menuService.deleteMenuItem(itemId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleAvailability(String itemId, bool isAvailable) async {
    try {
      return await _menuService.toggleAvailability(itemId, isAvailable);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void filterByCategory(FoodCategory? category) {
    _categoryFilter = category;
    notifyListeners();
  }

  List<MenuItemModel> getItemsByCategory(FoodCategory category) {
    return _menuItems.where((item) => item.category == category).toList();
  }

  @override
  void dispose() {
    _menuSubscription?.cancel();
    super.dispose();
  }
}
