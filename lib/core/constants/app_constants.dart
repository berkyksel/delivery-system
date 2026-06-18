class AppConstants {
  // Port Zone Boundaries
  static const int rechteroeverMin = 1;
  static const int rechteroeverMax = 999;
  static const int linkeroeverMin = 1000;
  static const int linkeroeverMax = 2000;

  // Tunnel Fee
  static const double tunnelFee = 17.60;

  // Haven Fees
  static const double haven1700Fee = 14.00;
  static const int haven1700 = 1700;

  static const double haven869to913Fee = 20.00;
  static const int haven869 = 869;
  static const int haven913 = 913;

  // Default / Unknown Haven Fee
  static const double defaultHavenFee = 0.00;

  // Estimated durations (minutes)
  static const int averageTunnelWaitTime = 5;
  static const int averageDeliveryTimeMin = 20;
  static const int averageDeliveryTimeMax = 60;

  // Firestore Collections
  static const String deliveriesCollection = 'deliveries';
  static const String companiesCollection = 'companies';
  static const String havensCollection = 'havens';
  static const String usersCollection = 'users';

  // Hive Box Names
  static const String settingsBox = 'settings';
  static const String deliveriesBox = 'deliveries_local';
  static const String profileBox = 'profile';

  // Remote Config Keys
  static const String rcTunnelFee = 'tunnel_fee';
  static const String rcHavenTariffs = 'haven_tariffs';

  // Currency
  static const String currencySymbol = '€';
  static const String currencyCode = 'EUR';

  // Pagination
  static const int pageSize = 20;
}
