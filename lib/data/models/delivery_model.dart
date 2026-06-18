import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/services/tariff_service.dart';

class DeliveryModel {
  final String? id;
  final String companyName;
  final String? contactPerson;
  final int havenNumber;
  final PortSide destinationSide;
  final PortSide driverSideAtDelivery;
  final bool tunnelUsed;
  final double havenFee;
  final double tunnelFee;
  final double totalFee;
  final int? estimatedMinutes;
  final String? notes;
  final DateTime createdAt;
  final String driverId;
  final DeliveryStatus status;

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
    required this.totalFee,
    this.estimatedMinutes,
    this.notes,
    required this.createdAt,
    required this.driverId,
    this.status = DeliveryStatus.pending,
  });

  factory DeliveryModel.fromTariff({
    required String companyName,
    required int havenNumber,
    required PortSide driverSide,
    required DeliveryTariff tariff,
    required String driverId,
    String? contactPerson,
    String? notes,
  }) {
    return DeliveryModel(
      companyName: companyName,
      contactPerson: contactPerson,
      havenNumber: havenNumber,
      destinationSide: tariff.destinationSide,
      driverSideAtDelivery: driverSide,
      tunnelUsed: tariff.needsTunnel,
      havenFee: tariff.havenFee,
      tunnelFee: tariff.tunnelFee,
      totalFee: tariff.total,
      estimatedMinutes: tariff.estimatedMinutes,
      notes: notes,
      createdAt: DateTime.now(),
      driverId: driverId,
    );
  }

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
      'totalFee': totalFee,
      'estimatedMinutes': estimatedMinutes,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'driverId': driverId,
      'status': status.name,
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
      totalFee: (data['totalFee'] ?? 0).toDouble(),
      estimatedMinutes: data['estimatedMinutes'],
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      driverId: data['driverId'] ?? '',
      status: DeliveryStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => DeliveryStatus.pending,
      ),
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
    double? totalFee,
    int? estimatedMinutes,
    String? notes,
    DateTime? createdAt,
    String? driverId,
    DeliveryStatus? status,
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
      totalFee: totalFee ?? this.totalFee,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      driverId: driverId ?? this.driverId,
      status: status ?? this.status,
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
