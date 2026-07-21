import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/delivery/new_delivery_screen.dart';
import '../../presentation/screens/delivery/delivery_summary_screen.dart';
import '../../presentation/screens/delivery/quote_preview_screen.dart';
import '../../presentation/screens/delivery/quick_quote_screen.dart';
import '../../presentation/screens/history/history_screen.dart';
import '../../presentation/screens/tariff/tariff_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/notifications/notifications_screen.dart';
import '../../presentation/screens/main_shell.dart';
import '../../presentation/screens/admin/admin_shell.dart';
import '../../presentation/screens/admin/admin_dashboard_screen.dart';
import '../../presentation/screens/admin/admin_deliveries_screen.dart';
import '../../presentation/screens/admin/admin_drivers_screen.dart';
import '../../presentation/screens/admin/admin_settings_screen.dart';
import '../../data/models/delivery_model.dart';
import '../../data/models/user_profile_model.dart';
import '../../presentation/providers/auth_provider.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/';
  static const String newDelivery = '/delivery/new';
  static const String quickQuote = '/delivery/quick';
  static const String deliverySummary = '/delivery/summary';
  static const String quotePreview = '/delivery/quote';
  static const String history = '/history';
  static const String tariff = '/tariff';
  static const String profile = '/profile';
  static const String notifications = '/notifications';

  // ─── Admin Rotaları ────────────────────────────────────────────────────────
  static const String admin = '/admin';
  static const String adminDeliveries = '/admin/deliveries';
  static const String adminDrivers = '/admin/drivers';
  static const String adminSettings = '/admin/settings';
}

final routerProvider = Provider<GoRouter>((ref) {
  // Auth state değişikliklerini dinle → router otomatik yenilenir
  final authState = ref.watch(authStateProvider);
  final profileAsync = ref.watch(currentUserProfileProvider);

  return GoRouter(
    initialLocation: AppRoutes.login,
    // ── Auth Guard ──────────────────────────────────────────────────────────
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isPublic =
          location == AppRoutes.login || location == AppRoutes.register;

      // Auth yükleniyorsa bekle (ilk başlatmada null gelir)
      if (authState.isLoading) return null;

      final user = authState.value;
      final isLoggedIn = user != null;

      // Giriş yapılmamışsa → login (public sayfalar hariç)
      if (!isLoggedIn && !isPublic) return AppRoutes.login;

      // Giriş yapılmışsa login/register'da durmamalı
      if (isLoggedIn && isPublic) {
        // Profil henüz yükleniyorsa bekle (timing sorunu önlenir)
        if (profileAsync.isLoading) return null;
        final role = profileAsync.value?.role;
        if (role == UserRole.manager) return AppRoutes.admin;
        return AppRoutes.home;
      }

      // Admin olmayan kullanıcı admin rotalarına giremez
      if (isLoggedIn && location.startsWith('/admin')) {
        // Profil henüz yükleniyorsa bekle
        if (profileAsync.isLoading) return null;
        final role = profileAsync.value?.role;
        if (role != UserRole.manager) return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      // ── Şoför Shell ──────────────────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.history,
            builder: (context, state) => const HistoryScreen(),
          ),
          GoRoute(
            path: AppRoutes.tariff,
            builder: (context, state) => const TariffScreen(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.newDelivery,
        builder: (context, state) => const NewDeliveryScreen(),
      ),
      GoRoute(
        path: AppRoutes.quickQuote,
        builder: (context, state) => const QuickQuoteScreen(),
      ),
      GoRoute(
        path: AppRoutes.deliverySummary,
        builder: (context, state) => DeliverySummaryScreen(
          delivery: state.extra as DeliveryModel,
        ),
      ),
      GoRoute(
        path: AppRoutes.quotePreview,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is Map<String, dynamic>) {
            return QuotePreviewScreen(
              delivery: extra['delivery'] as DeliveryModel,
              isInvoice: extra['isInvoice'] as bool? ?? false,
            );
          }
          return QuotePreviewScreen(delivery: extra as DeliveryModel);
        },
      ),
      // ── Admin Shell ───────────────────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.admin,
            builder: (context, state) => const AdminDashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.adminDeliveries,
            builder: (context, state) => const AdminDeliveriesScreen(),
          ),
          GoRoute(
            path: AppRoutes.adminDrivers,
            builder: (context, state) => const AdminDriversScreen(),
          ),
          GoRoute(
            path: AppRoutes.adminSettings,
            builder: (context, state) => const AdminSettingsScreen(),
          ),
        ],
      ),
    ],
  );
});
