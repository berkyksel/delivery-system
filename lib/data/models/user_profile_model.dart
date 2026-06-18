import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? photoUrl;
  final String? vehiclePlate;
  final String? vehicleType;
  final UserRole role;
  final String preferredLanguage;
  final bool notificationsEnabled;
  final String? currentSide; // 'rechteroever' or 'linkeroever'
  final DateTime? createdAt;

  const UserProfile({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.photoUrl,
    this.vehiclePlate,
    this.vehicleType,
    this.role = UserRole.driver,
    this.preferredLanguage = 'tr',
    this.notificationsEnabled = true,
    this.currentSide,
    this.createdAt,
  });

  String get fullName => '$firstName $lastName';

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'photoUrl': photoUrl,
      'vehiclePlate': vehiclePlate,
      'vehicleType': vehicleType,
      'role': role.name,
      'preferredLanguage': preferredLanguage,
      'notificationsEnabled': notificationsEnabled,
      'currentSide': currentSide,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: data['uid'] ?? doc.id,
      email: data['email'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      phone: data['phone'],
      photoUrl: data['photoUrl'],
      vehiclePlate: data['vehiclePlate'],
      vehicleType: data['vehicleType'],
      role: UserRole.values.firstWhere(
        (e) => e.name == data['role'],
        orElse: () => UserRole.driver,
      ),
      preferredLanguage: data['preferredLanguage'] ?? 'tr',
      notificationsEnabled: data['notificationsEnabled'] ?? true,
      currentSide: data['currentSide'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  UserProfile copyWith({
    String? firstName,
    String? lastName,
    String? phone,
    String? photoUrl,
    String? vehiclePlate,
    String? vehicleType,
    UserRole? role,
    String? preferredLanguage,
    bool? notificationsEnabled,
    String? currentSide,
  }) {
    return UserProfile(
      uid: uid,
      email: email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      vehicleType: vehicleType ?? this.vehicleType,
      role: role ?? this.role,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      currentSide: currentSide ?? this.currentSide,
      createdAt: createdAt,
    );
  }
}

enum UserRole {
  driver('Şoför'),
  manager('Yönetici');

  final String label;
  const UserRole(this.label);
}
