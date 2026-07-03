import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';

class AdminShell extends ConsumerWidget {
  final Widget child;
  const AdminShell({super.key, required this.child});

  int _getSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location == AppRoutes.admin) return 0;
    if (location == AppRoutes.adminDeliveries) return 1;
    if (location == AppRoutes.adminDrivers) return 2;
    if (location == AppRoutes.adminSettings) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = _getSelectedIndex(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: child,
      bottomNavigationBar: _AdminBottomNavBar(
        selectedIndex: selectedIndex,
        isDark: isDark,
        theme: theme,
      ),
    );
  }
}

class _AdminBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final bool isDark;
  final ThemeData theme;

  const _AdminBottomNavBar({
    required this.selectedIndex,
    required this.isDark,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final navBg = theme.colorScheme.surface;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.08);

    return Container(
      decoration: BoxDecoration(
        color: navBg,
        border: Border(top: BorderSide(color: borderColor, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _AdminNavItem(
                icon: Icons.dashboard_rounded,
                label: 'Panel',
                isSelected: selectedIndex == 0,
                onTap: () => context.go(AppRoutes.admin),
              ),
              _AdminNavItem(
                icon: Icons.local_shipping_rounded,
                label: 'Teslimatlar',
                isSelected: selectedIndex == 1,
                onTap: () => context.go(AppRoutes.adminDeliveries),
              ),
              _AdminNavItem(
                icon: Icons.people_rounded,
                label: 'Şoförler',
                isSelected: selectedIndex == 2,
                onTap: () => context.go(AppRoutes.adminDrivers),
              ),
              _AdminNavItem(
                icon: Icons.settings_rounded,
                label: 'Ayarlar',
                isSelected: selectedIndex == 3,
                onTap: () => context.go(AppRoutes.adminSettings),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _AdminNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Admin paneli için farklı renk (amber/turuncu yerine yeşil/teal)
    const adminAccent = Color(0xFF10B981); // Emerald green
    const selectedColor = adminAccent;
    final unselectedColor = theme.brightness == Brightness.dark
        ? const Color(0xFF475569)
        : const Color(0xFF94A3B8);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                color: adminAccent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? selectedColor : unselectedColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? selectedColor : unselectedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
