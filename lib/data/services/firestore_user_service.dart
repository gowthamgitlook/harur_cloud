import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/models/user_model.dart';
import '../../shared/enums/user_role.dart';

class FirestoreUserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    data['id'] = doc.id;
    return UserModel.fromJson(data);
  }

  Future<void> createUser(UserModel user) async {
    await _db.collection('users').doc(user.id).set(user.toJson());
  }

  Future<void> updateUser(UserModel user) async {
    await _db.collection('users').doc(user.id).set(user.toJson(), SetOptions(merge: true));
  }

  Future<UserModel?> getUserByPhone(String phone) async {
    final snap = await _db
        .collection('users')
        .where('phone', isEqualTo: phone)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    final data = snap.docs.first.data();
    data['id'] = snap.docs.first.id;
    return UserModel.fromJson(data);
  }

  Future<List<UserModel>> getUsersByRole(UserRole role) async {
    final snap = await _db
        .collection('users')
        .where('role', isEqualTo: role.name)
        .get();
    return snap.docs.map((d) {
      final data = d.data();
      data['id'] = d.id;
      return UserModel.fromJson(data);
    }).toList();
  }
}
