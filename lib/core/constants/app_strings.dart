class AppStrings {
  // App
  static const String appName = 'Anvers Liman';
  static const String appNameFull = 'Anvers Liman Teslimat Sistemi';

  // Auth
  static const String login = 'Giriş Yap';
  static const String register = 'Kayıt Ol';
  static const String email = 'E-posta';
  static const String password = 'Şifre';
  static const String forgotPassword = 'Şifremi Unuttum';
  static const String driverRole = 'Şoför';
  static const String managerRole = 'Yönetici';

  // Navigation
  static const String home = 'Ana Sayfa';
  static const String newDelivery = 'Yeni Teslimat';
  static const String history = 'Geçmiş';
  static const String tariff = 'Tarife';
  static const String profile = 'Profil';

  // Port / Haven
  static const String haven = 'Haven';
  static const String havenNumber = 'Haven Numarası';
  static const String rechteroever = 'Rechteroever';
  static const String linkeroever = 'Linkeroever';
  static const String rightBank = 'Sağ Kıyı';
  static const String leftBank = 'Sol Kıyı';
  static const String currentSide = 'Mevcut Konum';

  // Tariff
  static const String havenFee = 'Haven Ücreti';
  static const String tunnelFee = 'Tünel Ücreti';
  static const String totalFee = 'Toplam Ücret';
  static const String tunnelRequired = 'Tünel Geçişi Gerekli';
  static const String noTunnel = 'Tünel Gerekmez';
  static const String estimatedDuration = 'Tahmini Süre';
  static const String tunnelFeeValue = '17,60 €';

  // Container Properties — Genset & ADR
  static const String containerProperties = 'Konteyner Özellikleri';
  static const String genset = 'Genset';
  static const String gensetSubtitle = 'Motorlu şase / Reefer konteyner';
  static const String gensetDutch = 'Genset (motor/chassis)';
  static const String adr = 'ADR';
  static const String adrSubtitle = 'Tehlikeli madde / patlayıcı';
  static const String adrDutch = 'ADR (gevaarlijke stoffen)';
  static const String gensetFeeLabel = 'Genset Ücreti';
  static const String adrFeeLabel = 'ADR Ücreti';
  static const String feeTbd = 'TBD';

  // Quote / Offerte
  static const String createQuote = 'Teklif Oluştur';
  static const String quotePreview = 'Fiyat Teklifi';
  static const String offerte = 'Offerte';
  static const String shareQuote = 'Teklifi Paylaş';
  static const String printQuote = 'Yazdır';
  static const String quoteReference = 'Referans No';
  static const String quoteDate = 'Tarih';
  static const String quoteClient = 'Müşteri';
  static const String quoteDetails = 'Teslimat Detayları';
  static const String quotePriceBreakdown = 'Prijsopgave'; // Hollandaca
  static const String quoteGenerating = 'PDF oluşturuluyor...';

  // Delivery
  static const String companyName = 'Firma Adı';
  static const String destination = 'Varış Noktası';
  static const String deliveryDate = 'Teslimat Tarihi';
  static const String notes = 'Notlar';
  static const String createDelivery = 'Teslimat Oluştur';
  static const String deliveryCreated = 'Teslimat oluşturuldu!';
  static const String deliverySummary = 'Teslimat Özeti';

  // Dashboard
  static const String todayDeliveries = 'Bugünkü Teslimatlar';
  static const String totalEarnings = 'Toplam Kazanç';
  static const String tunnelCount = 'Tünel Geçişi';
  static const String recentDeliveries = 'Son Teslimatlar';
  static const String noDeliveries = 'Henüz teslimat yok';

  // Profile
  static const String firstName = 'Ad';
  static const String lastName = 'Soyad';
  static const String phone = 'Telefon';
  static const String vehicle = 'Araç';
  static const String licensePlate = 'Plaka';
  static const String language = 'Dil';
  static const String theme = 'Tema';
  static const String notifications = 'Bildirimler';
  static const String logout = 'Çıkış Yap';
  static const String saveChanges = 'Değişiklikleri Kaydet';

  // Errors
  static const String invalidHaven = 'Geçersiz haven numarası (1-2000 arası)';
  static const String requiredField = 'Bu alan zorunludur';
  static const String invalidEmail = 'Geçersiz e-posta adresi';
  static const String weakPassword = 'Şifre en az 6 karakter olmalıdır';
  static const String networkError = 'İnternet bağlantısı yok';
  static const String genericError = 'Bir hata oluştu, tekrar deneyin';

  // Time
  static const String minutes = 'dk';
  static const String hours = 'sa';
}
