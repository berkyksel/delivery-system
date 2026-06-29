import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/delivery_model.dart';
import '../l10n/app_l10n.dart';

const _kQuoteLangKey = 'preferred_quote_language';

/// Başlangıçta yüklenen varsayılan teklif/uygulama dili.
final initialQuoteLanguageProvider =
    Provider<QuoteLanguage>((ref) => QuoteLanguage.dutch);

class QuoteLanguageNotifier extends Notifier<QuoteLanguage> {
  @override
  QuoteLanguage build() {
    return ref.read(initialQuoteLanguageProvider);
  }

  Future<void> setLanguage(QuoteLanguage lang) async {
    state = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kQuoteLangKey, lang.name);
  }
}

final quoteLanguageProvider =
    NotifierProvider<QuoteLanguageNotifier, QuoteLanguage>(
  QuoteLanguageNotifier.new,
);

/// Seçili uygulama diline göre AppL10n örneğini döndürür.
/// Ekranlar bu provider'ı izleyerek otomatik yeniden çizilir.
final appL10nProvider = Provider<AppL10n>((ref) {
  final lang = ref.watch(quoteLanguageProvider);
  return AppL10n(lang);
});

/// SharedPreferences'tan teklif/uygulama dilini önceden yükler.
Future<QuoteLanguage> loadSavedQuoteLanguage() async {
  final prefs = await SharedPreferences.getInstance();
  final value = prefs.getString(_kQuoteLangKey);
  if (value != null) {
    try {
      return QuoteLanguage.values.firstWhere((e) => e.name == value);
    } catch (_) {}
  }
  return QuoteLanguage.dutch;
}
