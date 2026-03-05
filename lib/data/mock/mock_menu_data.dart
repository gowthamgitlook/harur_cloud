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
      imageUrl: 'assets/images/chicken_biryani.png',
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
      imageUrl: 'assets/images/mutton_biryani.png',
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
      imageUrl: 'assets/images/egg_biryani.png',
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
      imageUrl: 'assets/images/veg_biryani.png',
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
      imageUrl: 'assets/images/chicken_fried_rice.png',
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
      imageUrl: 'assets/images/egg_fried_rice.png',
      category: FoodCategory.friedRice,
      isPopular: true,
      isAvailable: true,
      rating: 4.3,
      reviewCount: 203,
      addons: [commonAddons[0]],
    ),
    MenuItemModel(
      id: 'item_7',
      name: 'Veg Fried Rice',
      description: 'Mixed vegetable fried rice with soy sauce',
      price: 90,
      imageUrl: 'assets/images/veg_fried_rice.png',
      category: FoodCategory.friedRice,
      isAvailable: true,
      rating: 4.1,
      reviewCount: 134,
    ),
    MenuItemModel(
      id: 'item_8',
      name: 'Schezwan Fried Rice',
      description: 'Spicy Schezwan style fried rice with vegetables',
      price: 110,
      imageUrl: 'assets/images/schezwan_fried_rice.png',
      category: FoodCategory.friedRice,
      isAvailable: true,
      rating: 4.5,
      reviewCount: 167,
      addons: [commonAddons[0]],
    ),

    // Parotta
    MenuItemModel(
      id: 'item_9',
      name: 'Chicken Kothu Parotta',
      description: 'Shredded parotta stir-fried with chicken and spices',
      price: 150,
      imageUrl: 'assets/images/chicken_kothu_parotta.png',
      category: FoodCategory.parotta,
      isPopular: true,
      isAvailable: true,
      rating: 4.6,
      reviewCount: 221,
      addons: [commonAddons[1], commonAddons[3]],
    ),
    MenuItemModel(
      id: 'item_10',
      name: 'Egg Parotta',
      description: 'Layered parotta with egg coating',
      price: 80,
      imageUrl: 'assets/images/egg_parotta.png',
      category: FoodCategory.parotta,
      isAvailable: true,
      rating: 4.2,
      reviewCount: 145,
      addons: [commonAddons[3]],
    ),
    MenuItemModel(
      id: 'item_11',
      name: 'Plain Parotta',
      description: 'Soft and flaky layered flatbread',
      price: 50,
      imageUrl: 'assets/images/plain_parotta.png',
      category: FoodCategory.parotta,
      isAvailable: true,
      rating: 4.0,
      reviewCount: 187,
      addons: [commonAddons[3]],
    ),

    // Grill
    MenuItemModel(
      id: 'item_12',
      name: 'Chicken Grill',
      description: 'Marinated chicken grilled to perfection',
      price: 200,
      imageUrl: 'assets/images/chicken_grill.png',
      category: FoodCategory.grill,
      isPopular: true,
      isAvailable: true,
      rating: 4.7,
      reviewCount: 198,
    ),
    MenuItemModel(
      id: 'item_13',
      name: 'Tandoori Chicken',
      description: 'Classic tandoori chicken with Indian spices',
      price: 220,
      imageUrl: 'assets/images/tandoori_chicken.png',
      category: FoodCategory.grill,
      isAvailable: true,
      rating: 4.6,
      reviewCount: 176,
    ),
    MenuItemModel(
      id: 'item_14',
      name: 'Fish Grill',
      description: 'Fresh fish marinated and grilled',
      price: 250,
      imageUrl: 'assets/images/fish_grill.png',
      category: FoodCategory.grill,
      isAvailable: false,
      rating: 4.4,
      reviewCount: 89,
    ),

    // Drinks
    MenuItemModel(
      id: 'item_15',
      name: 'Mango Lassi',
      description: 'Refreshing mango yogurt drink',
      price: 60,
      imageUrl: 'assets/images/mango_lassi.png',
      category: FoodCategory.drinks,
      isAvailable: true,
      rating: 4.5,
      reviewCount: 267,
    ),
    MenuItemModel(
      id: 'item_16',
      name: 'Lime Soda',
      description: 'Fresh lime soda with mint',
      price: 40,
      imageUrl: 'assets/images/lime_soda.png',
      category: FoodCategory.drinks,
      isAvailable: true,
      rating: 4.2,
      reviewCount: 189,
    ),
    MenuItemModel(
      id: 'item_17',
      name: 'Buttermilk',
      description: 'Traditional spiced buttermilk',
      price: 30,
      imageUrl: 'assets/images/buttermilk.png',
      category: FoodCategory.drinks,
      isAvailable: true,
      rating: 4.3,
      reviewCount: 145,
    ),
    MenuItemModel(
      id: 'item_18',
      name: 'Soft Drink',
      description: 'Chilled soft drink',
      price: 35,
      imageUrl: 'assets/images/soft_drink.png',
      category: FoodCategory.drinks,
      isAvailable: true,
      rating: 4.0,
      reviewCount: 98,
    ),
  ];

  // Banner images
  static final List<String> banners = [
    'assets/images/banner1.png',
    'assets/images/banner2.png',
    'assets/images/banner3.png',
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
