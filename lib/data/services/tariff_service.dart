import '../../core/constants/app_constants.dart';
import '../../data/models/tariff_zone_model.dart';

enum PortSide {
  rechteroever('Rechteroever', 'Sağ Kıyı'),
  linkeroever('Linkeroever', 'Sol Kıyı');

  final String dutchName;
  final String turkishName;
  const PortSide(this.dutchName, this.turkishName);
}

class DeliveryTariff {
  final double havenFee;
  final double tunnelFee;
  final double gensetFee;
  final double adrFee;
  final double dieselSurchargeFee;
  final double total;
  final PortSide destinationSide;
  final bool needsTunnel;
  final bool hasGenset;
  final bool isAdr;
  final int havenNumber;
  final int? estimatedMinutes;
  final TariffMode mode;
  final double? distanceKm;
  final double? zoneFee; // km zone ücreti (havenFee yerine kullanılır)

  const DeliveryTariff({
    required this.havenFee,
    required this.tunnelFee,
    required this.gensetFee,
    required this.adrFee,
    this.dieselSurchargeFee = 0.0,
    required this.total,
    required this.destinationSide,
    required this.needsTunnel,
    required this.hasGenset,
    required this.isAdr,
    required this.havenNumber,
    this.estimatedMinutes,
    this.mode = TariffMode.havenBased,
    this.distanceKm,
    this.zoneFee,
  });

  String get formattedTotal => '${total.toStringAsFixed(2)} €';
  String get formattedHavenFee => '${havenFee.toStringAsFixed(2)} €';
  String get formattedTunnelFee => '${tunnelFee.toStringAsFixed(2)} €';
  String get formattedGensetFee => '${gensetFee.toStringAsFixed(2)} €';
  String get formattedAdrFee => '${adrFee.toStringAsFixed(2)} €';
  String get formattedDieselFee => '${dieselSurchargeFee.toStringAsFixed(2)} €';

  /// Ana ücret (haven veya km bazlı)
  double get baseFee => zoneFee ?? havenFee;
}

class TariffService {
  /// Haven numarasına göre liman tarafını döndürür
  static PortSide getSide(int havenNumber) {
    if (havenNumber >= AppConstants.rechteroeverMin &&
        havenNumber <= AppConstants.rechteroeverMax) {
      return PortSide.rechteroever;
    }
    if (havenNumber >= AppConstants.linkeroeverMin &&
        havenNumber <= AppConstants.linkeroeverMax) {
      return PortSide.linkeroever;
    }
    throw ArgumentError(
        'Geçersiz haven numarası: $havenNumber (1-2000 arası olmalı)');
  }

  /// Haven numarasının geçerliliğini kontrol eder
  static bool isValidHaven(int havenNumber) {
    return havenNumber >= AppConstants.rechteroeverMin &&
        havenNumber <= AppConstants.linkeroeverMax;
  }

  /// Haven numarasına özel tarife döndürür
  static double getHavenFee(int havenNumber,
      {Map<String, double>? remoteConfig}) {
    // Remote Config'den tarife varsa kullan
    if (remoteConfig != null) {
      final key = havenNumber.toString();
      if (remoteConfig.containsKey(key)) {
        return remoteConfig[key]!;
      }
      // Aralık kontrolü
      for (final entry in remoteConfig.entries) {
        if (entry.key.contains('-')) {
          final parts = entry.key.split('-');
          if (parts.length == 2) {
            final min = int.tryParse(parts[0]);
            final max = int.tryParse(parts[1]);
            if (min != null &&
                max != null &&
                havenNumber >= min &&
                havenNumber <= max) {
              return entry.value;
            }
          }
        }
      }
    }

    // Sabit kurallar (fallback)
    if (havenNumber == AppConstants.haven1700) {
      return AppConstants.haven1700Fee;
    }
    if (havenNumber >= AppConstants.haven869 &&
        havenNumber <= AppConstants.haven913) {
      return AppConstants.haven869to913Fee;
    }

    return AppConstants.defaultHavenFee;
  }

  /// Dizel toeslag tutarını hesaplar
  /// [baseAmount]: toeslag uygulanacak baz miktar
  /// [percent]: yüzde değeri (örn. 8.0 = %8)
  static double calculateDieselSurcharge(double baseAmount, double percent) {
    if (percent <= 0) return 0.0;
    return baseAmount * (percent / 100);
  }

  /// Km aralığına göre ücret hesaplar (UserTariff.kmZones listesini kullanır)
  static double getZoneFee(double km, List<TariffZone> zones) {
    for (final zone in zones) {
      if (zone.containsKm(km)) {
        return zone.calculateFee(km);
      }
    }
    // Eğer hiçbir zone bulunamazsa son zone'un ücretini döndür
    if (zones.isNotEmpty) {
      return zones.last.calculateFee(km);
    }
    return 0.0;
  }

  /// Km başı ücret hesaplar
  static double getPerKmFee(double km, double ratePerKm,
      {double minimumFee = 0.0}) {
    final fee = km * ratePerKm;
    return fee < minimumFee ? minimumFee : fee;
  }

  /// Haven bazlı toplam teslimat ücretini hesaplar
  static DeliveryTariff calculate({
    required int havenNumber,
    required PortSide driverCurrentSide,
    bool hasGenset = false,
    bool isAdr = false,
    double dieselSurchargePercent = 0.0,
    Map<String, double>? remoteHavenTariffs,
    double? remoteTunnelFee,
    double? remoteGensetFee,
    double? remoteAdrFee,
    int? customEstimatedMinutes,
  }) {
    final destinationSide = getSide(havenNumber);
    final havenFee = getHavenFee(havenNumber, remoteConfig: remoteHavenTariffs);
    final needsTunnel = driverCurrentSide != destinationSide;
    final actualTunnelFee =
        needsTunnel ? (remoteTunnelFee ?? AppConstants.tunnelFee) : 0.0;
    final actualGensetFee =
        hasGenset ? (remoteGensetFee ?? AppConstants.gensetFee) : 0.0;
    final actualAdrFee = isAdr ? (remoteAdrFee ?? AppConstants.adrFee) : 0.0;

    final subtotal = havenFee + actualTunnelFee + actualGensetFee + actualAdrFee;
    final dieselFee = calculateDieselSurcharge(subtotal, dieselSurchargePercent);
    final total = subtotal + dieselFee;

    // Tahmini süre hesaplama
    int estimatedMinutes = AppConstants.averageDeliveryTimeMin;
    if (needsTunnel) {
      estimatedMinutes += AppConstants.averageTunnelWaitTime;
    }
    if (customEstimatedMinutes != null) {
      estimatedMinutes = customEstimatedMinutes;
    }

    return DeliveryTariff(
      havenFee: havenFee,
      tunnelFee: actualTunnelFee,
      gensetFee: actualGensetFee,
      adrFee: actualAdrFee,
      dieselSurchargeFee: dieselFee,
      total: total,
      destinationSide: destinationSide,
      needsTunnel: needsTunnel,
      hasGenset: hasGenset,
      isAdr: isAdr,
      havenNumber: havenNumber,
      estimatedMinutes: estimatedMinutes,
      mode: TariffMode.havenBased,
    );
  }

  /// Km aralık bazlı ücret hesaplar
  static DeliveryTariff calculateKmZone({
    required int havenNumber,
    required PortSide driverCurrentSide,
    required double distanceKm,
    required List<TariffZone> zones,
    bool hasGenset = false,
    bool isAdr = false,
    double dieselSurchargePercent = 0.0,
    double? remoteTunnelFee,
    double? remoteGensetFee,
    double? remoteAdrFee,
  }) {
    final destinationSide = getSide(havenNumber);
    final zoneFee = getZoneFee(distanceKm, zones);
    final needsTunnel = driverCurrentSide != destinationSide;
    final actualTunnelFee =
        needsTunnel ? (remoteTunnelFee ?? AppConstants.tunnelFee) : 0.0;
    final actualGensetFee =
        hasGenset ? (remoteGensetFee ?? AppConstants.gensetFee) : 0.0;
    final actualAdrFee = isAdr ? (remoteAdrFee ?? AppConstants.adrFee) : 0.0;

    final subtotal = zoneFee + actualTunnelFee + actualGensetFee + actualAdrFee;
    final dieselFee = calculateDieselSurcharge(subtotal, dieselSurchargePercent);
    final total = subtotal + dieselFee;

    int estimatedMinutes = (distanceKm / 60 * 60).round().clamp(15, 180);
    if (needsTunnel) estimatedMinutes += AppConstants.averageTunnelWaitTime;

    return DeliveryTariff(
      havenFee: 0.0,
      tunnelFee: actualTunnelFee,
      gensetFee: actualGensetFee,
      adrFee: actualAdrFee,
      dieselSurchargeFee: dieselFee,
      total: total,
      destinationSide: destinationSide,
      needsTunnel: needsTunnel,
      hasGenset: hasGenset,
      isAdr: isAdr,
      havenNumber: havenNumber,
      estimatedMinutes: estimatedMinutes,
      mode: TariffMode.kmZone,
      distanceKm: distanceKm,
      zoneFee: zoneFee,
    );
  }

  /// Km başı ücret hesaplar
  static DeliveryTariff calculatePerKm({
    required int havenNumber,
    required PortSide driverCurrentSide,
    required double distanceKm,
    required double ratePerKm,
    double minimumFee = 0.0,
    bool hasGenset = false,
    bool isAdr = false,
    double dieselSurchargePercent = 0.0,
    double? remoteTunnelFee,
    double? remoteGensetFee,
    double? remoteAdrFee,
  }) {
    final destinationSide = getSide(havenNumber);
    final kmFee = getPerKmFee(distanceKm, ratePerKm, minimumFee: minimumFee);
    final needsTunnel = driverCurrentSide != destinationSide;
    final actualTunnelFee =
        needsTunnel ? (remoteTunnelFee ?? AppConstants.tunnelFee) : 0.0;
    final actualGensetFee =
        hasGenset ? (remoteGensetFee ?? AppConstants.gensetFee) : 0.0;
    final actualAdrFee = isAdr ? (remoteAdrFee ?? AppConstants.adrFee) : 0.0;

    final subtotal = kmFee + actualTunnelFee + actualGensetFee + actualAdrFee;
    final dieselFee = calculateDieselSurcharge(subtotal, dieselSurchargePercent);
    final total = subtotal + dieselFee;

    int estimatedMinutes = (distanceKm / 60 * 60).round().clamp(15, 180);
    if (needsTunnel) estimatedMinutes += AppConstants.averageTunnelWaitTime;

    return DeliveryTariff(
      havenFee: 0.0,
      tunnelFee: actualTunnelFee,
      gensetFee: actualGensetFee,
      adrFee: actualAdrFee,
      dieselSurchargeFee: dieselFee,
      total: total,
      destinationSide: destinationSide,
      needsTunnel: needsTunnel,
      hasGenset: hasGenset,
      isAdr: isAdr,
      havenNumber: havenNumber,
      estimatedMinutes: estimatedMinutes,
      mode: TariffMode.perKm,
      distanceKm: distanceKm,
      zoneFee: kmFee,
    );
  }

  /// Belirli bir haven numarasının tarife bilgisini döndürür (özet)
  static String getHavenSummary(int havenNumber) {
    if (!isValidHaven(havenNumber)) return 'Geçersiz haven';
    final side = getSide(havenNumber);
    final fee = getHavenFee(havenNumber);
    final feeText = fee > 0 ? '${fee.toStringAsFixed(2)} €' : 'Tarife yok';
    return 'Haven $havenNumber — ${side.dutchName} — $feeText';
  }
}
