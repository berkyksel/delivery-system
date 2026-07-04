import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../core/constants/app_constants.dart';
import '../../data/models/tariff_zone_model.dart';

/// Tarife ayarlarını Firestore ve lokal SharedPreferences'da saklar.
/// Admin panel üzerinden güncellenen ücretler tüm kullanıcılara senkronize olur.
class TariffRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String _localTariffKey = 'cached_tariff';
  static const String _adminTariffDocId = 'global_tariff';

  // ── Global Tarife Getir (Real-time) ───────────────────────────────────────
  Stream<Map<String, dynamic>> getTariffStream() {
    return _db
        .collection(AppConstants.tariffsCollection)
        .doc(_adminTariffDocId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return _defaultTariffMap();
      return doc.data() ?? _defaultTariffMap();
    });
  }

  // ── Global Tarife Getir (Tek seferlik + cache) ────────────────────────────
  Future<Map<String, dynamic>> getTariff() async {
    try {
      final doc = await _db
          .collection(AppConstants.tariffsCollection)
          .doc(_adminTariffDocId)
          .get();
      if (doc.exists && doc.data() != null) {
        // Lokal cache'e yaz
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_localTariffKey, jsonEncode(doc.data()));
        return doc.data()!;
      }
      return await _getCachedTariff();
    } catch (_) {
      return await _getCachedTariff();
    }
  }

  // ── Kullanıcıya Özel Tarife Kaydet (Lokal) ───────────────────────────────
  Future<void> saveUserTariff(UserTariff tariff) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.tariffBox,
      jsonEncode(tariff.toJson()),
    );
  }

  // ── Kullanıcıya Özel Tarife Getir (Lokal) ────────────────────────────────
  Future<UserTariff?> getUserTariff() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(AppConstants.tariffBox);
    if (raw == null) return null;
    try {
      // Basit tariff verisi
      return UserTariff.defaultTariff();
    } catch (_) {
      return null;
    }
  }

  // ── Admin: Global Tarife Güncelle ────────────────────────────────────────
  Future<void> updateGlobalTariff({
    required double tunnelFee,
    required double gensetFee,
    required double adrFee,
    required double defaultDieselPercent,
  }) async {
    await _db
        .collection(AppConstants.tariffsCollection)
        .doc(_adminTariffDocId)
        .set({
      'tunnelFee': tunnelFee,
      'gensetFee': gensetFee,
      'adrFee': adrFee,
      'defaultDieselPercent': defaultDieselPercent,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ── Cache ─────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> _getCachedTariff() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_localTariffKey);
      if (raw != null) return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {}
    return _defaultTariffMap();
  }

  Map<String, dynamic> _defaultTariffMap() => {
        'tunnelFee': 17.60,
        'gensetFee': 0.0,
        'adrFee': 0.0,
        'defaultDieselPercent': 0.0,
      };
}
