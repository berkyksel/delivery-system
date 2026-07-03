import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/user_profile_model.dart';

// Mock şoför verileri
final _mockDrivers = [
  UserProfile(
    uid: 'driver_1',
    email: 'mehmet@anvers.com',
    firstName: 'Mehmet',
    lastName: 'Yılmaz',
    phone: '+32 470 123 456',
    vehiclePlate: '1-ABC-123',
    vehicleType: 'Kamyon',
    role: UserRole.driver,
    currentSide: 'rechteroever',
    createdAt: DateTime.now().subtract(const Duration(days: 120)),
  ),
  UserProfile(
    uid: 'driver_2',
    email: 'jan@anvers.com',
    firstName: 'Jan',
    lastName: 'De Vries',
    phone: '+32 471 234 567',
    vehiclePlate: '1-XYZ-456',
    vehicleType: 'Tır',
    role: UserRole.driver,
    currentSide: 'linkeroever',
    createdAt: DateTime.now().subtract(const Duration(days: 85)),
  ),
  UserProfile(
    uid: 'driver_3',
    email: 'pierre@anvers.com',
    firstName: 'Pierre',
    lastName: 'Dubois',
    phone: '+32 472 345 678',
    vehiclePlate: '1-DEF-789',
    vehicleType: 'Kamyon',
    role: UserRole.driver,
    currentSide: 'rechteroever',
    createdAt: DateTime.now().subtract(const Duration(days: 45)),
  ),
];

// Her şoförün mock teslimat istatistikleri
final _driverStats = {
  'driver_1': {'deliveries': 47, 'earnings': 1204.80, 'tunnels': 18},
  'driver_2': {'deliveries': 32, 'earnings': 816.40, 'tunnels': 12},
  'driver_3': {'deliveries': 19, 'earnings': 456.20, 'tunnels': 6},
};

class AdminDriversScreen extends ConsumerStatefulWidget {
  const AdminDriversScreen({super.key});

  @override
  ConsumerState<AdminDriversScreen> createState() =>
      _AdminDriversScreenState();
}

class _AdminDriversScreenState extends ConsumerState<AdminDriversScreen> {
  String _searchQuery = '';

  List<UserProfile> get _filtered {
    if (_searchQuery.isEmpty) return _mockDrivers;
    return _mockDrivers
        .where((d) =>
            d.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (d.vehiclePlate ?? '').toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(theme, isDark),
          SliverToBoxAdapter(
            child: _buildSearchBar(theme, isDark)
                .animate()
                .fadeIn(duration: 300.ms),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  final driver = _filtered[i];
                  final stats = _driverStats[driver.uid] ??
                      {'deliveries': 0, 'earnings': 0.0, 'tunnels': 0};
                  return _DriverCard(
                    driver: driver,
                    stats: stats,
                    theme: theme,
                    isDark: isDark,
                  ).animate().fadeIn(
                      delay: Duration(milliseconds: i * 80), duration: 350.ms);
                },
                childCount: _filtered.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(ThemeData theme, bool isDark) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: theme.scaffoldBackgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? const [Color(0xFF3B2A0A), Color(0xFF0A0E1A)]
                  : const [Color(0xFFF59E0B), Color(0xFFFFD54F)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Şoförler',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '${_mockDrivers.length} aktif şoför',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v),
        style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'İsim veya plaka ile ara...',
          prefixIcon: Icon(Icons.search_rounded,
              color: theme.colorScheme.onSurfaceVariant),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

class _DriverCard extends StatelessWidget {
  final UserProfile driver;
  final Map<String, Object> stats;
  final ThemeData theme;
  final bool isDark;

  const _DriverCard({
    required this.driver,
    required this.stats,
    required this.theme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = theme.colorScheme.surface;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);

    final isRight = driver.currentSide == 'rechteroever';
    final sideColor =
        isRight ? AppColors.rechteroever : AppColors.linkeroever;

    final initials =
        '${driver.firstName[0]}${driver.lastName[0]}';

    return GestureDetector(
      onTap: () => _showDriverDetail(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Avatar
                Stack(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: cardBg,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                // İsim & Bilgiler
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driver.fullName,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.directions_car_rounded,
                              size: 11,
                              color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(
                            '${driver.vehiclePlate ?? "—"}  •  ${driver.vehicleType ?? "—"}',
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      // Mevcut konum
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: sideColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isRight ? 'Rechteroever' : 'Linkeroever',
                          style: TextStyle(
                            color: sideColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Sağ ok
                Icon(Icons.chevron_right_rounded,
                    color: theme.colorScheme.onSurfaceVariant),
              ],
            ),
            const SizedBox(height: 12),
            // Mini istatistikler
            Row(
              children: [
                _MiniStat(
                  label: 'Teslimat',
                  value: '${stats['deliveries']}',
                  icon: Icons.local_shipping_rounded,
                  color: const Color(0xFF3B82F6),
                  theme: theme,
                ),
                _MiniStat(
                  label: 'Kazanç',
                  value:
                      '${(stats['earnings'] as num).toStringAsFixed(0)} €',
                  icon: Icons.euro_rounded,
                  color: const Color(0xFF10B981),
                  theme: theme,
                ),
                _MiniStat(
                  label: 'Tünel',
                  value: '${stats['tunnels']}',
                  icon: Icons.subway_rounded,
                  color: const Color(0xFFEF4444),
                  theme: theme,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDriverDetail(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _DriverDetailSheet(driver: driver, stats: stats, theme: theme, isDark: isDark),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final ThemeData theme;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.only(right: 6),
        child: Column(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(height: 3),
            Text(
              value,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DriverDetailSheet extends StatelessWidget {
  final UserProfile driver;
  final Map<String, Object> stats;
  final ThemeData theme;
  final bool isDark;

  const _DriverDetailSheet({
    required this.driver,
    required this.stats,
    required this.theme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final sheetBg = isDark ? const Color(0xFF1A2236) : Colors.white;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Header
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${driver.firstName[0]}${driver.lastName[0]}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    driver.fullName,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    driver.role.label,
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Bilgiler
          _DetailItem(label: 'E-posta', value: driver.email, theme: theme),
          if (driver.phone != null)
            _DetailItem(label: 'Telefon', value: driver.phone!, theme: theme),
          if (driver.vehiclePlate != null)
            _DetailItem(label: 'Plaka', value: driver.vehiclePlate!, theme: theme),
          if (driver.vehicleType != null)
            _DetailItem(
                label: 'Araç Tipi', value: driver.vehicleType!, theme: theme),
          const SizedBox(height: 16),
          // İstatistikler
          Text(
            'İSTATİSTİKLER',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _StatBlock(
                  label: 'Toplam Teslimat',
                  value: '${stats['deliveries']}',
                  color: const Color(0xFF3B82F6),
                  theme: theme),
              const SizedBox(width: 8),
              _StatBlock(
                  label: 'Toplam Kazanç',
                  value: '${(stats['earnings'] as num).toStringAsFixed(0)} €',
                  color: const Color(0xFF10B981),
                  theme: theme),
              const SizedBox(width: 8),
              _StatBlock(
                  label: 'Tünel Geçişi',
                  value: '${stats['tunnels']}',
                  color: const Color(0xFFEF4444),
                  theme: theme),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;

  const _DetailItem(
      {required this.label, required this.value, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant, fontSize: 13)),
          Text(value,
              style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final ThemeData theme;

  const _StatBlock(
      {required this.label,
      required this.value,
      required this.color,
      required this.theme});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    color: color, fontSize: 18, fontWeight: FontWeight.w800)),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant, fontSize: 9)),
          ],
        ),
      ),
    );
  }
}
