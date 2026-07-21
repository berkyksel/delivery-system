import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/locale_provider.dart';

class MainShell extends ConsumerWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  int _getSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location == AppRoutes.home) return 0;
    if (location == AppRoutes.history) return 1;
    if (location == AppRoutes.tariff) return 2;
    if (location == AppRoutes.profile) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = _getSelectedIndex(context);
    final l10n = ref.watch(appL10nProvider);

    return Scaffold(
      body: child,
      // FAB'ı kaldırdık — butonu nav bar'ın içine taşıdık
      bottomNavigationBar: _BottomNavBar(
        selectedIndex: selectedIndex,
        l10n: l10n,
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Alt Navigasyon Çubuğu — Ortada Yükselen Yeni Teslimat Butonu
// ══════════════════════════════════════════════════════════════════════════════
class _BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final dynamic l10n;

  const _BottomNavBar({
    required this.selectedIndex,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final navBg = theme.colorScheme.surface;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.08);

    return Container(
      decoration: BoxDecoration(
        color: navBg,
        border: Border(
          top: BorderSide(color: borderColor, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // ── Sol ve Sağ Nav Item'ları ─────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Ana Sayfa
                    _NavItem(
                      icon: Icons.home_rounded,
                      label: l10n.navHome,
                      isSelected: selectedIndex == 0,
                      onTap: () => context.go(AppRoutes.home),
                    ),
                    // Geçmiş
                    _NavItem(
                      icon: Icons.history_rounded,
                      label: l10n.navHistory,
                      isSelected: selectedIndex == 1,
                      onTap: () => context.go(AppRoutes.history),
                    ),
                    // Orta boşluk — merkez buton için
                    const SizedBox(width: 72),
                    // Tarife
                    _NavItem(
                      icon: Icons.receipt_long_rounded,
                      label: l10n.navTariff,
                      isSelected: selectedIndex == 2,
                      onTap: () => context.go(AppRoutes.tariff),
                    ),
                    // Profil
                    _NavItem(
                      icon: Icons.person_rounded,
                      label: l10n.navProfile,
                      isSelected: selectedIndex == 3,
                      onTap: () => context.go(AppRoutes.profile),
                    ),
                  ],
                ),
              ),

              // ── Merkez Yükselen Buton ─────────────────────────────────────
              Positioned(
                top: -22, // Nav bar üstüne taşar
                child: _CenterActionButton(l10n: l10n),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Merkezi Yükselen Aksiyon Butonu ───────────────────────────────────────────
class _CenterActionButton extends StatefulWidget {
  final dynamic l10n;
  const _CenterActionButton({required this.l10n});

  @override
  State<_CenterActionButton> createState() => _CenterActionButtonState();
}

class _CenterActionButtonState extends State<_CenterActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _ctrl.forward();
  void _onTapUp(TapUpDetails _) => _ctrl.reverse();
  void _onTapCancel() => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: () {
        HapticFeedback.mediumImpact();
        context.push(AppRoutes.newDelivery);
      },
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (_, child) => Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        ),
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF8C00), Color(0xFFFF6B00)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF6B00).withValues(alpha: 0.45),
                blurRadius: 18,
                spreadRadius: 2,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.add_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }
}

// ── Nav Item ─────────────────────────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedColor = theme.colorScheme.secondary;
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
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
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
