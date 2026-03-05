import 'package:flutter/foundation.dart';
import '../../../../data/mock/mock_menu_data.dart';
import '../../../../shared/enums/food_category.dart';
import '../../../../shared/models/menu_item_model.dart';

class MenuProvider extends ChangeNotifier {
  List<MenuItemModel> _allItems = [];
  List<MenuItemModel> _filteredItems = [];
  FoodCategory? _selectedCategory;
  String _searchQuery = '';
  bool _isLoading = false;

  // Getters
  List<MenuItemModel> get allItems => _allItems;
  List<MenuItemModel> get filteredItems => _filteredItems;
  List<MenuItemModel> get popularItems => MockMenuData.getPopularItems();
  List<String> get banners => MockMenuData.banners;
  FoodCategory? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  // Initialize - Load menu items
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    _allItems = MockMenuData.menuItems;
    _filteredItems = MockMenuData.getAvailableItems();

    _isLoading = false;
    notifyListeners();
  }

  // Filter by category
  void filterByCategory(FoodCategory? category) {
    _selectedCategory = category;

    if (category == null) {
      _filteredItems = _searchQuery.isEmpty
          ? MockMenuData.getAvailableItems()
          : MockMenuData.searchItems(_searchQuery);
    } else {
      final categoryItems = MockMenuData.getItemsByCategory(category);
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
        _filteredItems = MockMenuData.getAvailableItems();
      } else {
        filterByCategory(_selectedCategory);
      }
    } else {
      final searchResults = MockMenuData.searchItems(query);
      _filteredItems = _selectedCategory == null
          ? searchResults.where((item) => item.isAvailable).toList()
          : searchResults
              .where((item) => item.isAvailable && item.category == _selectedCategory)
              .toList();
    }

    notifyListeners();
  }

  // Clear filters
  void clearFilters() {
    _selectedCategory = null;
    _searchQuery = '';
    _filteredItems = MockMenuData.getAvailableItems();
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
