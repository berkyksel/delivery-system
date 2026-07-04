import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/auth_service.dart';
import '../../data/models/user_profile_model.dart';
import '../../data/repositories/user_repository.dart';

// ── Auth Servisi ──────────────────────────────────────────────────────────────
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// ── Firebase Auth State Stream ────────────────────────────────────────────────
/// Firebase kullanıcısını dinler. null = giriş yapılmamış.
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// ── Mevcut Firebase Kullanıcısı ───────────────────────────────────────────────
final currentFirebaseUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).value;
});

// ── User Repository ───────────────────────────────────────────────────────────
final userRepositoryProvider = Provider<UserRepository>((ref) => UserRepository());

// ── Mevcut Kullanıcı Profili (Firestore) ─────────────────────────────────────
/// Oturum açmış kullanıcının Firestore profilini real-time dinler.
final currentUserProfileProvider = StreamProvider<UserProfile?>((ref) {
  final firebaseUser = ref.watch(currentFirebaseUserProvider);
  if (firebaseUser == null) return const Stream.empty();
  return ref
      .watch(userRepositoryProvider)
      .getUserProfileStream(firebaseUser.uid);
});

// ── Kullanıcı Rolü ────────────────────────────────────────────────────────────
final currentUserRoleProvider = Provider<UserRole?>((ref) {
  final profileAsync = ref.watch(currentUserProfileProvider);
  return profileAsync.value?.role;
});

// ── Giriş Durumu ─────────────────────────────────────────────────────────────
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(currentFirebaseUserProvider) != null;
});

// ── Admin mi? ─────────────────────────────────────────────────────────────────
final isAdminProvider = Provider<bool>((ref) {
  return ref.watch(currentUserRoleProvider) == UserRole.manager;
});

// ── Tüm Şoförler — Admin ──────────────────────────────────────────────────────
final allDriversProvider = StreamProvider<List<UserProfile>>((ref) {
  return ref.watch(userRepositoryProvider).getAllDrivers();
});

// ── Auth State Notifier (Giriş / Çıkış işlemleri) ─────────────────────────────
class AuthNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authServiceProvider).signIn(
            email: email,
            password: password,
          ),
    );
  }

  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? vehiclePlate,
    String? vehicleType,
    UserRole role = UserRole.driver,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authServiceProvider).register(
            email: email,
            password: password,
            firstName: firstName,
            lastName: lastName,
            vehiclePlate: vehiclePlate,
            vehicleType: vehicleType,
            role: role,
          ),
    );
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authServiceProvider).signOut(),
    );
  }

  Future<void> sendPasswordReset(String email) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authServiceProvider).sendPasswordResetEmail(email),
    );
  }
}

final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, void>(AuthNotifier.new);
