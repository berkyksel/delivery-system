/// Km aralığına göre tarife dilimi
class TariffZone {
  final double minKm;      // başlangıç km (dahil)
  final double? maxKm;     // bitiş km (dahil), null = sınırsız
  final double fixedFee;   // sabit ücret (€)
  final double? perKmRate; // km başı ücret (€/km), null = sabit ücret kullanılır
  final String label;      // görüntü etiketi, örn. "0 – 25 km"

  const TariffZone({
    required this.minKm,
    this.maxKm,
    required this.fixedFee,
    this.perKmRate,
    required this.label,
  });

  bool containsKm(double km) {
    if (km < minKm) return false;
    if (maxKm == null) return true;
    return km <= maxKm!;
  }

  /// Bu dilim için ücret hesapla
  double calculateFee(double km) {
    if (perKmRate != null && perKmRate! > 0) {
      return km * perKmRate!;
    }
    return fixedFee;
  }

  TariffZone copyWith({
    double? minKm,
    double? maxKm,
    double? fixedFee,
    double? perKmRate,
    String? label,
  }) {
    return TariffZone(
      minKm: minKm ?? this.minKm,
      maxKm: maxKm ?? this.maxKm,
      fixedFee: fixedFee ?? this.fixedFee,
      perKmRate: perKmRate ?? this.perKmRate,
      label: label ?? this.label,
    );
  }

  Map<String, dynamic> toMap() => {
        'minKm': minKm,
        'maxKm': maxKm,
        'fixedFee': fixedFee,
        'perKmRate': perKmRate,
        'label': label,
      };

  factory TariffZone.fromMap(Map<String, dynamic> map) => TariffZone(
        minKm: (map['minKm'] as num).toDouble(),
        maxKm: map['maxKm'] != null ? (map['maxKm'] as num).toDouble() : null,
        fixedFee: (map['fixedFee'] as num).toDouble(),
        perKmRate: map['perKmRate'] != null
            ? (map['perKmRate'] as num).toDouble()
            : null,
        label: map['label'] as String? ?? '',
      );
}

/// Tarife hesaplama modu
enum TariffMode {
  havenBased,   // Haven numarasına göre sabit ücret (mevcut sistem)
  kmZone,       // Km aralıklarına göre (0-25, 25-50, 50-100)
  perKm,        // Her km başına sabit birim fiyat
}

/// Kullanıcı / şirket tarife profili
class UserTariff {
  /// Haven numarası bazlı özel ücretler: {"1700": 14.0, "869-913": 20.0}
  final Map<String, double> havenRates;

  /// Km aralık dilimleri (adres teslimatı için)
  final List<TariffZone> kmZones;

  /// Km başı ücret (TariffMode.perKm için)
  final double perKmRate;

  /// Minimum ücret (km bazlı için)
  final double minimumFee;

  /// Tünel ücreti (Kennedy)
  final double tunnelFee;

  /// Genset ücreti
  final double gensetFee;

  /// ADR ücreti
  final double adrFee;

  /// Varsayılan dizel toeslag yüzdesi (örn. 8.0 = %8)
  final double defaultDieselSurchargePercent;

  /// Aktif tarife modu
  final TariffMode mode;

  const UserTariff({
    this.havenRates = const {},
    this.kmZones = const [],
    this.perKmRate = 0.0,
    this.minimumFee = 0.0,
    this.tunnelFee = 17.60,
    this.gensetFee = 0.0,
    this.adrFee = 0.0,
    this.defaultDieselSurchargePercent = 0.0,
    this.mode = TariffMode.havenBased,
  });

  /// Varsayılan tarife (sistem değerleri)
  factory UserTariff.defaultTariff() => const UserTariff(
        havenRates: {
          '1700': 14.0,
          '869-913': 20.0,
        },
        kmZones: [
          TariffZone(
            minKm: 0,
            maxKm: 25,
            fixedFee: 50.0,
            label: '0 – 25 km',
          ),
          TariffZone(
            minKm: 25,
            maxKm: 50,
            fixedFee: 80.0,
            label: '25 – 50 km',
          ),
          TariffZone(
            minKm: 50,
            maxKm: 100,
            fixedFee: 120.0,
            label: '50 – 100 km',
          ),
          TariffZone(
            minKm: 100,
            maxKm: null,
            fixedFee: 180.0,
            label: '100+ km',
          ),
        ],
        perKmRate: 1.20,
        minimumFee: 30.0,
        tunnelFee: 17.60,
        gensetFee: 25.0,
        adrFee: 35.0,
        defaultDieselSurchargePercent: 0.0,
        mode: TariffMode.havenBased,
      );

  UserTariff copyWith({
    Map<String, double>? havenRates,
    List<TariffZone>? kmZones,
    double? perKmRate,
    double? minimumFee,
    double? tunnelFee,
    double? gensetFee,
    double? adrFee,
    double? defaultDieselSurchargePercent,
    TariffMode? mode,
  }) {
    return UserTariff(
      havenRates: havenRates ?? this.havenRates,
      kmZones: kmZones ?? this.kmZones,
      perKmRate: perKmRate ?? this.perKmRate,
      minimumFee: minimumFee ?? this.minimumFee,
      tunnelFee: tunnelFee ?? this.tunnelFee,
      gensetFee: gensetFee ?? this.gensetFee,
      adrFee: adrFee ?? this.adrFee,
      defaultDieselSurchargePercent:
          defaultDieselSurchargePercent ?? this.defaultDieselSurchargePercent,
      mode: mode ?? this.mode,
    );
  }
}
