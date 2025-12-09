// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String usersCollection = 'users';

  FirestoreService();

  /// Ambil user doc reference
  DocumentReference<Map<String, dynamic>> userRef(String uid) {
    return _db.collection(usersCollection).doc(uid);
  }

  /// Periksa apakah user ada
  Future<DocumentSnapshot<Map<String, dynamic>>> getUser(String uid) async {
    return await userRef(uid).get();
  }

  /// Buat user awal (jika belum ada)
  Future<void> createUser({
    required String uid,
    required String name,
    required String email,
    String? photoUrl,
    Map<String, dynamic>? extra,
  }) async {
    final docRef = userRef(uid);
    final data = <String, dynamic>{
      'name': name,
      'email': email,
      'photoUrl': photoUrl ?? '',
      'createdAt': FieldValue.serverTimestamp(),
      // tambahkan field lain bila perlu
    };
    if (extra != null) {
      data.addAll(extra);
    }
    await docRef.set(data, SetOptions(merge: true));
  }

  /// Update user partial
  Future<void> updateUser(String uid, Map<String, dynamic> updates) async {
    await userRef(uid).set(updates, SetOptions(merge: true));
  }

  /// Hapus user (jika diperlukan)
  Future<void> deleteUser(String uid) async {
    await userRef(uid).delete();
  }
}
