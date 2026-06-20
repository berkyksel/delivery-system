import '../../core/constants/app_constants.dart';

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
  final double total;
  final PortSide destinationSide;
  final bool needsTunnel;
  final bool hasGenset;
  final bool isAdr;
  final int havenNumber;
  final int? estimatedMinutes;

  const DeliveryTariff({
    required this.havenFee,
    required this.tunnelFee,
    required this.gensetFee,
    required this.adrFee,
    required this.total,
    required this.destinationSide,
    required this.needsTunnel,
    required this.hasGenset,
    required this.isAdr,
    required this.havenNumber,
    this.estimatedMinutes,
  });

  String get formattedTotal => '${total.toStringAsFixed(2)} €';
  String get formattedHavenFee => '${havenFee.toStringAsFixed(2)} €';
  String get formattedTunnelFee => '${tunnelFee.toStringAsFixed(2)} €';
  String get formattedGensetFee => '${gensetFee.toStringAsFixed(2)} €';
  String get formattedAdrFee => '${adrFee.toStringAsFixed(2)} €';
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
    throw ArgumentError('Geçersiz haven numarası: $havenNumber (1-2000 arası olmalı)');
  }

  /// Haven numarasının geçerliliğini kontrol eder
  static bool isValidHaven(int havenNumber) {
    return havenNumber >= AppConstants.rechteroeverMin &&
        havenNumber <= AppConstants.linkeroeverMax;
  }

  /// Haven numarasına özel tarife döndürür
  static double getHavenFee(int havenNumber, {Map<String, double>? remoteConfig}) {
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
            if (min != null && max != null &&
                havenNumber >= min && havenNumber <= max) {
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

  /// Toplam teslimat ücretini hesaplar
  static DeliveryTariff calculate({
    required int havenNumber,
    required PortSide driverCurrentSide,
    bool hasGenset = false,
    bool isAdr = false,
    Map<String, double>? remoteHavenTariffs,
    double? remoteTunnelFee,
    double? remoteGensetFee,
    double? remoteAdrFee,
    int? customEstimatedMinutes,
  }) {
    final destinationSide = getSide(havenNumber);
    final havenFee = getHavenFee(havenNumber, remoteConfig: remoteHavenTariffs);
    final needsTunnel = driverCurrentSide != destinationSide;
    final actualTunnelFee = needsTunnel
        ? (remoteTunnelFee ?? AppConstants.tunnelFee)
        : 0.0;
    final actualGensetFee = hasGenset
        ? (remoteGensetFee ?? AppConstants.gensetFee)
        : 0.0;
    final actualAdrFee = isAdr
        ? (remoteAdrFee ?? AppConstants.adrFee)
        : 0.0;
    final total = havenFee + actualTunnelFee + actualGensetFee + actualAdrFee;

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
      total: total,
      destinationSide: destinationSide,
      needsTunnel: needsTunnel,
      hasGenset: hasGenset,
      isAdr: isAdr,
      havenNumber: havenNumber,
      estimatedMinutes: estimatedMinutes,
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
