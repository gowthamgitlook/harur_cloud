import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../../../shared/models/menu_item_model.dart';

class FirestoreAdminMenuService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _controller = StreamController<List<MenuItemModel>>.broadcast();
  StreamSubscription? _firestoreSubscription;

  Stream<List<MenuItemModel>> get menuStream => _controller.stream;

  FirestoreAdminMenuService() {
    _firestoreSubscription = _db
        .collection('menu')
        .snapshots()
        .listen((snapshot) {
      final items = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return MenuItemModel.fromJson(data);
      }).toList();
      _controller.add(items);
    }, onError: (e) {
      debugPrint('FirestoreAdminMenuService stream error: $e');
    });
  }

  Future<List<MenuItemModel>> getAllMenuItems() async {
    final snapshot = await _db.collection('menu').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return MenuItemModel.fromJson(data);
    }).toList();
  }

  Future<MenuItemModel> addMenuItem(MenuItemModel item) async {
    final data = item.toJson()..remove('id');
    final ref = await _db.collection('menu').add(data);
    return item.copyWith(id: ref.id);
  }

  Future<MenuItemModel> updateMenuItem(MenuItemModel item) async {
    await _db.collection('menu').doc(item.id).set(item.toJson());
    return item;
  }

  Future<bool> deleteMenuItem(String itemId) async {
    await _db.collection('menu').doc(itemId).delete();
    return true;
  }

  Future<bool> toggleAvailability(String itemId, bool isAvailable) async {
    await _db.collection('menu').doc(itemId).update({'isAvailable': isAvailable});
    return true;
  }

  Future<MenuItemModel?> getMenuItemById(String itemId) async {
    final doc = await _db.collection('menu').doc(itemId).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    data['id'] = doc.id;
    return MenuItemModel.fromJson(data);
  }

  void dispose() {
    _firestoreSubscription?.cancel();
    _controller.close();
  }
}
