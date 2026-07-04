import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_profile_model.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/tariff_repository.dart';
import 'auth_provider.dart';

// ── Tariff Repository ─────────────────────────────────────────────────────────
final tariffRepositoryProvider =
    Provider<TariffRepository>((ref) => TariffRepository());

// ── Kullanıcı Profili Güncelleme Notifier ─────────────────────────────────────
class UserProfileNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> updateProfile(UserProfile profile) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(userRepositoryProvider).updateProfile(profile);
    });
  }

  Future<void> updateCurrentSide(String uid, String side) async {
    state = await AsyncValue.guard(() async {
      await ref.read(userRepositoryProvider).updateCurrentSide(uid, side);
    });
  }

  Future<void> updateNotifications(String uid, bool enabled) async {
    state = await AsyncValue.guard(() async {
      await ref
          .read(userRepositoryProvider)
          .updateNotifications(uid, enabled);
    });
  }
}

final userProfileNotifierProvider =
    AsyncNotifierProvider<UserProfileNotifier, void>(UserProfileNotifier.new);

// ── Global Tarife Stream ──────────────────────────────────────────────────────
/// Admin'in güncellediği global tarife ayarlarını real-time dinler
final globalTariffProvider = StreamProvider<Map<String, dynamic>>((ref) {
  return ref.watch(tariffRepositoryProvider).getTariffStream();
});

// ── Admin: Tarife Güncelleme Notifier ────────────────────────────────────────
class AdminTariffNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> updateTariff({
    required double tunnelFee,
    required double gensetFee,
    required double adrFee,
    required double defaultDieselPercent,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(tariffRepositoryProvider).updateGlobalTariff(
            tunnelFee: tunnelFee,
            gensetFee: gensetFee,
            adrFee: adrFee,
            defaultDieselPercent: defaultDieselPercent,
          );
    });
  }
}

final adminTariffNotifierProvider =
    AsyncNotifierProvider<AdminTariffNotifier, void>(AdminTariffNotifier.new);

// ── Admin: Şoför Rolü Değiştirme ──────────────────────────────────────────────
class AdminDriversNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> updateRole(String uid, UserRole role) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(userRepositoryProvider).updateRole(uid, role);
    });
  }

  Future<void> deleteUser(String uid) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(userRepositoryProvider).deleteUser(uid);
    });
  }
}

final adminDriversNotifierProvider =
    AsyncNotifierProvider<AdminDriversNotifier, void>(
        AdminDriversNotifier.new);
