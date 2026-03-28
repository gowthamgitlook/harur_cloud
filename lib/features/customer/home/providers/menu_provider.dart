import 'package:flutter/foundation.dart';
import '../../../../data/mock/mock_menu_data.dart';
import '../../../../data/services/menu_service.dart';
import '../../../../config/app_config.dart';
import '../../../../shared/enums/food_category.dart';
import '../../../../shared/models/menu_item_model.dart';

class MenuProvider extends ChangeNotifier {
  final IMenuService _menuService;

  List<MenuItemModel> _allItems = [];
  List<MenuItemModel> _filteredItems = [];
  List<String> _banners = [];
  FoodCategory? _selectedCategory;
  String _searchQuery = '';
  bool _isLoading = false;

  MenuProvider({IMenuService? menuService})
      : _menuService = menuService ??
            (AppConfig.useMockServices ? FirestoreMenuService() : FirestoreMenuService()); 
            // Note: Currently using FirestoreMenuService for both to show how it works, 
            // but usually mock would have its own implementation of IMenuService.

  // Getters
  List<MenuItemModel> get allItems => _allItems;
  List<MenuItemModel> get filteredItems => _filteredItems;
  List<MenuItemModel> get popularItems => _allItems.where((item) => item.isPopular && item.isAvailable).toList();
  List<String> get banners => _banners;
  FoodCategory? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  // Initialize - Load menu items
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    if (AppConfig.useMockServices) {
       // Still using mock data for some parts if needed
       _allItems = MockMenuData.menuItems;
       _banners = MockMenuData.banners;
    } else {
      try {
        _allItems = await _menuService.getMenuItems();
        _banners = await _menuService.getBanners();
      } catch (e) {
        debugPrint('Error loading menu from Firestore: $e');
        _allItems = MockMenuData.menuItems;
        _banners = MockMenuData.banners;
      }
    }

    _filteredItems = _allItems.where((item) => item.isAvailable).toList();

    _isLoading = false;
    notifyListeners();
  }

  // Filter by category
  void filterByCategory(FoodCategory? category) {
    _selectedCategory = category;

    if (category == null) {
      _filteredItems = _searchQuery.isEmpty
          ? _allItems.where((item) => item.isAvailable).toList()
          : _searchItemsLocally(_searchQuery);
    } else {
      final categoryItems = _allItems.where((item) => item.category == category).toList();
      _filteredItems = _searchQuery.isEmpty
          ? categoryItems.where((item) => item.isAvailable).toList()
          : categoryItems
              .where((item) =>
                  item.isAvailable &&
                  (item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      item.description.toLowerCase().contains(_searchQuery.toLowerCase())))
              .toList();
    }

    notifyListeners();
  }

  // Search items
  void searchItems(String query) {
    _searchQuery = query;

    if (query.isEmpty) {
      if (_selectedCategory == null) {
        _filteredItems = _allItems.where((item) => item.isAvailable).toList();
      } else {
        filterByCategory(_selectedCategory);
      }
    } else {
      final searchResults = _searchItemsLocally(query);
      _filteredItems = _selectedCategory == null
          ? searchResults.where((item) => item.isAvailable).toList()
          : searchResults
              .where((item) => item.isAvailable && item.category == _selectedCategory)
              .toList();
    }

    notifyListeners();
  }

  List<MenuItemModel> _searchItemsLocally(String query) {
    final lowerQuery = query.toLowerCase();
    return _allItems.where((item) {
      return item.name.toLowerCase().contains(lowerQuery) ||
          item.description.toLowerCase().contains(lowerQuery) ||
          item.category.displayName.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Clear filters
  void clearFilters() {
    _selectedCategory = null;
    _searchQuery = '';
    _filteredItems = _allItems.where((item) => item.isAvailable).toList();
    notifyListeners();
  }

  // Get item by ID
  MenuItemModel? getItemById(String id) {
    try {
      return _allItems.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get items by category
  List<MenuItemModel> getItemsByCategory(FoodCategory category) {
    return _allItems
        .where((item) => item.category == category && item.isAvailable)
        .toList();
  }
}
