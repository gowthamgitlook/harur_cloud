import '../../../../../data/mock/mock_menu_data.dart';
import '../../../../../shared/models/menu_item_model.dart';
import '../../../../../shared/models/restaurant_model.dart';
import 'menu_repository.dart';

class MockMenuRepository implements IMenuRepository {
  @override
  Future<List<MenuItemModel>> getMenuItems() async {
    // Simulate real network delay for UX testing (shimmer loaders)
    await Future.delayed(const Duration(seconds: 1));
    return MockMenuData.menuItems;
  }

  @override
  Future<List<RestaurantModel>> getRestaurants() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockMenuData.restaurants;
  }

  @override
  Future<List<String>> getBanners() async {
    return MockMenuData.banners;
  }
}
