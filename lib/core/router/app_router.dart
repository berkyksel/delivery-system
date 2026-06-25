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
import '../../presentation/screens/main_shell.dart';
import '../../data/models/delivery_model.dart';

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
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.login,
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
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
    ],
  );
});
