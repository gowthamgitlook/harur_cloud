import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/models/menu_item_model.dart';

abstract class IMenuService {
  Future<List<MenuItemModel>> getMenuItems();
  Future<List<String>> getBanners();
}

class FirestoreMenuService implements IMenuService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<MenuItemModel>> getMenuItems() async {
    final snapshot = await _firestore.collection('menu_items').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return MenuItemModel.fromJson(data);
    }).toList();
  }

  @override
  Future<List<String>> getBanners() async {
    final snapshot = await _firestore.collection('banners').get();
    return snapshot.docs.map((doc) => doc.data()['imageUrl'] as String).toList();
  }
}
