import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/services/tariff_service.dart';
import '../../data/models/tariff_zone_model.dart';

// ─── Teklif / Fatura Dili ─────────────────────────────────────────────────────
enum QuoteLanguage {
  turkish('Türkçe', 'tr', '🇹🇷'),
  dutch('Nederlands', 'nl', '🇳🇱'),
  french('Français', 'fr', '🇫🇷'),
  english('English', 'en', '🇬🇧'),
  german('Deutsch', 'de', '🇩🇪');

  final String label;
  final String code;
  final String flag;
  const QuoteLanguage(this.label, this.code, this.flag);
}

// ─── Teklif Durumu ────────────────────────────────────────────────────────────
enum QuoteStatus {
  draft('Taslak'),
  sent('Gönderildi'),
  accepted('Kabul Edildi'),
  rejected('Reddedildi'),
  invoiced('Faturalandı');

  final String label;
  const QuoteStatus(this.label);
}

class DeliveryModel {
  final String? id;
  final String companyName;
  final String? contactPerson;

  // ─── Haven / Liman ────────────────────────────────────────────────────────
  final int havenNumber;
  final PortSide destinationSide;
  final PortSide driverSideAtDelivery;
  final bool tunnelUsed;

  // ─── Ücretler ─────────────────────────────────────────────────────────────
  final double havenFee;
  final double tunnelFee;
  final bool hasGenset;
  final double gensetFee;
  final bool isAdr;
  final double adrFee;

  // ─── Dizel Toeslag ────────────────────────────────────────────────────────
  final double dieselSurchargePercent; // örn. 8.0 = %8
  final double dieselSurchargeFee;     // hesaplanan tutar

  // ─── Tarife Modu ──────────────────────────────────────────────────────────
  final TariffMode tariffMode;
  final double? distanceKm;           // km bazlı modlar için

  // ─── Güzergah ─────────────────────────────────────────────────────────────
  final String? pickupHaven;          // Konşimentoya alınacak liman adı/no
  final String? deliveryAddress;      // Boşaltılacak / yüklenecek adres
  final String? returnHaven;          // Geri verilecek liman adı/no

  // ─── TIR Bilgisi ──────────────────────────────────────────────────────────
  final String? truckModelId;         // TruckCatalog ID
  final String? truckModelName;       // Görüntü adı (örn. "DAF XF 480")
  final double? estimatedFuelLiters;  // Tahmini yakıt tüketimi

  // ─── Genel ────────────────────────────────────────────────────────────────
  final double totalFee;
  final int? estimatedMinutes;
  final String? notes;
  final DateTime createdAt;
  final String driverId;
  final DeliveryStatus status;

  // ─── Teklif / Fatura ──────────────────────────────────────────────────────
  final QuoteLanguage quoteLanguage;
  final QuoteStatus quoteStatus;
  final DateTime? invoiceDate;
  final DateTime? invoiceDueDate;     // vade tarihi (+10 gün)
  final String? invoiceNumber;

  // ─── Hızlı Teklif ────────────────────────────────────────────────────────
  final bool isQuickQuote;            // Şirket bilgisi olmadan oluşturuldu
  final String? quoteOwnerName;       // Hızlı teklif sahibi adı

  const DeliveryModel({
    this.id,
    required this.companyName,
    this.contactPerson,
    required this.havenNumber,
    required this.destinationSide,
    required this.driverSideAtDelivery,
    required this.tunnelUsed,
    required this.havenFee,
    required this.tunnelFee,
    this.hasGenset = false,
    this.gensetFee = 0.0,
    this.isAdr = false,
    this.adrFee = 0.0,
    this.dieselSurchargePercent = 0.0,
    this.dieselSurchargeFee = 0.0,
    this.tariffMode = TariffMode.havenBased,
    this.distanceKm,
    this.pickupHaven,
    this.deliveryAddress,
    this.returnHaven,
    this.truckModelId,
    this.truckModelName,
    this.estimatedFuelLiters,
    required this.totalFee,
    this.estimatedMinutes,
    this.notes,
    required this.createdAt,
    required this.driverId,
    this.status = DeliveryStatus.pending,
    this.quoteLanguage = QuoteLanguage.dutch,
    this.quoteStatus = QuoteStatus.draft,
    this.invoiceDate,
    this.invoiceDueDate,
    this.invoiceNumber,
    this.isQuickQuote = false,
    this.quoteOwnerName,
  });

  factory DeliveryModel.fromTariff({
    required String companyName,
    required int havenNumber,
    required PortSide driverSide,
    required DeliveryTariff tariff,
    required String driverId,
    String? contactPerson,
    String? notes,
    double dieselSurchargePercent = 0.0,
    double dieselSurchargeFee = 0.0,
    TariffMode tariffMode = TariffMode.havenBased,
    double? distanceKm,
    String? pickupHaven,
    String? deliveryAddress,
    String? returnHaven,
    String? truckModelId,
    String? truckModelName,
    double? estimatedFuelLiters,
    QuoteLanguage quoteLanguage = QuoteLanguage.dutch,
    bool isQuickQuote = false,
    String? quoteOwnerName,
  }) {
    final totalWithDiesel = tariff.total + dieselSurchargeFee;
    return DeliveryModel(
      companyName: companyName,
      contactPerson: contactPerson,
      havenNumber: havenNumber,
      destinationSide: tariff.destinationSide,
      driverSideAtDelivery: driverSide,
      tunnelUsed: tariff.needsTunnel,
      havenFee: tariff.havenFee,
      tunnelFee: tariff.tunnelFee,
      hasGenset: tariff.hasGenset,
      gensetFee: tariff.gensetFee,
      isAdr: tariff.isAdr,
      adrFee: tariff.adrFee,
      dieselSurchargePercent: dieselSurchargePercent,
      dieselSurchargeFee: dieselSurchargeFee,
      tariffMode: tariffMode,
      distanceKm: distanceKm,
      pickupHaven: pickupHaven,
      deliveryAddress: deliveryAddress,
      returnHaven: returnHaven,
      truckModelId: truckModelId,
      truckModelName: truckModelName,
      estimatedFuelLiters: estimatedFuelLiters,
      totalFee: totalWithDiesel,
      estimatedMinutes: tariff.estimatedMinutes,
      notes: notes,
      createdAt: DateTime.now(),
      driverId: driverId,
      quoteLanguage: quoteLanguage,
      isQuickQuote: isQuickQuote,
      quoteOwnerName: quoteOwnerName,
    );
  }

  /// Teslimat müşteri adını döndürür (hızlı teklif veya şirket adı)
  String get displayClientName {
    if (isQuickQuote && quoteOwnerName != null && quoteOwnerName!.isNotEmpty) {
      return quoteOwnerName!;
    }
    return companyName;
  }

  /// Güzergah özet metni
  String get routeSummary {
    final parts = <String>[];
    if (pickupHaven != null && pickupHaven!.isNotEmpty) {
      parts.add(pickupHaven!);
    }
    if (deliveryAddress != null && deliveryAddress!.isNotEmpty) {
      parts.add(deliveryAddress!);
    }
    if (returnHaven != null && returnHaven!.isNotEmpty) {
      parts.add(returnHaven!);
    }
    return parts.join(' → ');
  }

  bool get hasRoute =>
      (pickupHaven != null && pickupHaven!.isNotEmpty) ||
      (deliveryAddress != null && deliveryAddress!.isNotEmpty) ||
      (returnHaven != null && returnHaven!.isNotEmpty);

  bool get hasDieselSurcharge => dieselSurchargePercent > 0;

  bool get hasInvoice => invoiceNumber != null;

  Map<String, dynamic> toFirestore() {
    return {
      'companyName': companyName,
      'contactPerson': contactPerson,
      'havenNumber': havenNumber,
      'destinationSide': destinationSide.name,
      'driverSideAtDelivery': driverSideAtDelivery.name,
      'tunnelUsed': tunnelUsed,
      'havenFee': havenFee,
      'tunnelFee': tunnelFee,
      'hasGenset': hasGenset,
      'gensetFee': gensetFee,
      'isAdr': isAdr,
      'adrFee': adrFee,
      'dieselSurchargePercent': dieselSurchargePercent,
      'dieselSurchargeFee': dieselSurchargeFee,
      'tariffMode': tariffMode.name,
      'distanceKm': distanceKm,
      'pickupHaven': pickupHaven,
      'deliveryAddress': deliveryAddress,
      'returnHaven': returnHaven,
      'truckModelId': truckModelId,
      'truckModelName': truckModelName,
      'estimatedFuelLiters': estimatedFuelLiters,
      'totalFee': totalFee,
      'estimatedMinutes': estimatedMinutes,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'driverId': driverId,
      'status': status.name,
      'quoteLanguage': quoteLanguage.name,
      'quoteStatus': quoteStatus.name,
      'invoiceDate':
          invoiceDate != null ? Timestamp.fromDate(invoiceDate!) : null,
      'invoiceDueDate':
          invoiceDueDate != null ? Timestamp.fromDate(invoiceDueDate!) : null,
      'invoiceNumber': invoiceNumber,
      'isQuickQuote': isQuickQuote,
      'quoteOwnerName': quoteOwnerName,
    };
  }

  factory DeliveryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DeliveryModel(
      id: doc.id,
      companyName: data['companyName'] ?? '',
      contactPerson: data['contactPerson'],
      havenNumber: data['havenNumber'] ?? 0,
      destinationSide: PortSide.values.firstWhere(
        (e) => e.name == data['destinationSide'],
        orElse: () => PortSide.rechteroever,
      ),
      driverSideAtDelivery: PortSide.values.firstWhere(
        (e) => e.name == data['driverSideAtDelivery'],
        orElse: () => PortSide.rechteroever,
      ),
      tunnelUsed: data['tunnelUsed'] ?? false,
      havenFee: (data['havenFee'] ?? 0).toDouble(),
      tunnelFee: (data['tunnelFee'] ?? 0).toDouble(),
      hasGenset: data['hasGenset'] ?? false,
      gensetFee: (data['gensetFee'] ?? 0).toDouble(),
      isAdr: data['isAdr'] ?? false,
      adrFee: (data['adrFee'] ?? 0).toDouble(),
      dieselSurchargePercent:
          (data['dieselSurchargePercent'] ?? 0).toDouble(),
      dieselSurchargeFee: (data['dieselSurchargeFee'] ?? 0).toDouble(),
      tariffMode: TariffMode.values.firstWhere(
        (e) => e.name == data['tariffMode'],
        orElse: () => TariffMode.havenBased,
      ),
      distanceKm: data['distanceKm'] != null
          ? (data['distanceKm'] as num).toDouble()
          : null,
      pickupHaven: data['pickupHaven'],
      deliveryAddress: data['deliveryAddress'],
      returnHaven: data['returnHaven'],
      truckModelId: data['truckModelId'],
      truckModelName: data['truckModelName'],
      estimatedFuelLiters: data['estimatedFuelLiters'] != null
          ? (data['estimatedFuelLiters'] as num).toDouble()
          : null,
      totalFee: (data['totalFee'] ?? 0).toDouble(),
      estimatedMinutes: data['estimatedMinutes'],
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      driverId: data['driverId'] ?? '',
      status: DeliveryStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => DeliveryStatus.pending,
      ),
      quoteLanguage: QuoteLanguage.values.firstWhere(
        (e) => e.name == data['quoteLanguage'],
        orElse: () => QuoteLanguage.dutch,
      ),
      quoteStatus: QuoteStatus.values.firstWhere(
        (e) => e.name == data['quoteStatus'],
        orElse: () => QuoteStatus.draft,
      ),
      invoiceDate: data['invoiceDate'] != null
          ? (data['invoiceDate'] as Timestamp).toDate()
          : null,
      invoiceDueDate: data['invoiceDueDate'] != null
          ? (data['invoiceDueDate'] as Timestamp).toDate()
          : null,
      invoiceNumber: data['invoiceNumber'],
      isQuickQuote: data['isQuickQuote'] ?? false,
      quoteOwnerName: data['quoteOwnerName'],
    );
  }

  DeliveryModel copyWith({
    String? id,
    String? companyName,
    String? contactPerson,
    int? havenNumber,
    PortSide? destinationSide,
    PortSide? driverSideAtDelivery,
    bool? tunnelUsed,
    double? havenFee,
    double? tunnelFee,
    bool? hasGenset,
    double? gensetFee,
    bool? isAdr,
    double? adrFee,
    double? dieselSurchargePercent,
    double? dieselSurchargeFee,
    TariffMode? tariffMode,
    double? distanceKm,
    String? pickupHaven,
    String? deliveryAddress,
    String? returnHaven,
    String? truckModelId,
    String? truckModelName,
    double? estimatedFuelLiters,
    double? totalFee,
    int? estimatedMinutes,
    String? notes,
    DateTime? createdAt,
    String? driverId,
    DeliveryStatus? status,
    QuoteLanguage? quoteLanguage,
    QuoteStatus? quoteStatus,
    DateTime? invoiceDate,
    DateTime? invoiceDueDate,
    String? invoiceNumber,
    bool? isQuickQuote,
    String? quoteOwnerName,
  }) {
    return DeliveryModel(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      contactPerson: contactPerson ?? this.contactPerson,
      havenNumber: havenNumber ?? this.havenNumber,
      destinationSide: destinationSide ?? this.destinationSide,
      driverSideAtDelivery: driverSideAtDelivery ?? this.driverSideAtDelivery,
      tunnelUsed: tunnelUsed ?? this.tunnelUsed,
      havenFee: havenFee ?? this.havenFee,
      tunnelFee: tunnelFee ?? this.tunnelFee,
      hasGenset: hasGenset ?? this.hasGenset,
      gensetFee: gensetFee ?? this.gensetFee,
      isAdr: isAdr ?? this.isAdr,
      adrFee: adrFee ?? this.adrFee,
      dieselSurchargePercent:
          dieselSurchargePercent ?? this.dieselSurchargePercent,
      dieselSurchargeFee: dieselSurchargeFee ?? this.dieselSurchargeFee,
      tariffMode: tariffMode ?? this.tariffMode,
      distanceKm: distanceKm ?? this.distanceKm,
      pickupHaven: pickupHaven ?? this.pickupHaven,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      returnHaven: returnHaven ?? this.returnHaven,
      truckModelId: truckModelId ?? this.truckModelId,
      truckModelName: truckModelName ?? this.truckModelName,
      estimatedFuelLiters: estimatedFuelLiters ?? this.estimatedFuelLiters,
      totalFee: totalFee ?? this.totalFee,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      driverId: driverId ?? this.driverId,
      status: status ?? this.status,
      quoteLanguage: quoteLanguage ?? this.quoteLanguage,
      quoteStatus: quoteStatus ?? this.quoteStatus,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      invoiceDueDate: invoiceDueDate ?? this.invoiceDueDate,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      isQuickQuote: isQuickQuote ?? this.isQuickQuote,
      quoteOwnerName: quoteOwnerName ?? this.quoteOwnerName,
    );
  }
}

enum DeliveryStatus {
  pending('Bekliyor'),
  inProgress('Yolda'),
  completed('Tamamlandı'),
  cancelled('İptal');

  final String label;
  const DeliveryStatus(this.label);
}
