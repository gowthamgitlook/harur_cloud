import '../../shared/enums/food_category.dart';
import '../../shared/models/addon_model.dart';
import '../../shared/models/menu_item_model.dart';
import '../../shared/models/restaurant_model.dart';

class MockMenuData {
  MockMenuData._();

  // Common addons
  static final List<AddonModel> commonAddons = [
    AddonModel(id: 'addon_1', name: 'Extra Egg', price: 20),
    AddonModel(id: 'addon_2', name: 'Extra Chicken', price: 50),
    AddonModel(id: 'addon_3', name: 'Raita', price: 30),
    AddonModel(id: 'addon_4', name: 'Extra Gravy', price: 25),
  ];

  // Restaurants
  static final List<RestaurantModel> restaurants = [
    RestaurantModel(
      id: 'res_1',
      name: 'Harur Cloud Kitchen',
      description: 'The best local flavors in town',
      imageUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=1200&q=80',
      rating: 4.5,
      reviewCount: 500,
      deliveryTime: '25-30 mins',
      priceForTwo: 400.0,
      cuisine: 'Biryani, South Indian',
      latitude: 12.0540,
      longitude: 78.4822,
      address: 'Near Bus Stand, Harur',
    ),
    RestaurantModel(
      id: 'res_2',
      name: 'Spice Garden',
      description: 'Authentic Indian Curry & Tandoor',
      imageUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=1200&q=80',
      rating: 4.2,
      reviewCount: 350,
      deliveryTime: '35-40 mins',
      priceForTwo: 600.0,
      cuisine: 'North Indian, Chinese',
      latitude: 12.0550,
      longitude: 78.4832,
      address: 'Main Road, Harur',
    ),
    RestaurantModel(
      id: 'res_3',
      name: 'Pizza Hub',
      description: 'Cheesy delights and more',
      imageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=1200&q=80',
      rating: 4.0,
      reviewCount: 200,
      deliveryTime: '20-25 mins',
      priceForTwo: 500.0,
      cuisine: 'Italian, Pizza, Burgers',
      latitude: 12.0560,
      longitude: 78.4842,
      address: 'Cinema Theater Road, Harur',
    ),
  ];

  // Menu Items
  static final List<MenuItemModel> menuItems = [
    // res_1 items
    MenuItemModel(
      id: 'item_1',
      restaurantId: 'res_1',
      restaurantName: 'Harur Cloud Kitchen',
      name: 'Chicken Biryani',
      description: 'Aromatic basmati rice with tender chicken pieces',
      price: 180,
      imageUrl: 'https://images.unsplash.com/photo-1563379091339-03b21bc4a4f8?w=800&q=80',
      category: FoodCategory.biryani,
      isPopular: true,
      isVeg: false,
      rating: 4.5,
      reviewCount: 234,
      addons: [commonAddons[0], commonAddons[1], commonAddons[2]],
    ),
    MenuItemModel(
      id: 'item_2',
      restaurantId: 'res_1',
      restaurantName: 'Harur Cloud Kitchen',
      name: 'Mutton Biryani',
      description: 'Rich and flavorful mutton biryani',
      price: 220,
      imageUrl: 'https://images.unsplash.com/photo-1589302168068-964664d93dc0?w=800&q=80',
      category: FoodCategory.biryani,
      isPopular: true,
      isVeg: false,
      rating: 4.7,
      reviewCount: 189,
      addons: [commonAddons[0], commonAddons[2]],
    ),
    MenuItemModel(
      id: 'item_3',
      restaurantId: 'res_1',
      restaurantName: 'Harur Cloud Kitchen',
      name: 'Veg Biryani',
      description: 'Healthy and tasty vegetable biryani',
      price: 150,
      imageUrl: 'https://images.unsplash.com/photo-1563379091339-03b21bc4a4f8?w=800&q=80',
      category: FoodCategory.biryani,
      isPopular: false,
      isVeg: true,
      rating: 4.2,
      reviewCount: 145,
    ),
    MenuItemModel(
      id: 'item_4',
      restaurantId: 'res_1',
      restaurantName: 'Harur Cloud Kitchen',
      name: 'Chicken 65',
      description: 'Spicy, deep-fried chicken dish',
      price: 160,
      imageUrl: 'https://images.unsplash.com/photo-1610057099443-fde8c4d50f91?w=800&q=80',
      category: FoodCategory.starters,
      isPopular: true,
      isVeg: false,
      rating: 4.6,
      reviewCount: 312,
    ),
    MenuItemModel(
      id: 'item_5',
      restaurantId: 'res_1',
      restaurantName: 'Harur Cloud Kitchen',
      name: 'Chicken Fried Rice',
      description: 'Classic chicken fried rice with vegetables',
      price: 140,
      imageUrl: 'https://images.unsplash.com/photo-1603133872878-6858488e721a?w=800&q=80',
      category: FoodCategory.friedRice,
      isPopular: true,
      isVeg: false,
      rating: 4.3,
      reviewCount: 198,
    ),
    MenuItemModel(
      id: 'item_6',
      restaurantId: 'res_1',
      restaurantName: 'Harur Cloud Kitchen',
      name: 'Egg Fried Rice',
      description: 'Delicious fried rice with scrambled eggs',
      price: 120,
      imageUrl: 'https://images.unsplash.com/photo-1512058560366-cd2429555e54?w=800&q=80',
      category: FoodCategory.friedRice,
      isPopular: false,
      isVeg: false,
      rating: 4.1,
      reviewCount: 156,
    ),
    MenuItemModel(
      id: 'item_7',
      restaurantId: 'res_1',
      restaurantName: 'Harur Cloud Kitchen',
      name: 'Veg Fried Rice',
      description: 'Healthy vegetable fried rice',
      price: 110,
      imageUrl: 'https://images.unsplash.com/photo-1512058560366-cd2429555e54?w=800&q=80',
      category: FoodCategory.friedRice,
      isPopular: false,
      isVeg: true,
      rating: 4.0,
      reviewCount: 124,
    ),
    MenuItemModel(
      id: 'item_8',
      restaurantId: 'res_1',
      restaurantName: 'Harur Cloud Kitchen',
      name: 'Plain Parotta',
      description: 'Multi-layered flaky bread',
      price: 40,
      imageUrl: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=800&q=80',
      category: FoodCategory.parotta,
      isPopular: true,
      isVeg: true,
      rating: 4.4,
      reviewCount: 450,
    ),
    MenuItemModel(
      id: 'item_9',
      restaurantId: 'res_1',
      restaurantName: 'Harur Cloud Kitchen',
      name: 'Chicken Kothu Parotta',
      description: 'Shredded parotta with chicken and spices',
      price: 150,
      imageUrl: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=800&q=80',
      category: FoodCategory.parotta,
      isPopular: true,
      isVeg: false,
      rating: 4.8,
      reviewCount: 287,
    ),
    MenuItemModel(
      id: 'item_10',
      restaurantId: 'res_1',
      restaurantName: 'Harur Cloud Kitchen',
      name: 'Egg Parotta',
      description: 'Flaky parotta stuffed with egg',
      price: 60,
      imageUrl: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=800&q=80',
      category: FoodCategory.parotta,
      isPopular: false,
      isVeg: false,
      rating: 4.3,
      reviewCount: 167,
    ),

    // res_2 items
    MenuItemModel(
      id: 'item_11',
      restaurantId: 'res_2',
      restaurantName: 'Spice Garden',
      name: 'Butter Chicken',
      description: 'Creamy chicken curry with butter and spices',
      price: 240,
      imageUrl: 'https://images.unsplash.com/photo-1603894527134-8d9600969966?w=800&q=80',
      category: FoodCategory.starters,
      isPopular: true,
      isVeg: false,
      rating: 4.4,
      reviewCount: 178,
    ),

    // res_3 items
    MenuItemModel(
      id: 'item_12',
      restaurantId: 'res_3',
      restaurantName: 'Pizza Hub',
      name: 'Margherita Pizza',
      description: 'Classic cheese and tomato pizza',
      price: 250,
      imageUrl: 'https://images.unsplash.com/photo-1604382354936-07c5d9983bd3?w=800&q=80',
      category: FoodCategory.biryani,
      isPopular: true,
      isVeg: true,
      rating: 4.6,
      reviewCount: 221,
    ),
  ];

  // Banner images
  static final List<String> banners = [
    'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=1200&q=80',
    'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=1200&q=80',
    'https://images.unsplash.com/photo-1476224203421-9ac39bcb3327?w=1200&q=80',
  ];

  static List<MenuItemModel> getItemsByRestaurant(String restaurantId) {
    return menuItems.where((item) => item.restaurantId == restaurantId).toList();
  }

  // Search items
  static List<MenuItemModel> searchItems(String query) {
    if (query.isEmpty) return menuItems;

    final lowerQuery = query.toLowerCase();
    return menuItems.where((item) {
      return item.name.toLowerCase().contains(lowerQuery) ||
          item.description.toLowerCase().contains(lowerQuery) ||
          item.category.displayName.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
