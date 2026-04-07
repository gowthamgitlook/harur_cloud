import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../shared/enums/food_category.dart';
import '../../../../shared/models/menu_item_model.dart';
import '../../../../shared/models/restaurant_model.dart';
import '../data/repositories/menu_repository.dart';

class MenuProvider extends ChangeNotifier {
  // Dependency Inversion: We only know the INTERFACE, not the implementation.
  final IMenuRepository _menuRepository;

  List<MenuItemModel> _allItems = [];
  List<MenuItemModel> _filteredItems = [];
  List<RestaurantModel> _allRestaurants = [];
  List<RestaurantModel> _filteredRestaurants = [];
  List<String> _banners = [];
  FoodCategory? _selectedCategory;
  String _searchQuery = '';
  
  // UI State
  bool _isLoading = false;
  bool _isSearchLoading = false; // New: For debounce UX
  String? _errorMessage;
  Timer? _searchDebounce;

  MenuProvider({required IMenuRepository menuRepository})
      : _menuRepository = menuRepository;

  // Getters
  List<MenuItemModel> get allItems => _allItems;
  List<MenuItemModel> get filteredItems => _filteredItems;
  List<RestaurantModel> get allRestaurants => _allRestaurants;
  List<RestaurantModel> get filteredRestaurants => _filteredRestaurants;
  List<String> get banners => _banners;
  FoodCategory? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  bool get isSearchLoading => _isSearchLoading;
  String? get errorMessage => _errorMessage;

  /// Fetch initial data (Cold Start)
  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Parallel execution for faster start (Senior approach)
      final results = await Future.wait([
        _menuRepository.getMenuItems(),
        _menuRepository.getBanners(),
        _menuRepository.getRestaurants(),
      ]);

      _allItems = results[0] as List<MenuItemModel>;
      _banners = results[1] as List<String>;
      _allRestaurants = results[2] as List<RestaurantModel>;

      _applyFilters();
    } catch (e) {
      _errorMessage = 'Unable to load menu. Please check your connection.';
      debugPrint('MenuProvider Init Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Category Filter
  void filterByCategory(FoodCategory? category) {
    _selectedCategory = category;
    _applyFilters();
  }

  /// Search Logic with Improved Debouncing
  void searchItems(String query) {
    if (_searchQuery == query) return;
    
    _searchQuery = query;
    
    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();

    if (query.isNotEmpty) {
      _isSearchLoading = true;
      notifyListeners();
    }

    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      _isSearchLoading = false;
      _applyFilters();
    });
    
    if (query.isEmpty) {
      _isSearchLoading = false;
      _applyFilters();
    }
  }

  /// Centralized Filter Logic (Production Standard)
  void _applyFilters() {
    Iterable<MenuItemModel> items = _allItems;

    // Filter by category
    if (_selectedCategory != null) {
      items = items.where((item) => item.category == _selectedCategory);
    }

    // Filter by search
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      items = items.where((i) => i.name.toLowerCase().contains(q) || i.description.toLowerCase().contains(q));
    }

    _filteredItems = items.where((item) => item.isAvailable).toList();

    // Map items to restaurants
    final restaurantIds = _filteredItems.map((e) => e.restaurantId).toSet();
    
    if (_searchQuery.isEmpty && _selectedCategory == null) {
      _filteredRestaurants = List.from(_allRestaurants);
    } else {
      _filteredRestaurants = _allRestaurants.where((r) => restaurantIds.contains(r.id)).toList();
    }

    notifyListeners();
  }

  void clearFilters() {
    _selectedCategory = null;
    _searchQuery = '';
    _applyFilters();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }
}
