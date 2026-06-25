/// TIR / Kamyon modeli
class TruckModel {
  final String id;
  final String brand;
  final String model;
  final double fuelConsumptionPer100km; // L/100km (ortalama)
  final double tankCapacityLiters;
  final String axleConfig; // örn. "4x2", "6x4"

  const TruckModel({
    required this.id,
    required this.brand,
    required this.model,
    required this.fuelConsumptionPer100km,
    required this.tankCapacityLiters,
    required this.axleConfig,
  });

  String get fullName => '$brand $model';
  String get displayName => '$brand $model ($axleConfig)';

  /// Belirli bir mesafe için tahmini yakıt tüketimini hesaplar
  double estimatedFuelLiters(double distanceKm) {
    return (distanceKm / 100) * fuelConsumptionPer100km;
  }

  /// Belirli bir mesafe ve dizel fiyatı için tahmini yakıt maliyeti
  double estimatedFuelCost(double distanceKm, double dieselPricePerLiter) {
    return estimatedFuelLiters(distanceKm) * dieselPricePerLiter;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'brand': brand,
        'model': model,
        'fuelConsumptionPer100km': fuelConsumptionPer100km,
        'tankCapacityLiters': tankCapacityLiters,
        'axleConfig': axleConfig,
      };
}

/// Sabit TIR modelleri kataloğu
class TruckCatalog {
  TruckCatalog._();

  static const List<TruckModel> models = [
    // ─── DAF ──────────────────────────────────────────────────────────────────
    TruckModel(
      id: 'daf_xf_480',
      brand: 'DAF',
      model: 'XF 480',
      fuelConsumptionPer100km: 28.0,
      tankCapacityLiters: 700,
      axleConfig: '4x2',
    ),
    TruckModel(
      id: 'daf_xf_530',
      brand: 'DAF',
      model: 'XF 530',
      fuelConsumptionPer100km: 30.0,
      tankCapacityLiters: 700,
      axleConfig: '6x4',
    ),
    TruckModel(
      id: 'daf_cf_450',
      brand: 'DAF',
      model: 'CF 450',
      fuelConsumptionPer100km: 26.5,
      tankCapacityLiters: 590,
      axleConfig: '4x2',
    ),

    // ─── Volvo ────────────────────────────────────────────────────────────────
    TruckModel(
      id: 'volvo_fh_500',
      brand: 'Volvo',
      model: 'FH 500',
      fuelConsumptionPer100km: 29.0,
      tankCapacityLiters: 750,
      axleConfig: '4x2',
    ),
    TruckModel(
      id: 'volvo_fh_540',
      brand: 'Volvo',
      model: 'FH 540',
      fuelConsumptionPer100km: 31.0,
      tankCapacityLiters: 750,
      axleConfig: '6x4',
    ),
    TruckModel(
      id: 'volvo_fm_420',
      brand: 'Volvo',
      model: 'FM 420',
      fuelConsumptionPer100km: 27.0,
      tankCapacityLiters: 600,
      axleConfig: '4x2',
    ),

    // ─── Mercedes-Benz ────────────────────────────────────────────────────────
    TruckModel(
      id: 'mercedes_actros_1845',
      brand: 'Mercedes',
      model: 'Actros 1845',
      fuelConsumptionPer100km: 28.5,
      tankCapacityLiters: 690,
      axleConfig: '4x2',
    ),
    TruckModel(
      id: 'mercedes_actros_2545',
      brand: 'Mercedes',
      model: 'Actros 2545',
      fuelConsumptionPer100km: 32.0,
      tankCapacityLiters: 690,
      axleConfig: '6x4',
    ),
    TruckModel(
      id: 'mercedes_arocs_2645',
      brand: 'Mercedes',
      model: 'Arocs 2645',
      fuelConsumptionPer100km: 34.0,
      tankCapacityLiters: 720,
      axleConfig: '6x4',
    ),

    // ─── Scania ───────────────────────────────────────────────────────────────
    TruckModel(
      id: 'scania_r450',
      brand: 'Scania',
      model: 'R 450',
      fuelConsumptionPer100km: 27.5,
      tankCapacityLiters: 730,
      axleConfig: '4x2',
    ),
    TruckModel(
      id: 'scania_r500',
      brand: 'Scania',
      model: 'R 500',
      fuelConsumptionPer100km: 29.5,
      tankCapacityLiters: 730,
      axleConfig: '4x2',
    ),
    TruckModel(
      id: 'scania_s580',
      brand: 'Scania',
      model: 'S 580',
      fuelConsumptionPer100km: 31.5,
      tankCapacityLiters: 730,
      axleConfig: '6x4',
    ),

    // ─── MAN ──────────────────────────────────────────────────────────────────
    TruckModel(
      id: 'man_tgx_480',
      brand: 'MAN',
      model: 'TGX 480',
      fuelConsumptionPer100km: 28.0,
      tankCapacityLiters: 680,
      axleConfig: '4x2',
    ),
    TruckModel(
      id: 'man_tgx_540',
      brand: 'MAN',
      model: 'TGX 540',
      fuelConsumptionPer100km: 30.5,
      tankCapacityLiters: 680,
      axleConfig: '6x4',
    ),

    // ─── Iveco ────────────────────────────────────────────────────────────────
    TruckModel(
      id: 'iveco_s_way_480',
      brand: 'Iveco',
      model: 'S-Way 480',
      fuelConsumptionPer100km: 27.0,
      tankCapacityLiters: 620,
      axleConfig: '4x2',
    ),
  ];

  /// ID ile model ara
  static TruckModel? findById(String id) {
    try {
      return models.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Marka listesi (tekrarsız)
  static List<String> get brands =>
      models.map((m) => m.brand).toSet().toList()..sort();

  /// Belirli markaya ait modeller
  static List<TruckModel> byBrand(String brand) =>
      models.where((m) => m.brand == brand).toList();
}
