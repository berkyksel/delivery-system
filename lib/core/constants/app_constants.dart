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

  // Genset Fee (motorlu şase)
  static const double gensetFee = 0.00; // TBD — Remote Config ile güncellenecek

  // ADR Fee (tehlikeli madde / patlayıcı)
  static const double adrFee = 0.00; // TBD — Remote Config ile güncellenecek

  // Diesel Surcharge
  static const double defaultDieselSurchargePercent = 0.0; // %0 varsayılan
  static const double dieselPricePerLiter = 1.65;           // €/L Belçika ortalama

  // Km-based Tariff defaults
  static const double defaultKmZone0to25 = 50.0;   // € (0-25 km)
  static const double defaultKmZone25to50 = 80.0;  // € (25-50 km)
  static const double defaultKmZone50to100 = 120.0; // € (50-100 km)
  static const double defaultKmZone100plus = 180.0; // € (100+ km)
  static const double defaultPerKmRate = 1.20;       // €/km
  static const double defaultMinimumFee = 30.0;      // € minimum

  // Invoice
  static const int invoiceDueDays = 10; // Fatura vade süresi (gün)

  // Estimated durations (minutes)
  static const int averageTunnelWaitTime = 5;
  static const int averageDeliveryTimeMin = 20;
  static const int averageDeliveryTimeMax = 60;

  // Firestore Collections
  static const String deliveriesCollection = 'deliveries';
  static const String companiesCollection = 'companies';
  static const String havensCollection = 'havens';
  static const String usersCollection = 'users';
  static const String tariffsCollection = 'tariffs';
  static const String invoicesCollection = 'invoices';

  // Hive Box Names
  static const String settingsBox = 'settings';
  static const String deliveriesBox = 'deliveries_local';
  static const String profileBox = 'profile';
  static const String tariffBox = 'user_tariff';

  // Remote Config Keys
  static const String rcTunnelFee = 'tunnel_fee';
  static const String rcHavenTariffs = 'haven_tariffs';
  static const String rcGensetFee = 'genset_fee';
  static const String rcAdrFee = 'adr_fee';
  static const String rcDieselSurcharge = 'diesel_surcharge_percent';

  // Currency
  static const String currencySymbol = '€';
  static const String currencyCode = 'EUR';

  // Pagination
  static const int pageSize = 20;
}
