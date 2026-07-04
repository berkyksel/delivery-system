import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/delivery_model.dart';
import '../../data/repositories/delivery_repository.dart';
import 'auth_provider.dart';

// ── Delivery Repository ───────────────────────────────────────────────────────
final deliveryRepositoryProvider =
    Provider<DeliveryRepository>((ref) => DeliveryRepository());

// ── Aktif Kullanıcının Teslimatları (Real-time) ───────────────────────────────
/// Oturum açmış şoförün teslimatlarını Firestore'dan real-time dinler.
final myDeliveriesProvider = StreamProvider<List<DeliveryModel>>((ref) {
  final user = ref.watch(currentFirebaseUserProvider);
  if (user == null) return const Stream.empty();
  return ref
      .watch(deliveryRepositoryProvider)
      .getDeliveriesForDriver(user.uid);
});

// ── Bugünkü Teslimatlar ───────────────────────────────────────────────────────
final todayDeliveriesProvider = StreamProvider<List<DeliveryModel>>((ref) {
  final user = ref.watch(currentFirebaseUserProvider);
  if (user == null) return const Stream.empty();
  return ref
      .watch(deliveryRepositoryProvider)
      .getTodayDeliveries(user.uid);
});

// ── Tüm Teslimatlar — Admin (Real-time) ───────────────────────────────────────
final allDeliveriesProvider = StreamProvider<List<DeliveryModel>>((ref) {
  return ref.watch(deliveryRepositoryProvider).getAllDeliveries();
});

// ── Admin İstatistikleri ──────────────────────────────────────────────────────
/// Tüm teslimatlardan hesaplanan özet istatistikler
final adminStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final allAsync = ref.watch(allDeliveriesProvider);
  final all = allAsync.value ?? [];

  final today = DateTime.now();
  final todayList = all.where((d) =>
      d.createdAt.year == today.year &&
      d.createdAt.month == today.month &&
      d.createdAt.day == today.day).toList();

  final totalEarnings = all
      .where((d) => d.status == DeliveryStatus.completed)
      .fold(0.0, (sum, d) => sum + d.totalFee);

  return {
    'total': all.length,
    'todayCount': todayList.length,
    'completed': all.where((d) => d.status == DeliveryStatus.completed).length,
    'inProgress': all.where((d) => d.status == DeliveryStatus.inProgress).length,
    'pending': all.where((d) => d.status == DeliveryStatus.pending).length,
    'totalEarnings': totalEarnings,
    'tunnelCount': all.where((d) => d.tunnelUsed).length,
  };
});

// ── Teslimat Oluşturma Notifier ───────────────────────────────────────────────
class CreateDeliveryNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async => null;

  Future<void> create(DeliveryModel delivery) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final id = await ref
          .read(deliveryRepositoryProvider)
          .createDelivery(delivery);
      return id;
    });
  }

  void reset() {
    state = const AsyncData(null);
  }
}

final createDeliveryProvider =
    AsyncNotifierProvider<CreateDeliveryNotifier, String?>(
        CreateDeliveryNotifier.new);

// ── Durum Güncelleme Notifier ─────────────────────────────────────────────────
class UpdateDeliveryStatusNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> updateStatus(String id, DeliveryStatus status) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(deliveryRepositoryProvider)
          .updateStatus(id, status);
    });
  }
}

final updateDeliveryStatusProvider =
    AsyncNotifierProvider<UpdateDeliveryStatusNotifier, void>(
        UpdateDeliveryStatusNotifier.new);
