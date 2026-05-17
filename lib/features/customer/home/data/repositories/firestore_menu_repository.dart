import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../../../shared/models/menu_item_model.dart';
import '../../../../../shared/models/restaurant_model.dart';
import 'menu_repository.dart';

class FirestoreMenuRepository implements IMenuRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static final RestaurantModel _restaurant = RestaurantModel(
    id: 'res_1',
    name: 'Harur Cloud Kitchen',
    description: 'Fresh home-style cooking delivered to your door',
    imageUrl:
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=1200&q=80',
    rating: 4.5,
    reviewCount: 0,
    deliveryTime: '25-35 mins',
    priceForTwo: 300.0,
    cuisine: 'South Indian, Biryani',
    isVegetarian: false,
    isOpen: true,
    latitude: 12.0540,
    longitude: 78.4822,
    address: 'Harur, Tamil Nadu',
  );

  @override
  Future<List<MenuItemModel>> getMenuItems() async {
    try {
      final snapshot = await _db.collection('menu').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return MenuItemModel.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('FirestoreMenuRepository.getMenuItems error: $e');
      return [];
    }
  }

  @override
  Future<List<RestaurantModel>> getRestaurants() async {
    return [_restaurant];
  }

  @override
  Future<List<String>> getBanners() async {
    try {
      final snapshot = await _db.collection('banners').get();
      return snapshot.docs
          .map((doc) => doc.data()['imageUrl'] as String? ?? '')
          .where((url) => url.isNotEmpty)
          .toList();
    } catch (e) {
      debugPrint('FirestoreMenuRepository.getBanners error: $e');
      return [];
    }
  }
}
