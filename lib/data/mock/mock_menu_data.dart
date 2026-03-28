import '../../shared/enums/food_category.dart';
import '../../shared/models/addon_model.dart';
import '../../shared/models/menu_item_model.dart';

class MockMenuData {
  MockMenuData._();

  // Common addons
  static final List<AddonModel> commonAddons = [
    AddonModel(id: 'addon_1', name: 'Extra Egg', price: 20),
    AddonModel(id: 'addon_2', name: 'Extra Chicken', price: 50),
    AddonModel(id: 'addon_3', name: 'Raita', price: 30),
    AddonModel(id: 'addon_4', name: 'Extra Gravy', price: 25),
  ];

  // Menu Items
  static final List<MenuItemModel> menuItems = [
    // Biryani
    MenuItemModel(
      id: 'item_1',
      name: 'Chicken Biryani',
      description: 'Aromatic basmati rice with tender chicken pieces, cooked with traditional spices',
      price: 180,
      imageUrl: 'https://images.unsplash.com/photo-1563379091339-03b21bc4a4f8?w=800&q=80',
      category: FoodCategory.biryani,
      isPopular: true,
      isAvailable: true,
      rating: 4.5,
      reviewCount: 234,
      addons: [commonAddons[0], commonAddons[1], commonAddons[2]],
    ),
    MenuItemModel(
      id: 'item_2',
      name: 'Mutton Biryani',
      description: 'Rich and flavorful mutton biryani with perfectly cooked rice',
      price: 220,
      imageUrl: 'https://images.unsplash.com/photo-1589302168068-964664d93dc0?w=800&q=80',
      category: FoodCategory.biryani,
      isPopular: true,
      isAvailable: true,
      rating: 4.7,
      reviewCount: 189,
      addons: [commonAddons[0], commonAddons[2]],
    ),
    MenuItemModel(
      id: 'item_3',
      name: 'Egg Biryani',
      description: 'Delicious biryani with boiled eggs and aromatic spices',
      price: 120,
      imageUrl: 'https://images.unsplash.com/photo-1633945274405-b6c8069047b0?w=800&q=80',
      category: FoodCategory.biryani,
      isAvailable: true,
      rating: 4.2,
      reviewCount: 156,
      addons: [commonAddons[0], commonAddons[2]],
    ),
    MenuItemModel(
      id: 'item_4',
      name: 'Veg Biryani',
      description: 'Mixed vegetables cooked with fragrant basmati rice',
      price: 100,
      imageUrl: 'https://images.unsplash.com/photo-1563379091339-03b21bc4a4f8?w=800&q=80',
      category: FoodCategory.biryani,
      isAvailable: true,
      rating: 4.0,
      reviewCount: 98,
      addons: [commonAddons[2]],
    ),

    // Fried Rice
    MenuItemModel(
      id: 'item_5',
      name: 'Chicken Fried Rice',
      description: 'Wok-tossed rice with chicken and vegetables',
      price: 140,
      imageUrl: 'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=800&q=80',
      category: FoodCategory.friedRice,
      isPopular: true,
      isAvailable: true,
      rating: 4.4,
      reviewCount: 178,
      addons: [commonAddons[0], commonAddons[1]],
    ),
    MenuItemModel(
      id: 'item_6',
      name: 'Egg Fried Rice',
      description: 'Classic fried rice with scrambled eggs',
      price: 100,
      imageUrl: 'https://images.unsplash.com/photo-1512058560366-cd242955a15a?w=800&q=80',
      category: FoodCategory.friedRice,
      isPopular: true,
      isAvailable: true,
      rating: 4.3,
      reviewCount: 203,
      addons: [commonAddons[0]],
    ),

    // Parotta
    MenuItemModel(
      id: 'item_9',
      name: 'Chicken Kothu Parotta',
      description: 'Shredded parotta stir-fried with chicken and spices',
      price: 150,
      imageUrl: 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=800&q=80',
      category: FoodCategory.parotta,
      isPopular: true,
      isAvailable: true,
      rating: 4.6,
      reviewCount: 221,
      addons: [commonAddons[1], commonAddons[3]],
    ),

    // Grill
    MenuItemModel(
      id: 'item_12',
      name: 'Chicken Grill',
      description: 'Marinated chicken grilled to perfection',
      price: 200,
      imageUrl: 'https://images.unsplash.com/photo-1598515214211-89d3c73ae83b?w=800&q=80',
      category: FoodCategory.grill,
      isPopular: true,
      isAvailable: true,
      rating: 4.7,
      reviewCount: 198,
    ),

    // Drinks
    MenuItemModel(
      id: 'item_15',
      name: 'Mango Lassi',
      description: 'Refreshing mango yogurt drink',
      price: 60,
      imageUrl: 'https://images.unsplash.com/photo-1534353436294-0dbd4bdac845?w=800&q=80',
      category: FoodCategory.drinks,
      isAvailable: true,
      rating: 4.5,
      reviewCount: 267,
    ),
  ];

  // Banner images
  static final List<String> banners = [
    'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=1200&q=80',
    'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=1200&q=80',
    'https://images.unsplash.com/photo-1476224203421-9ac39bcb3327?w=1200&q=80',
  ];

  // Get items by category
  static List<MenuItemModel> getItemsByCategory(FoodCategory category) {
    return menuItems.where((item) => item.category == category).toList();
  }

  // Get popular items
  static List<MenuItemModel> getPopularItems() {
    return menuItems.where((item) => item.isPopular && item.isAvailable).toList();
  }

  // Get available items
  static List<MenuItemModel> getAvailableItems() {
    return menuItems.where((item) => item.isAvailable).toList();
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
