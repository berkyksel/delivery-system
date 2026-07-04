import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/delivery_model.dart';
import '../../core/constants/app_constants.dart';

/// Firestore `deliveries` koleksiyonu üzerinde CRUD işlemleri
class DeliveryRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(AppConstants.deliveriesCollection);

  // ── Teslimat Oluştur ──────────────────────────────────────────────────────
  Future<String> createDelivery(DeliveryModel delivery) async {
    final docRef = await _col.add(delivery.toFirestore());
    return docRef.id;
  }

  // ── Belirli Şoförün Teslimatları (Real-time) ──────────────────────────────
  Stream<List<DeliveryModel>> getDeliveriesForDriver(String driverId) {
    return _col
        .where('driverId', isEqualTo: driverId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => DeliveryModel.fromFirestore(doc))
            .toList());
  }

  // ── Tüm Teslimatlar — Admin (Real-time) ───────────────────────────────────
  Stream<List<DeliveryModel>> getAllDeliveries() {
    return _col
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => DeliveryModel.fromFirestore(doc))
            .toList());
  }

  // ── Bugünkü Teslimatlar ───────────────────────────────────────────────────
  Stream<List<DeliveryModel>> getTodayDeliveries(String driverId) {
    final startOfDay = DateTime.now().copyWith(
      hour: 0,
      minute: 0,
      second: 0,
      millisecond: 0,
    );
    return _col
        .where('driverId', isEqualTo: driverId)
        .where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => DeliveryModel.fromFirestore(doc))
            .toList());
  }

  // ── Tek Teslimat ──────────────────────────────────────────────────────────
  Future<DeliveryModel?> getDelivery(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) return null;
    return DeliveryModel.fromFirestore(doc);
  }

  // ── Durum Güncelle ────────────────────────────────────────────────────────
  Future<void> updateStatus(String id, DeliveryStatus status) async {
    await _col.doc(id).update({'status': status.name});
  }

  // ── Teklif Durumu Güncelle ────────────────────────────────────────────────
  Future<void> updateQuoteStatus(String id, QuoteStatus quoteStatus) async {
    await _col.doc(id).update({'quoteStatus': quoteStatus.name});
  }

  // ── Fatura Numarası Ekle ──────────────────────────────────────────────────
  Future<void> markAsInvoiced({
    required String id,
    required String invoiceNumber,
    required DateTime invoiceDate,
    required DateTime invoiceDueDate,
  }) async {
    await _col.doc(id).update({
      'invoiceNumber': invoiceNumber,
      'invoiceDate': Timestamp.fromDate(invoiceDate),
      'invoiceDueDate': Timestamp.fromDate(invoiceDueDate),
      'quoteStatus': QuoteStatus.invoiced.name,
    });
  }

  // ── Teslimat Sil ──────────────────────────────────────────────────────────
  Future<void> deleteDelivery(String id) async {
    await _col.doc(id).delete();
  }

  // ── Teslimat Güncelle ─────────────────────────────────────────────────────
  Future<void> updateDelivery(DeliveryModel delivery) async {
    if (delivery.id == null) return;
    await _col.doc(delivery.id).update(delivery.toFirestore());
  }

  // ── Bu Ay İstatistikleri ──────────────────────────────────────────────────
  Future<Map<String, dynamic>> getMonthlyStats(String driverId) async {
    final startOfMonth = DateTime.now().copyWith(
      day: 1,
      hour: 0,
      minute: 0,
      second: 0,
      millisecond: 0,
    );
    final snap = await _col
        .where('driverId', isEqualTo: driverId)
        .where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .get();

    final deliveries =
        snap.docs.map((doc) => DeliveryModel.fromFirestore(doc)).toList();

    final totalEarnings = deliveries
        .where((d) => d.status == DeliveryStatus.completed)
        .fold(0.0, (total, d) => total + d.totalFee);

    final tunnelCount = deliveries.where((d) => d.tunnelUsed).length;

    return {
      'count': deliveries.length,
      'earnings': totalEarnings,
      'tunnels': tunnelCount,
    };
  }
}
