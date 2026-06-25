import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/theme/locale_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Türkçe tarih formatlaması için locale verisi başlat
  await initializeDateFormatting('tr');

  // Kaydedilmiş tema ve teklif dilini uygulama açılmadan önce yükle
  final savedThemeMode = await loadSavedThemeMode();
  final savedQuoteLanguage = await loadSavedQuoteLanguage();

  // Uygulama yalnızca dikey modda çalışır
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar rengi
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF111827),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // TODO: Firebase başlatma
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  runApp(
    ProviderScope(
      overrides: [
        // Kaydedilmiş tema modunu başlangıç değeri olarak geç
        initialThemeModeProvider.overrideWithValue(savedThemeMode),
        // Kaydedilmiş teklif dilini başlangıç değeri olarak geç
        initialQuoteLanguageProvider.overrideWithValue(savedQuoteLanguage),
      ],
      child: const AnversLimanApp(),
    ),
  );
}

class AnversLimanApp extends ConsumerWidget {
  const AnversLimanApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Anvers Liman',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}

