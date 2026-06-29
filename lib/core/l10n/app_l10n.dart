import '../../data/models/delivery_model.dart';

/// Uygulama arayüz çevirileri.
/// Seçilen [QuoteLanguage]'a göre doğru metni döndürür.
class AppL10n {
  final QuoteLanguage language;

  const AppL10n(this.language);

  // ── Navigasyon ──────────────────────────────────────────────────────────────
  String get navHome {
    return switch (language) {
      QuoteLanguage.dutch   => 'Thuis',
      QuoteLanguage.french  => 'Accueil',
      QuoteLanguage.english => 'Home',
      QuoteLanguage.german  => 'Start',
      QuoteLanguage.turkish => 'Ana Sayfa',
    };
  }

  String get navHistory {
    return switch (language) {
      QuoteLanguage.dutch   => 'Geschiedenis',
      QuoteLanguage.french  => 'Historique',
      QuoteLanguage.english => 'History',
      QuoteLanguage.german  => 'Verlauf',
      QuoteLanguage.turkish => 'Geçmiş',
    };
  }

  String get navTariff {
    return switch (language) {
      QuoteLanguage.dutch   => 'Tarief',
      QuoteLanguage.french  => 'Tarif',
      QuoteLanguage.english => 'Tariff',
      QuoteLanguage.german  => 'Tarif',
      QuoteLanguage.turkish => 'Tarife',
    };
  }

  String get navProfile {
    return switch (language) {
      QuoteLanguage.dutch   => 'Profiel',
      QuoteLanguage.french  => 'Profil',
      QuoteLanguage.english => 'Profile',
      QuoteLanguage.german  => 'Profil',
      QuoteLanguage.turkish => 'Profil',
    };
  }

  String get navNewDelivery {
    return switch (language) {
      QuoteLanguage.dutch   => 'Nieuwe Levering',
      QuoteLanguage.french  => 'Nouvelle Livraison',
      QuoteLanguage.english => 'New Delivery',
      QuoteLanguage.german  => 'Neue Lieferung',
      QuoteLanguage.turkish => 'Yeni Teslimat',
    };
  }

  // ── Ana Sayfa ───────────────────────────────────────────────────────────────
  String get homeGreeting {
    return switch (language) {
      QuoteLanguage.dutch   => 'Goedemorgen! 👋',
      QuoteLanguage.french  => 'Bonjour! 👋',
      QuoteLanguage.english => 'Good morning! 👋',
      QuoteLanguage.german  => 'Guten Morgen! 👋',
      QuoteLanguage.turkish => 'Günaydın! 👋',
    };
  }

  String get homeWelcome {
    return switch (language) {
      QuoteLanguage.dutch   => 'Welkom',
      QuoteLanguage.french  => 'Bienvenue',
      QuoteLanguage.english => 'Welcome',
      QuoteLanguage.german  => 'Willkommen',
      QuoteLanguage.turkish => 'Hoş geldiniz',
    };
  }

  String get homeToday {
    return switch (language) {
      QuoteLanguage.dutch   => 'Vandaag',
      QuoteLanguage.french  => "Aujourd'hui",
      QuoteLanguage.english => 'Today',
      QuoteLanguage.german  => 'Heute',
      QuoteLanguage.turkish => 'Bugün',
    };
  }

  String get homeDelivery {
    return switch (language) {
      QuoteLanguage.dutch   => 'levering',
      QuoteLanguage.french  => 'livraison',
      QuoteLanguage.english => 'delivery',
      QuoteLanguage.german  => 'Lieferung',
      QuoteLanguage.turkish => 'teslimat',
    };
  }

  String get homeEarnings {
    return switch (language) {
      QuoteLanguage.dutch   => 'Verdienste',
      QuoteLanguage.french  => 'Gains',
      QuoteLanguage.english => 'Earnings',
      QuoteLanguage.german  => 'Verdienst',
      QuoteLanguage.turkish => 'Kazanç',
    };
  }

  String get homeTunnel {
    return switch (language) {
      QuoteLanguage.dutch   => 'Tunnel',
      QuoteLanguage.french  => 'Tunnel',
      QuoteLanguage.english => 'Tunnel',
      QuoteLanguage.german  => 'Tunnel',
      QuoteLanguage.turkish => 'Tünel',
    };
  }

  String get homeTunnelPassage {
    return switch (language) {
      QuoteLanguage.dutch   => 'doorgang',
      QuoteLanguage.french  => 'passage',
      QuoteLanguage.english => 'passage',
      QuoteLanguage.german  => 'Durchgang',
      QuoteLanguage.turkish => 'geçiş',
    };
  }

  String get homeCurrentLocation {
    return switch (language) {
      QuoteLanguage.dutch   => 'Huidige locatie',
      QuoteLanguage.french  => 'Position actuelle',
      QuoteLanguage.english => 'Current Location',
      QuoteLanguage.german  => 'Aktueller Standort',
      QuoteLanguage.turkish => 'Mevcut Konum',
    };
  }

  String get homeChange {
    return switch (language) {
      QuoteLanguage.dutch   => 'Wijzigen',
      QuoteLanguage.french  => 'Changer',
      QuoteLanguage.english => 'Change',
      QuoteLanguage.german  => 'Ändern',
      QuoteLanguage.turkish => 'Değiştir',
    };
  }

  String get homeRecentDeliveries {
    return switch (language) {
      QuoteLanguage.dutch   => 'Recente Leveringen',
      QuoteLanguage.french  => 'Livraisons Récentes',
      QuoteLanguage.english => 'Recent Deliveries',
      QuoteLanguage.german  => 'Letzte Lieferungen',
      QuoteLanguage.turkish => 'Son Teslimatlar',
    };
  }

  String get homeSeeAll {
    return switch (language) {
      QuoteLanguage.dutch   => 'Alles zien',
      QuoteLanguage.french  => 'Voir tout',
      QuoteLanguage.english => 'See All',
      QuoteLanguage.german  => 'Alle anzeigen',
      QuoteLanguage.turkish => 'Tümünü Gör',
    };
  }

  // ── Geçmiş Ekranı ──────────────────────────────────────────────────────────
  String get historyTitle {
    return switch (language) {
      QuoteLanguage.dutch   => 'Leveringsgeschiedenis',
      QuoteLanguage.french  => 'Historique des Livraisons',
      QuoteLanguage.english => 'Delivery History',
      QuoteLanguage.german  => 'Lieferverlauf',
      QuoteLanguage.turkish => 'Teslimat Geçmişi',
    };
  }

  String get historyTotalDeliveries {
    return switch (language) {
      QuoteLanguage.dutch   => 'Totale leveringen',
      QuoteLanguage.french  => 'Total livraisons',
      QuoteLanguage.english => 'Total Deliveries',
      QuoteLanguage.german  => 'Gesamtlieferungen',
      QuoteLanguage.turkish => 'Toplam Teslimat',
    };
  }

  String get historyTotalEarnings {
    return switch (language) {
      QuoteLanguage.dutch   => 'Totale verdienste',
      QuoteLanguage.french  => 'Total gains',
      QuoteLanguage.english => 'Total Earnings',
      QuoteLanguage.german  => 'Gesamtverdienst',
      QuoteLanguage.turkish => 'Toplam Kazanç',
    };
  }

  String get historyTunnelPassage {
    return switch (language) {
      QuoteLanguage.dutch   => 'Tunneldoorgangen',
      QuoteLanguage.french  => 'Passages tunnel',
      QuoteLanguage.english => 'Tunnel Passages',
      QuoteLanguage.german  => 'Tunneldurchgänge',
      QuoteLanguage.turkish => 'Tünel Geçişi',
    };
  }

  String get filterAll {
    return switch (language) {
      QuoteLanguage.dutch   => 'Alle',
      QuoteLanguage.french  => 'Tous',
      QuoteLanguage.english => 'All',
      QuoteLanguage.german  => 'Alle',
      QuoteLanguage.turkish => 'Tümü',
    };
  }

  String get filterToday {
    return switch (language) {
      QuoteLanguage.dutch   => 'Vandaag',
      QuoteLanguage.french  => "Aujourd'hui",
      QuoteLanguage.english => 'Today',
      QuoteLanguage.german  => 'Heute',
      QuoteLanguage.turkish => 'Bugün',
    };
  }

  String get filterThisWeek {
    return switch (language) {
      QuoteLanguage.dutch   => 'Deze week',
      QuoteLanguage.french  => 'Cette semaine',
      QuoteLanguage.english => 'This Week',
      QuoteLanguage.german  => 'Diese Woche',
      QuoteLanguage.turkish => 'Bu Hafta',
    };
  }

  String get filterThisMonth {
    return switch (language) {
      QuoteLanguage.dutch   => 'Deze maand',
      QuoteLanguage.french  => 'Ce mois',
      QuoteLanguage.english => 'This Month',
      QuoteLanguage.german  => 'Diesen Monat',
      QuoteLanguage.turkish => 'Bu Ay',
    };
  }

  List<String> get historyFilters => [filterAll, filterToday, filterThisWeek, filterThisMonth];

  // ── Tarife Ekranı ───────────────────────────────────────────────────────────
  String get tariffTitle {
    return switch (language) {
      QuoteLanguage.dutch   => 'Tariefbeheer',
      QuoteLanguage.french  => 'Gestion des Tarifs',
      QuoteLanguage.english => 'Tariff Management',
      QuoteLanguage.german  => 'Tarifverwaltung',
      QuoteLanguage.turkish => 'Tarife Yönetimi',
    };
  }

  String get tariffSubtitle {
    return switch (language) {
      QuoteLanguage.dutch   => 'Bewerk en sla uw tarief op',
      QuoteLanguage.french  => 'Modifiez et sauvegardez votre tarif',
      QuoteLanguage.english => 'Edit and save your tariff',
      QuoteLanguage.german  => 'Bearbeiten und speichern Sie Ihren Tarif',
      QuoteLanguage.turkish => 'Kendi tarifenizi düzenleyin ve kaydedin',
    };
  }

  String get tariffTabHaven {
    return switch (language) {
      QuoteLanguage.dutch   => 'Haven',
      QuoteLanguage.french  => 'Port',
      QuoteLanguage.english => 'Haven',
      QuoteLanguage.german  => 'Hafen',
      QuoteLanguage.turkish => 'Haven',
    };
  }

  String get tariffTabKmZone {
    return switch (language) {
      QuoteLanguage.dutch   => 'Km Zone',
      QuoteLanguage.french  => 'Zone Km',
      QuoteLanguage.english => 'Km Zone',
      QuoteLanguage.german  => 'Km-Zone',
      QuoteLanguage.turkish => 'Km Aralık',
    };
  }

  String get tariffTabGeneral {
    return switch (language) {
      QuoteLanguage.dutch   => 'Algemeen',
      QuoteLanguage.french  => 'Général',
      QuoteLanguage.english => 'General',
      QuoteLanguage.german  => 'Allgemein',
      QuoteLanguage.turkish => 'Genel',
    };
  }

  String get tariffSaved {
    return switch (language) {
      QuoteLanguage.dutch   => '✓ Tarief opgeslagen',
      QuoteLanguage.french  => '✓ Tarif enregistré',
      QuoteLanguage.english => '✓ Tariff saved',
      QuoteLanguage.german  => '✓ Tarif gespeichert',
      QuoteLanguage.turkish => '✓ Tarife kaydedildi',
    };
  }

  String get tariffSave {
    return switch (language) {
      QuoteLanguage.dutch   => 'Opslaan',
      QuoteLanguage.french  => 'Enregistrer',
      QuoteLanguage.english => 'Save',
      QuoteLanguage.german  => 'Speichern',
      QuoteLanguage.turkish => 'Kaydet',
    };
  }

  String get tariffCancel {
    return switch (language) {
      QuoteLanguage.dutch   => 'Annuleren',
      QuoteLanguage.french  => 'Annuler',
      QuoteLanguage.english => 'Cancel',
      QuoteLanguage.german  => 'Abbrechen',
      QuoteLanguage.turkish => 'İptal',
    };
  }

  String get tariffSaveHaven {
    return switch (language) {
      QuoteLanguage.dutch   => 'Haventarief opslaan',
      QuoteLanguage.french  => 'Enregistrer tarif port',
      QuoteLanguage.english => 'Save Haven Tariff',
      QuoteLanguage.german  => 'Hafentarif speichern',
      QuoteLanguage.turkish => 'Haven Tarifesini Kaydet',
    };
  }

  String get tariffSaveKm {
    return switch (language) {
      QuoteLanguage.dutch   => 'Km-tarief opslaan',
      QuoteLanguage.french  => 'Enregistrer tarif km',
      QuoteLanguage.english => 'Save Km Tariff',
      QuoteLanguage.german  => 'Km-Tarif speichern',
      QuoteLanguage.turkish => 'Km Tarifesini Kaydet',
    };
  }

  String get tariffSaveGeneral {
    return switch (language) {
      QuoteLanguage.dutch   => 'Algemene tarieven opslaan',
      QuoteLanguage.french  => 'Enregistrer tarifs généraux',
      QuoteLanguage.english => 'Save General Fees',
      QuoteLanguage.german  => 'Allgemeine Gebühren speichern',
      QuoteLanguage.turkish => 'Genel Ücretleri Kaydet',
    };
  }

  String get tariffReset {
    return switch (language) {
      QuoteLanguage.dutch   => 'Tarief resetten',
      QuoteLanguage.french  => 'Réinitialiser le tarif',
      QuoteLanguage.english => 'Reset Tariff',
      QuoteLanguage.german  => 'Tarif zurücksetzen',
      QuoteLanguage.turkish => 'Tarifeyi Sıfırla',
    };
  }

  String get tariffResetAll {
    return switch (language) {
      QuoteLanguage.dutch   => 'Alle tarieven resetten naar standaard',
      QuoteLanguage.french  => 'Réinitialiser tous les tarifs aux valeurs par défaut',
      QuoteLanguage.english => 'Reset all tariffs to factory defaults',
      QuoteLanguage.german  => 'Alle Tarife auf Werkseinstellungen zurücksetzen',
      QuoteLanguage.turkish => 'Tüm tarifeleri fabrika değerlerine sıfırla',
    };
  }

  String get tariffResetConfirm {
    return switch (language) {
      QuoteLanguage.dutch   => 'Alle aangepaste tarieven worden verwijderd en de standaardwaarden worden hersteld.',
      QuoteLanguage.french  => 'Tous les tarifs personnalisés seront supprimés et les valeurs par défaut seront restaurées.',
      QuoteLanguage.english => 'All custom tariffs will be deleted and default values will be restored.',
      QuoteLanguage.german  => 'Alle benutzerdefinierten Tarife werden gelöscht und Standardwerte werden wiederhergestellt.',
      QuoteLanguage.turkish => 'Tüm özel tarifelar silinecek ve varsayılan değerlere dönülecek.',
    };
  }

  String get tariffDoReset {
    return switch (language) {
      QuoteLanguage.dutch   => 'Resetten',
      QuoteLanguage.french  => 'Réinitialiser',
      QuoteLanguage.english => 'Reset',
      QuoteLanguage.german  => 'Zurücksetzen',
      QuoteLanguage.turkish => 'Sıfırla',
    };
  }

  // ── Profil Ekranı ───────────────────────────────────────────────────────────
  String get profileCurrentLocation {
    return switch (language) {
      QuoteLanguage.dutch   => 'HUIDIGE LOCATIE',
      QuoteLanguage.french  => 'POSITION ACTUELLE',
      QuoteLanguage.english => 'CURRENT LOCATION',
      QuoteLanguage.german  => 'AKTUELLER STANDORT',
      QuoteLanguage.turkish => 'MEVCUT KONUMUM',
    };
  }

  String get profilePersonalInfo {
    return switch (language) {
      QuoteLanguage.dutch   => 'PERSOONLIJKE INFO',
      QuoteLanguage.french  => 'INFOS PERSONNELLES',
      QuoteLanguage.english => 'PERSONAL INFO',
      QuoteLanguage.german  => 'PERSÖNLICHE INFO',
      QuoteLanguage.turkish => 'KİŞİSEL BİLGİLER',
    };
  }

  String get profileFullName {
    return switch (language) {
      QuoteLanguage.dutch   => 'Volledige naam',
      QuoteLanguage.french  => 'Nom complet',
      QuoteLanguage.english => 'Full Name',
      QuoteLanguage.german  => 'Vollständiger Name',
      QuoteLanguage.turkish => 'Ad Soyad',
    };
  }

  String get profileEmail {
    return switch (language) {
      QuoteLanguage.dutch   => 'E-mail',
      QuoteLanguage.french  => 'E-mail',
      QuoteLanguage.english => 'Email',
      QuoteLanguage.german  => 'E-Mail',
      QuoteLanguage.turkish => 'E-posta',
    };
  }

  String get profilePhone {
    return switch (language) {
      QuoteLanguage.dutch   => 'Telefoon',
      QuoteLanguage.french  => 'Téléphone',
      QuoteLanguage.english => 'Phone',
      QuoteLanguage.german  => 'Telefon',
      QuoteLanguage.turkish => 'Telefon',
    };
  }

  String get profileVehicleInfo {
    return switch (language) {
      QuoteLanguage.dutch   => 'VOERTUIGINFO',
      QuoteLanguage.french  => 'INFO VÉHICULE',
      QuoteLanguage.english => 'VEHICLE INFO',
      QuoteLanguage.german  => 'FAHRZEUGINFO',
      QuoteLanguage.turkish => 'ARAÇ BİLGİLERİ',
    };
  }

  String get profilePlate {
    return switch (language) {
      QuoteLanguage.dutch   => 'Nummerplaat',
      QuoteLanguage.french  => 'Plaque',
      QuoteLanguage.english => 'Plate',
      QuoteLanguage.german  => 'Kennzeichen',
      QuoteLanguage.turkish => 'Plaka',
    };
  }

  String get profileVehicleType {
    return switch (language) {
      QuoteLanguage.dutch   => 'Voertuigtype',
      QuoteLanguage.french  => 'Type de véhicule',
      QuoteLanguage.english => 'Vehicle Type',
      QuoteLanguage.german  => 'Fahrzeugtyp',
      QuoteLanguage.turkish => 'Araç Tipi',
    };
  }

  String get profilePreferences {
    return switch (language) {
      QuoteLanguage.dutch   => 'VOORKEUREN',
      QuoteLanguage.french  => 'PRÉFÉRENCES',
      QuoteLanguage.english => 'PREFERENCES',
      QuoteLanguage.german  => 'EINSTELLUNGEN',
      QuoteLanguage.turkish => 'TERCİHLER',
    };
  }

  String get profileNotifications {
    return switch (language) {
      QuoteLanguage.dutch   => 'Meldingen',
      QuoteLanguage.french  => 'Notifications',
      QuoteLanguage.english => 'Notifications',
      QuoteLanguage.german  => 'Benachrichtigungen',
      QuoteLanguage.turkish => 'Bildirimler',
    };
  }

  String get profileNotificationsSubtitle {
    return switch (language) {
      QuoteLanguage.dutch   => 'Leveringsherinneringen',
      QuoteLanguage.french  => 'Rappels de livraison',
      QuoteLanguage.english => 'Delivery reminders',
      QuoteLanguage.german  => 'Liefererinnerungen',
      QuoteLanguage.turkish => 'Teslimat hatırlatmaları',
    };
  }

  String get profileAppTheme {
    return switch (language) {
      QuoteLanguage.dutch   => 'App-thema',
      QuoteLanguage.french  => "Thème de l'app",
      QuoteLanguage.english => 'App Theme',
      QuoteLanguage.german  => 'App-Design',
      QuoteLanguage.turkish => 'Uygulama Teması',
    };
  }

  String get profileDark {
    return switch (language) {
      QuoteLanguage.dutch   => 'Donker',
      QuoteLanguage.french  => 'Sombre',
      QuoteLanguage.english => 'Dark',
      QuoteLanguage.german  => 'Dunkel',
      QuoteLanguage.turkish => 'Koyu',
    };
  }

  String get profileLight {
    return switch (language) {
      QuoteLanguage.dutch   => 'Licht',
      QuoteLanguage.french  => 'Clair',
      QuoteLanguage.english => 'Light',
      QuoteLanguage.german  => 'Hell',
      QuoteLanguage.turkish => 'Açık',
    };
  }

  String get profileAppLanguage {
    return switch (language) {
      QuoteLanguage.dutch   => 'App-taal',
      QuoteLanguage.french  => "Langue de l'app",
      QuoteLanguage.english => 'App Language',
      QuoteLanguage.german  => 'App-Sprache',
      QuoteLanguage.turkish => 'Uygulama Dili',
    };
  }

  String get profileAppLanguageSubtitle {
    return switch (language) {
      QuoteLanguage.dutch   => 'Selecteer de taal voor de app en offertes',
      QuoteLanguage.french  => "Sélectionnez la langue de l'app et des devis",
      QuoteLanguage.english => 'Select language for app and quotes',
      QuoteLanguage.german  => 'Sprache für App und Angebote wählen',
      QuoteLanguage.turkish => 'Uygulama ve teklif için dil seçin',
    };
  }

  String get profileLogout {
    return switch (language) {
      QuoteLanguage.dutch   => 'Uitloggen',
      QuoteLanguage.french  => 'Se déconnecter',
      QuoteLanguage.english => 'Logout',
      QuoteLanguage.german  => 'Abmelden',
      QuoteLanguage.turkish => 'Çıkış Yap',
    };
  }

  String get profileLogoutConfirm {
    return switch (language) {
      QuoteLanguage.dutch   => 'Weet u zeker dat u wilt uitloggen?',
      QuoteLanguage.french  => 'Êtes-vous sûr de vouloir vous déconnecter?',
      QuoteLanguage.english => 'Are you sure you want to logout?',
      QuoteLanguage.german  => 'Sind Sie sicher, dass Sie sich abmelden möchten?',
      QuoteLanguage.turkish => 'Hesabınızdan çıkmak istediğinizden emin misiniz?',
    };
  }

  String get profileLogoutCancel {
    return switch (language) {
      QuoteLanguage.dutch   => 'Annuleren',
      QuoteLanguage.french  => 'Annuler',
      QuoteLanguage.english => 'Cancel',
      QuoteLanguage.german  => 'Abbrechen',
      QuoteLanguage.turkish => 'İptal',
    };
  }

  // ── Hızlı Teklif ────────────────────────────────────────────────────────────
  String get quickQuoteTitle {
    return switch (language) {
      QuoteLanguage.dutch   => 'Snelle Offerte',
      QuoteLanguage.french  => 'Devis Rapide',
      QuoteLanguage.english => 'Quick Quote',
      QuoteLanguage.german  => 'Schnelles Angebot',
      QuoteLanguage.turkish => 'Hızlı Teklif',
    };
  }

  String get quickQuoteBanner {
    return switch (language) {
      QuoteLanguage.dutch   => 'Snelle offerte: Maak direct een PDF aan met alleen tarief- en adresgegevens, zonder bedrijfsnaam.',
      QuoteLanguage.french  => 'Devis rapide: Créez instantanément un PDF avec seulement les données de tarif et d\'adresse, sans nom d\'entreprise.',
      QuoteLanguage.english => 'Quick Quote: Instantly create a PDF with only tariff and address data, without a company name.',
      QuoteLanguage.german  => 'Schnelles Angebot: Erstellen Sie sofort eine PDF mit nur Tarif- und Adressdaten, ohne Firmenname.',
      QuoteLanguage.turkish => 'Hızlı Teklif: Şirket adı girmeden, sadece tarife ve adres bilgisiyle anında PDF oluşturur.',
    };
  }

  String get quickQuoteOwner {
    return switch (language) {
      QuoteLanguage.dutch   => 'OFFERTE-EIGENAAR',
      QuoteLanguage.french  => 'PROPRIÉTAIRE DEVIS',
      QuoteLanguage.english => 'QUOTE OWNER',
      QuoteLanguage.german  => 'ANGEBOTSEIGENTÜMER',
      QuoteLanguage.turkish => 'TEKLİF SAHİBİ',
    };
  }

  String get quickQuoteOwnerLabel {
    return switch (language) {
      QuoteLanguage.dutch   => 'Naam / Referentie (Optioneel)',
      QuoteLanguage.french  => 'Nom / Référence (Optionnel)',
      QuoteLanguage.english => 'Name / Reference (Optional)',
      QuoteLanguage.german  => 'Name / Referenz (Optional)',
      QuoteLanguage.turkish => 'İsim / Referans (Opsiyonel)',
    };
  }

  String get quickQuoteOwnerHelper {
    return switch (language) {
      QuoteLanguage.dutch   => 'Verschijnt als klantnaam in PDF',
      QuoteLanguage.french  => 'Apparaît comme nom du client dans le PDF',
      QuoteLanguage.english => 'Appears as client name in PDF',
      QuoteLanguage.german  => 'Erscheint als Kundenname in PDF',
      QuoteLanguage.turkish => "PDF'de müşteri adı olarak görünür",
    };
  }

  String get quickQuoteLanguage {
    return switch (language) {
      QuoteLanguage.dutch   => 'TAAL OFFERTE',
      QuoteLanguage.french  => 'LANGUE DEVIS',
      QuoteLanguage.english => 'QUOTE LANGUAGE',
      QuoteLanguage.german  => 'ANGEBOTSSPRACHE',
      QuoteLanguage.turkish => 'TEKLİF DİLİ',
    };
  }

  String get quickQuoteTariffMode {
    return switch (language) {
      QuoteLanguage.dutch   => 'TARIEFMODUS',
      QuoteLanguage.french  => 'MODE TARIF',
      QuoteLanguage.english => 'TARIFF MODE',
      QuoteLanguage.german  => 'TARIFMODUS',
      QuoteLanguage.turkish => 'TARİFE MODU',
    };
  }

  String get quickQuoteHavenLocation {
    return switch (language) {
      QuoteLanguage.dutch   => 'DOEL HAVEN & LOCATIE',
      QuoteLanguage.french  => 'PORT CIBLE & LOCALISATION',
      QuoteLanguage.english => 'TARGET HAVEN & LOCATION',
      QuoteLanguage.german  => 'ZIELHAVEN & STANDORT',
      QuoteLanguage.turkish => 'HEDEF HAVEN & KONUM',
    };
  }

  String get quickQuoteRoute {
    return switch (language) {
      QuoteLanguage.dutch   => 'ROUTE (Optioneel)',
      QuoteLanguage.french  => 'ITINÉRAIRE (Optionnel)',
      QuoteLanguage.english => 'ROUTE (Optional)',
      QuoteLanguage.german  => 'ROUTE (Optional)',
      QuoteLanguage.turkish => 'GÜZERGAH (Opsiyonel)',
    };
  }

  String get quickQuoteTruckModel {
    return switch (language) {
      QuoteLanguage.dutch   => 'VRACHTWAGEN MODEL (Optioneel)',
      QuoteLanguage.french  => 'MODÈLE CAMION (Optionnel)',
      QuoteLanguage.english => 'TRUCK MODEL (Optional)',
      QuoteLanguage.german  => 'LKW-MODELL (Optional)',
      QuoteLanguage.turkish => 'TIR MODELİ (Opsiyonel)',
    };
  }

  String get quickQuoteDiesel {
    return switch (language) {
      QuoteLanguage.dutch   => 'DIESEL TOESLAG (Optioneel)',
      QuoteLanguage.french  => 'SUPPLÉMENT DIESEL (Optionnel)',
      QuoteLanguage.english => 'DIESEL SURCHARGE (Optional)',
      QuoteLanguage.german  => 'DIESELZUSCHLAG (Optional)',
      QuoteLanguage.turkish => 'DİZEL TOESLAG (Opsiyonel)',
    };
  }

  String get quickQuoteGenerate {
    return switch (language) {
      QuoteLanguage.dutch   => 'PDF Offerte Aanmaken',
      QuoteLanguage.french  => 'Créer PDF Devis',
      QuoteLanguage.english => 'Generate PDF Quote',
      QuoteLanguage.german  => 'PDF-Angebot Erstellen',
      QuoteLanguage.turkish => 'PDF Teklif Oluştur',
    };
  }

  String get quickQuotePleaseCalculate {
    return switch (language) {
      QuoteLanguage.dutch   => 'Bereken eerst het tarief',
      QuoteLanguage.french  => "Calculez d'abord le tarif",
      QuoteLanguage.english => 'Please calculate the tariff first',
      QuoteLanguage.german  => 'Bitte zuerst den Tarif berechnen',
      QuoteLanguage.turkish => 'Lütfen önce tarife hesaplayın',
    };
  }

  // ── Genel ──────────────────────────────────────────────────────────────────
  String get generalHavenNumber {
    return switch (language) {
      QuoteLanguage.dutch   => 'Havennummer (1-2000)',
      QuoteLanguage.french  => 'Numéro de port (1-2000)',
      QuoteLanguage.english => 'Haven Number (1-2000)',
      QuoteLanguage.german  => 'Hafennummer (1-2000)',
      QuoteLanguage.turkish => 'Haven Numarası (1-2000)',
    };
  }

  String get generalDistance {
    return switch (language) {
      QuoteLanguage.dutch   => 'Afstand (km)',
      QuoteLanguage.french  => 'Distance (km)',
      QuoteLanguage.english => 'Distance (km)',
      QuoteLanguage.german  => 'Entfernung (km)',
      QuoteLanguage.turkish => 'Mesafe (km)',
    };
  }

  String get generalPickupHaven {
    return switch (language) {
      QuoteLanguage.dutch   => 'Haven voor afgifte',
      QuoteLanguage.french  => 'Port de prise en charge',
      QuoteLanguage.english => 'Pickup Haven',
      QuoteLanguage.german  => 'Abholhafen',
      QuoteLanguage.turkish => 'Konşimentoya Alınacak Liman',
    };
  }

  String get generalDeliveryAddress {
    return switch (language) {
      QuoteLanguage.dutch   => 'Aflever / Laadadres',
      QuoteLanguage.french  => 'Adresse livraison / chargement',
      QuoteLanguage.english => 'Delivery / Loading Address',
      QuoteLanguage.german  => 'Liefer- / Ladeadresse',
      QuoteLanguage.turkish => 'Boşaltma / Yükleme Adresi',
    };
  }

  String get generalReturnHaven {
    return switch (language) {
      QuoteLanguage.dutch   => 'Haven voor teruggave',
      QuoteLanguage.french  => 'Port de retour',
      QuoteLanguage.english => 'Return Haven',
      QuoteLanguage.german  => 'Rückgabehafen',
      QuoteLanguage.turkish => 'Geri Verilecek Liman',
    };
  }

  String get generalSelectTruck {
    return switch (language) {
      QuoteLanguage.dutch   => 'Selecteer vrachtwagen',
      QuoteLanguage.french  => 'Sélectionner camion',
      QuoteLanguage.english => 'Select Truck Model',
      QuoteLanguage.german  => 'LKW-Modell wählen',
      QuoteLanguage.turkish => 'TIR Modeli Seçin',
    };
  }

  String get generalNone {
    return switch (language) {
      QuoteLanguage.dutch   => '— Niet geselecteerd —',
      QuoteLanguage.french  => '— Non sélectionné —',
      QuoteLanguage.english => '— Not selected —',
      QuoteLanguage.german  => '— Nicht ausgewählt —',
      QuoteLanguage.turkish => '— Seçilmedi —',
    };
  }

  String get generalHavenRequired {
    return switch (language) {
      QuoteLanguage.dutch   => 'Havennummer is verplicht',
      QuoteLanguage.french  => 'Le numéro de port est obligatoire',
      QuoteLanguage.english => 'Haven number is required',
      QuoteLanguage.german  => 'Hafennummer ist erforderlich',
      QuoteLanguage.turkish => 'Haven numarası zorunludur',
    };
  }

  String get generalInvalidHaven {
    return switch (language) {
      QuoteLanguage.dutch   => 'Ongeldig haven',
      QuoteLanguage.french  => 'Port invalide',
      QuoteLanguage.english => 'Invalid haven',
      QuoteLanguage.german  => 'Ungültiger Hafen',
      QuoteLanguage.turkish => 'Geçersiz haven',
    };
  }

  String get generalDistanceRequired {
    return switch (language) {
      QuoteLanguage.dutch   => 'Afstand is verplicht',
      QuoteLanguage.french  => 'La distance est obligatoire',
      QuoteLanguage.english => 'Distance is required',
      QuoteLanguage.german  => 'Entfernung ist erforderlich',
      QuoteLanguage.turkish => 'Mesafe zorunludur',
    };
  }

  String get generalInvalidKm {
    return switch (language) {
      QuoteLanguage.dutch   => 'Voer geldige km in',
      QuoteLanguage.french  => 'Entrez des km valides',
      QuoteLanguage.english => 'Enter valid km',
      QuoteLanguage.german  => 'Gültige km eingeben',
      QuoteLanguage.turkish => 'Geçerli km girin',
    };
  }

  // Tarife Modu etiketleri
  String get modeHaven {
    return switch (language) {
      QuoteLanguage.dutch   => 'Haven',
      QuoteLanguage.french  => 'Port',
      QuoteLanguage.english => 'Haven',
      QuoteLanguage.german  => 'Hafen',
      QuoteLanguage.turkish => 'Haven',
    };
  }

  String get modeKmZone {
    return switch (language) {
      QuoteLanguage.dutch   => 'Km Zone',
      QuoteLanguage.french  => 'Zone Km',
      QuoteLanguage.english => 'Km Zone',
      QuoteLanguage.german  => 'Km-Zone',
      QuoteLanguage.turkish => 'Km Aralık',
    };
  }

  String get modePerKm {
    return switch (language) {
      QuoteLanguage.dutch   => 'Per Km',
      QuoteLanguage.french  => 'Par Km',
      QuoteLanguage.english => 'Per Km',
      QuoteLanguage.german  => 'Pro Km',
      QuoteLanguage.turkish => 'Km Başı',
    };
  }

  // Zaman
  String minutesAgo(int n) {
    return switch (language) {
      QuoteLanguage.dutch   => '$n minuten geleden',
      QuoteLanguage.french  => 'il y a $n minutes',
      QuoteLanguage.english => '$n minutes ago',
      QuoteLanguage.german  => 'vor $n Minuten',
      QuoteLanguage.turkish => '$n dakika önce',
    };
  }

  String hoursAgo(int n) {
    return switch (language) {
      QuoteLanguage.dutch   => '$n uur geleden',
      QuoteLanguage.french  => 'il y a $n heures',
      QuoteLanguage.english => '$n hours ago',
      QuoteLanguage.german  => 'vor $n Stunden',
      QuoteLanguage.turkish => '$n saat önce',
    };
  }

  String daysAgo(int n) {
    return switch (language) {
      QuoteLanguage.dutch   => '$n dagen geleden',
      QuoteLanguage.french  => 'il y a $n jours',
      QuoteLanguage.english => '$n days ago',
      QuoteLanguage.german  => 'vor $n Tagen',
      QuoteLanguage.turkish => '$n gün önce',
    };
  }

  String get generalRecord {
    return switch (language) {
      QuoteLanguage.dutch   => 'registratie',
      QuoteLanguage.french  => 'enregistrement',
      QuoteLanguage.english => 'record',
      QuoteLanguage.german  => 'Eintrag',
      QuoteLanguage.turkish => 'kayıt',
    };
  }
}
