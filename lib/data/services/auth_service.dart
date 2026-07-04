import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/user_profile_model.dart';
import '../../core/constants/app_constants.dart';

/// Firebase Authentication işlemlerini yönetir.
/// AuthState değişikliklerini stream olarak yayınlar.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── Auth State ────────────────────────────────────────────────────────────
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => _auth.currentUser != null;

  // ── Giriş Yap ─────────────────────────────────────────────────────────────
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    }
  }

  // ── Kayıt Ol ──────────────────────────────────────────────────────────────
  Future<UserCredential> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? vehiclePlate,
    String? vehicleType,
    UserRole role = UserRole.driver,
  }) async {
    try {
      // Firebase Auth kaydı
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Kullanıcı profilini Firestore'a kaydet
      if (credential.user != null) {
        final profile = UserProfile(
          uid: credential.user!.uid,
          email: email.trim(),
          firstName: firstName,
          lastName: lastName,
          vehiclePlate: vehiclePlate,
          vehicleType: vehicleType,
          role: role,
          createdAt: DateTime.now(),
        );
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(credential.user!.uid)
            .set(profile.toFirestore());
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    }
  }

  // ── Çıkış Yap ─────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ── Şifre Sıfırla ─────────────────────────────────────────────────────────
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    }
  }

  // ── Kullanıcı Rolünü Getir ─────────────────────────────────────────────────
  Future<UserRole?> getCurrentUserRole() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();
      if (!doc.exists) return null;
      final data = doc.data() as Map<String, dynamic>;
      return UserRole.values.firstWhere(
        (r) => r.name == data['role'],
        orElse: () => UserRole.driver,
      );
    } catch (_) {
      return null;
    }
  }

  // ── Hata Eşleme ───────────────────────────────────────────────────────────
  AuthException _mapAuthError(FirebaseAuthException e) {
    return switch (e.code) {
      'user-not-found' => AuthException('Bu e-posta ile kayıtlı kullanıcı bulunamadı.'),
      'wrong-password' => AuthException('Şifre hatalı.'),
      'invalid-credential' => AuthException('E-posta veya şifre hatalı.'),
      'email-already-in-use' => AuthException('Bu e-posta zaten kullanımda.'),
      'weak-password' => AuthException('Şifre en az 6 karakter olmalıdır.'),
      'invalid-email' => AuthException('Geçersiz e-posta adresi.'),
      'network-request-failed' => AuthException('İnternet bağlantısı yok.'),
      'too-many-requests' => AuthException('Çok fazla deneme. Lütfen bekleyin.'),
      'user-disabled' => AuthException('Bu hesap devre dışı bırakıldı.'),
      _ => AuthException('Bir hata oluştu: ${e.message}'),
    };
  }
}

/// Firebase Auth hatalarını taşıyan exception sınıfı
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}
