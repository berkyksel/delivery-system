import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/user_profile_model.dart';
import '../../core/constants/app_constants.dart';

/// Firestore `users` koleksiyonu üzerinde CRUD işlemleri
class UserRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(AppConstants.usersCollection);

  // ── Profil Oluştur ────────────────────────────────────────────────────────
  Future<void> createProfile(UserProfile profile) async {
    await _col.doc(profile.uid).set(profile.toFirestore());
  }

  // ── Profil Getir (Real-time) ──────────────────────────────────────────────
  Stream<UserProfile?> getUserProfileStream(String uid) {
    return _col.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserProfile.fromFirestore(doc);
    });
  }

  // ── Profil Getir (Tek seferlik) ───────────────────────────────────────────
  Future<UserProfile?> getUserProfile(String uid) async {
    final doc = await _col.doc(uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromFirestore(doc);
  }

  // ── Profil Güncelle ───────────────────────────────────────────────────────
  Future<void> updateProfile(UserProfile profile) async {
    await _col.doc(profile.uid).update(profile.toFirestore());
  }

  // ── Mevcut Konum Güncelle ─────────────────────────────────────────────────
  Future<void> updateCurrentSide(String uid, String side) async {
    await _col.doc(uid).update({'currentSide': side});
  }

  // ── Bildirim Tercihi Güncelle ─────────────────────────────────────────────
  Future<void> updateNotifications(String uid, bool enabled) async {
    await _col.doc(uid).update({'notificationsEnabled': enabled});
  }

  // ── Tüm Şoförler — Admin (Real-time) ─────────────────────────────────────
  Stream<List<UserProfile>> getAllDrivers() {
    return _col
        .where('role', isEqualTo: UserRole.driver.name)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => UserProfile.fromFirestore(doc)).toList());
  }

  // ── Tüm Kullanıcılar — Admin (Real-time) ─────────────────────────────────
  Stream<List<UserProfile>> getAllUsers() {
    return _col.snapshots().map((snap) =>
        snap.docs.map((doc) => UserProfile.fromFirestore(doc)).toList());
  }

  // ── Kullanıcı Rolünü Güncelle ─────────────────────────────────────────────
  Future<void> updateRole(String uid, UserRole role) async {
    await _col.doc(uid).update({'role': role.name});
  }

  // ── Kullanıcı Sil ────────────────────────────────────────────────────────
  Future<void> deleteUser(String uid) async {
    await _col.doc(uid).delete();
  }
}
