import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/delivery_model.dart';
import '../../../data/services/tariff_service.dart';

// ─── Mock admin veri ──────────────────────────────────────────────────────────
final _adminMockDeliveries = [
  DeliveryModel(
    id: 'a1',
    companyName: 'Maersk Logistics',
    havenNumber: 1700,
    destinationSide: PortSide.linkeroever,
    driverSideAtDelivery: PortSide.rechteroever,
    tunnelUsed: true,
    havenFee: 14.00,
    tunnelFee: 17.60,
    totalFee: 31.60,
    estimatedMinutes: 35,
    createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    driverId: 'driver_1',
    status: DeliveryStatus.completed,
  ),
  DeliveryModel(
    id: 'a2',
    companyName: 'DP World',
    havenNumber: 880,
    destinationSide: PortSide.rechteroever,
    driverSideAtDelivery: PortSide.rechteroever,
    tunnelUsed: false,
    havenFee: 20.00,
    tunnelFee: 0,
    totalFee: 20.00,
    estimatedMinutes: 20,
    createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    driverId: 'driver_2',
    status: DeliveryStatus.completed,
  ),
  DeliveryModel(
    id: 'a3',
    companyName: 'MSC Terminal',
    havenNumber: 1200,
    destinationSide: PortSide.linkeroever,
    driverSideAtDelivery: PortSide.linkeroever,
    tunnelUsed: false,
    havenFee: 0,
    tunnelFee: 0,
    totalFee: 0,
    estimatedMinutes: 25,
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    driverId: 'driver_1',
    status: DeliveryStatus.inProgress,
  ),
  DeliveryModel(
    id: 'a4',
    companyName: 'CMA CGM',
    havenNumber: 550,
    destinationSide: PortSide.rechteroever,
    driverSideAtDelivery: PortSide.rechteroever,
    tunnelUsed: false,
    havenFee: 20.00,
    tunnelFee: 0,
    totalFee: 20.00,
    estimatedMinutes: 22,
    createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    driverId: 'driver_3',
    status: DeliveryStatus.pending,
  ),
  DeliveryModel(
    id: 'a5',
    companyName: 'Evergreen Marine',
    havenNumber: 1350,
    destinationSide: PortSide.linkeroever,
    driverSideAtDelivery: PortSide.rechteroever,
    tunnelUsed: true,
    havenFee: 14.00,
    tunnelFee: 17.60,
    totalFee: 31.60,
    estimatedMinutes: 40,
    createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
    driverId: 'driver_2',
    status: DeliveryStatus.completed,
  ),
];

final _adminMockDrivers = [
  {'id': 'driver_1', 'name': 'Mehmet Yılmaz', 'plate': '1-ABC-123'},
  {'id': 'driver_2', 'name': 'Jan De Vries', 'plate': '1-XYZ-456'},
  {'id': 'driver_3', 'name': 'Pierre Dubois', 'plate': '1-DEF-789'},
];

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final today = DateTime.now();
    final todayDeliveries = _adminMockDeliveries.where((d) {
      return d.createdAt.year == today.year &&
          d.createdAt.month == today.month &&
          d.createdAt.day == today.day;
    }).toList();

    final totalEarnings = _adminMockDeliveries
        .where((d) => d.status == DeliveryStatus.completed)
        .fold(0.0, (sum, d) => sum + d.totalFee);

    final pendingCount = _adminMockDeliveries
        .where((d) => d.status == DeliveryStatus.pending)
        .length;
    final inProgressCount = _adminMockDeliveries
        .where((d) => d.status == DeliveryStatus.inProgress)
        .length;
    final completedCount = _adminMockDeliveries
        .where((d) => d.status == DeliveryStatus.completed)
        .length;
    final tunnelCount = _adminMockDeliveries.where((d) => d.tunnelUsed).length;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(theme, isDark),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── KPI Kartları ──────────────────────────────────────────
                _buildKpiGrid(
                  context,
                  theme,
                  isDark,
                  todayCount: todayDeliveries.length,
                  totalEarnings: totalEarnings,
                  driverCount: _adminMockDrivers.length,
                  tunnelCount: tunnelCount,
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
                const SizedBox(height: 20),
                // ── Durum Dağılımı ────────────────────────────────────────
                _buildStatusCard(
                  theme,
                  isDark,
                  pending: pendingCount,
                  inProgress: inProgressCount,
                  completed: completedCount,
                ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.1),
                const SizedBox(height: 20),
                // ── Son Aktiviteler ───────────────────────────────────────
                _buildRecentActivity(context, theme, isDark)
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 400.ms)
                    .slideY(begin: 0.1),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(ThemeData theme, bool isDark) {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: theme.scaffoldBackgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? const [Color(0xFF064E3B), Color(0xFF0A0E1A)]
                  : const [Color(0xFF059669), Color(0xFF10B981)],
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.shield_rounded,
                                size: 12, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              'YÖNETİCİ PANELİ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Genel Bakış',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    DateFormat('d MMMM y, EEEE', 'tr').format(DateTime.now()),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
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

  Widget _buildKpiGrid(
    BuildContext context,
    ThemeData theme,
    bool isDark, {
    required int todayCount,
    required double totalEarnings,
    required int driverCount,
    required int tunnelCount,
  }) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _KpiCard(
          icon: Icons.local_shipping_rounded,
          label: 'Bugünkü Teslimat',
          value: '$todayCount',
          color: const Color(0xFF3B82F6),
          isDark: isDark,
          theme: theme,
          onTap: () => context.go(AppRoutes.adminDeliveries),
        ),
        _KpiCard(
          icon: Icons.euro_rounded,
          label: 'Toplam Kazanç',
          value: '${totalEarnings.toStringAsFixed(0)} €',
          color: const Color(0xFF10B981),
          isDark: isDark,
          theme: theme,
        ),
        _KpiCard(
          icon: Icons.people_rounded,
          label: 'Aktif Şoförler',
          value: '$driverCount',
          color: const Color(0xFFF59E0B),
          isDark: isDark,
          theme: theme,
          onTap: () => context.go(AppRoutes.adminDrivers),
        ),
        _KpiCard(
          icon: Icons.subway_rounded,
          label: 'Tünel Geçişi',
          value: '$tunnelCount',
          color: const Color(0xFFEF4444),
          isDark: isDark,
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildStatusCard(
    ThemeData theme,
    bool isDark, {
    required int pending,
    required int inProgress,
    required int completed,
  }) {
    final total = pending + inProgress + completed;
    final cardBg = theme.colorScheme.surface;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.08);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.donut_large_rounded,
                  size: 14, color: Color(0xFF10B981)),
              const SizedBox(width: 8),
              Text(
                'TESLİMAT DURUMLARI',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 1.0,
                ),
              ),
              const Spacer(),
              Text(
                'Toplam $total',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Yüzde çubuğu
          if (total > 0) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Row(
                children: [
                  if (completed > 0)
                    Expanded(
                      flex: completed,
                      child: Container(
                        height: 10,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  if (inProgress > 0)
                    Expanded(
                      flex: inProgress,
                      child: Container(
                        height: 10,
                        color: const Color(0xFFF59E0B),
                      ),
                    ),
                  if (pending > 0)
                    Expanded(
                      flex: pending,
                      child: Container(
                        height: 10,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              _StatusBadge(
                label: 'Tamamlandı',
                count: completed,
                color: const Color(0xFF10B981),
                theme: theme,
              ),
              const SizedBox(width: 8),
              _StatusBadge(
                label: 'Yolda',
                count: inProgress,
                color: const Color(0xFFF59E0B),
                theme: theme,
              ),
              const SizedBox(width: 8),
              _StatusBadge(
                label: 'Bekliyor',
                count: pending,
                color: const Color(0xFF94A3B8),
                theme: theme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(
      BuildContext context, ThemeData theme, bool isDark) {
    final cardBg = theme.colorScheme.surface;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.08);

    final recent = _adminMockDeliveries.take(4).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history_rounded,
                  size: 14, color: Color(0xFF10B981)),
              const SizedBox(width: 8),
              Text(
                'SON AKTİVİTELER',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 1.0,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => context.go(AppRoutes.adminDeliveries),
                child: const Text(
                  'Tümünü Gör',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF10B981),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...recent.map((d) => _ActivityTile(delivery: d, theme: theme)),
        ],
      ),
    );
  }
}

// ─── KPI Kartı ────────────────────────────────────────────────────────────────
class _KpiCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;
  final ThemeData theme;
  final VoidCallback? onTap;

  const _KpiCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
    required this.theme,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = theme.colorScheme.surface;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.08);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: isDark ? 0.08 : 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Durum Badge ─────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final ThemeData theme;

  const _StatusBadge({
    required this.label,
    required this.count,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Aktivite Satırı ─────────────────────────────────────────────────────────
class _ActivityTile extends StatelessWidget {
  final DeliveryModel delivery;
  final ThemeData theme;

  const _ActivityTile({required this.delivery, required this.theme});

  Color get _statusColor {
    return switch (delivery.status) {
      DeliveryStatus.completed => const Color(0xFF10B981),
      DeliveryStatus.inProgress => const Color(0xFFF59E0B),
      DeliveryStatus.pending => const Color(0xFF94A3B8),
      DeliveryStatus.cancelled => const Color(0xFFEF4444),
    };
  }

  @override
  Widget build(BuildContext context) {
    final diff = DateTime.now().difference(delivery.createdAt);
    final timeAgo = diff.inMinutes < 60
        ? '${diff.inMinutes} dk önce'
        : diff.inHours < 24
            ? '${diff.inHours} sa önce'
            : '${diff.inDays} gün önce';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.local_shipping_rounded,
                size: 18, color: _statusColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  delivery.companyName,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Haven ${delivery.havenNumber}  •  ${delivery.totalFee.toStringAsFixed(2)} €',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  delivery.status.label,
                  style: TextStyle(
                    color: _statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                timeAgo,
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
