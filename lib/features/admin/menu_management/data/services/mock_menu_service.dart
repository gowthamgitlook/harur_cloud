import 'dart:async';
import '../../../../../data/mock/mock_menu_data.dart';
import '../../../../../shared/models/menu_item_model.dart';

class MockMenuService {
  static final MockMenuService _instance = MockMenuService._internal();
  factory MockMenuService() => _instance;
  MockMenuService._internal() {
    // Initialize with mock data
    _menuItems = List.from(MockMenuData.menuItems);
  }

  List<MenuItemModel> _menuItems = [];
  final _menuStreamController = StreamController<List<MenuItemModel>>.broadcast();

  Stream<List<MenuItemModel>> get menuStream => _menuStreamController.stream;

  /// Get all menu items
  Future<List<MenuItemModel>> getAllMenuItems() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_menuItems);
  }

  /// Add a new menu item
  Future<MenuItemModel> addMenuItem(MenuItemModel item) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Generate a unique ID if not provided
    final newItem = item.id.isEmpty
        ? item.copyWith(id: _generateMenuItemId())
        : item;

    _menuItems.add(newItem);
    _menuStreamController.add(_menuItems);

    return newItem;
  }

  /// Update an existing menu item
  Future<MenuItemModel> updateMenuItem(MenuItemModel item) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final itemIndex = _menuItems.indexWhere((i) => i.id == item.id);
    if (itemIndex == -1) {
      throw Exception('Menu item not found');
    }

    _menuItems[itemIndex] = item;
    _menuStreamController.add(_menuItems);

    return item;
  }

  /// Delete a menu item (soft delete - mark as unavailable)
  Future<bool> deleteMenuItem(String itemId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final itemIndex = _menuItems.indexWhere((i) => i.id == itemId);
    if (itemIndex == -1) {
      return false;
    }

    // Remove from list
    _menuItems.removeAt(itemIndex);
    _menuStreamController.add(_menuItems);

    return true;
  }

  /// Toggle item availability
  Future<bool> toggleAvailability(String itemId, bool isAvailable) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final itemIndex = _menuItems.indexWhere((i) => i.id == itemId);
    if (itemIndex == -1) {
      return false;
    }

    final updatedItem = _menuItems[itemIndex].copyWith(isAvailable: isAvailable);
    _menuItems[itemIndex] = updatedItem;
    _menuStreamController.add(_menuItems);

    return true;
  }

  /// Get a specific menu item by ID
  Future<MenuItemModel?> getMenuItemById(String itemId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _menuItems.firstWhere((item) => item.id == itemId);
    } catch (e) {
      return null;
    }
  }

  /// Generate a unique menu item ID
  String _generateMenuItemId() {
    return 'item_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Cleanup
  void dispose() {
    _menuStreamController.close();
  }

  /// Clear all menu items (for testing)
  void clearMenuItems() {
    _menuItems.clear();
    _menuStreamController.add(_menuItems);
  }

  /// Reset to default menu items (for testing)
  void resetToDefaultMenu() {
    _menuItems = List.from(MockMenuData.menuItems);
    _menuStreamController.add(_menuItems);
  }
}
