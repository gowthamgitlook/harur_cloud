import '../../../../shared/models/menu_item_model.dart';
import '../../../../shared/models/restaurant_model.dart';

abstract class IMenuRepository {
  Future<List<MenuItemModel>> getMenuItems();
  Future<List<RestaurantModel>> getRestaurants();
  Future<List<String>> getBanners();
}
