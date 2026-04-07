import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../data/mock/mock_menu_data.dart';
import '../../../../data/services/menu_service.dart';
import '../../../../config/app_config.dart';
import '../../../../shared/enums/food_category.dart';
import '../../../../shared/models/menu_item_model.dart';
import '../../../../shared/models/restaurant_model.dart';

class MenuProvider extends ChangeNotifier {
  final IMenuService _menuService;

  List<MenuItemModel> _allItems = [];
  List<MenuItemModel> _filteredItems = [];
  List<RestaurantModel> _allRestaurants = [];
  List<RestaurantModel> _filteredRestaurants = [];
  List<String> _banners = [];
  FoodCategory? _selectedCategory;
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _searchDebounce;

  MenuProvider({IMenuService? menuService})
      : _menuService = menuService ??
            (AppConfig.useMockServices ? FirestoreMenuService() : FirestoreMenuService());

  // Getters
  List<MenuItemModel> get allItems => _allItems;
  List<MenuItemModel> get filteredItems => _filteredItems;
  List<RestaurantModel> get allRestaurants => _allRestaurants;
  List<RestaurantModel> get filteredRestaurants => _filteredRestaurants;
  List<MenuItemModel> get popularItems => _allItems.where((item) => item.isPopular && item.isAvailable).toList();
  List<String> get banners => _banners;
  FoodCategory? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Initialize - Load menu items and restaurants
  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (AppConfig.useMockServices) {
        // Simulate network delay for realistic shimmer testing
        await Future.delayed(const Duration(seconds: 2));
        _allItems = MockMenuData.menuItems;
        _banners = MockMenuData.banners;
        _allRestaurants = MockMenuData.restaurants;
      } else {
        _allItems = await _menuService.getMenuItems();
        _banners = await _menuService.getBanners();
        // For now, restaurants are only in mock data until IMenuService is updated
        _allRestaurants = MockMenuData.restaurants;
      }
      
      _filteredItems = _allItems.where((item) => item.isAvailable).toList();
      _filteredRestaurants = List.from(_allRestaurants);
    } catch (e) {
      _errorMessage = 'Failed to load menu. Please try again.';
      debugPrint('Error loading menu: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Filter by category
  void filterByCategory(FoodCategory? category) {
    _selectedCategory = category;
    _applyFilters();
  }

  // Search items with Debouncing (Senior approach)
  void searchItems(String query) {
    _searchQuery = query;
    
    // Cancel any previous debounce timer
    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();

    // Set a new debounce timer
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      _applyFilters();
    });
    
    // Only notify if query is empty to clear results immediately
    if (query.isEmpty) notifyListeners();
  }

  void _applyFilters() {
    // 1. Filter by category
    Iterable<MenuItemModel> items = _allItems;
    if (_selectedCategory != null) {
      items = items.where((item) => item.category == _selectedCategory);
    }

    // 2. Filter by search query
    if (_searchQuery.isNotEmpty) {
      final lowerQuery = _searchQuery.toLowerCase();
      items = items.where((item) =>
          item.name.toLowerCase().contains(lowerQuery) ||
          item.description.toLowerCase().contains(lowerQuery));
    }

    _filteredItems = items.where((item) => item.isAvailable).toList();

    // Update restaurant list based on filtered items
    final restaurantIds = _filteredItems.map((e) => e.restaurantId).toSet();
    if (_searchQuery.isEmpty && _selectedCategory == null) {
      _filteredRestaurants = List.from(_allRestaurants);
    } else {
      _filteredRestaurants = _allRestaurants.where((r) => restaurantIds.contains(r.id)).toList();
    }

    notifyListeners();
  }

  // Clear filters
  void clearFilters() {
    _selectedCategory = null;
    _searchQuery = '';
    _filteredItems = _allItems.where((item) => item.isAvailable).toList();
    _filteredRestaurants = List.from(_allRestaurants);
    notifyListeners();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  // Get item by ID
  MenuItemModel? getItemById(String id) {
    try {
      return _allItems.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }
}
