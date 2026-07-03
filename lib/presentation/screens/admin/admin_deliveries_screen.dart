import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/delivery_model.dart';
import '../../../data/services/tariff_service.dart';

// Mock veri — dashboard ile aynı kaynaktan
final _deliveries = [
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

final _driverNames = {
  'driver_1': 'Mehmet Yılmaz',
  'driver_2': 'Jan De Vries',
  'driver_3': 'Pierre Dubois',
};

class AdminDeliveriesScreen extends ConsumerStatefulWidget {
  const AdminDeliveriesScreen({super.key});

  @override
  ConsumerState<AdminDeliveriesScreen> createState() =>
      _AdminDeliveriesScreenState();
}

class _AdminDeliveriesScreenState
    extends ConsumerState<AdminDeliveriesScreen> {
  DeliveryStatus? _filterStatus; // null = tümü

  List<DeliveryModel> get _filtered {
    if (_filterStatus == null) return _deliveries;
    return _deliveries.where((d) => d.status == _filterStatus).toList();
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
            child: _buildFilterBar(theme, isDark)
                .animate()
                .fadeIn(duration: 300.ms),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _DeliveryCard(
                  delivery: _filtered[i],
                  driverName: _driverNames[_filtered[i].driverId] ?? 'Bilinmiyor',
                  theme: theme,
                  isDark: isDark,
                  onStatusChange: (newStatus) {
                    setState(() {
                      // Mock güncelleme
                    });
                  },
                ).animate().fadeIn(
                    delay: Duration(milliseconds: i * 60), duration: 300.ms),
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
                  ? const [Color(0xFF1E3A5F), Color(0xFF0A0E1A)]
                  : const [Color(0xFF1565C0), Color(0xFF42A5F5)],
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
                    'Tüm Teslimatlar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '${_deliveries.length} kayıt bulundu',
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

  Widget _buildFilterBar(ThemeData theme, bool isDark) {
    final filters = [
      (null, 'Tümü'),
      (DeliveryStatus.completed, 'Tamamlandı'),
      (DeliveryStatus.inProgress, 'Yolda'),
      (DeliveryStatus.pending, 'Bekliyor'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((f) {
            final isSelected = _filterStatus == f.$1;
            final color = f.$1 == null
                ? const Color(0xFF10B981)
                : f.$1 == DeliveryStatus.completed
                    ? const Color(0xFF10B981)
                    : f.$1 == DeliveryStatus.inProgress
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFF94A3B8);
            return GestureDetector(
              onTap: () => setState(() => _filterStatus = f.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color:
                      isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? color
                        : isDark
                            ? Colors.white.withValues(alpha: 0.15)
                            : Colors.black.withValues(alpha: 0.12),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  f.$2,
                  style: TextStyle(
                    color: isSelected ? color : theme.colorScheme.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  final DeliveryModel delivery;
  final String driverName;
  final ThemeData theme;
  final bool isDark;
  final ValueChanged<DeliveryStatus> onStatusChange;

  const _DeliveryCard({
    required this.delivery,
    required this.driverName,
    required this.theme,
    required this.isDark,
    required this.onStatusChange,
  });

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
    final cardBg = theme.colorScheme.surface;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);

    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            // Haven badge
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: delivery.destinationSide == PortSide.linkeroever
                      ? [
                          AppColors.linkeroever.withValues(alpha: 0.8),
                          AppColors.linkeroever
                        ]
                      : [
                          AppColors.rechteroever.withValues(alpha: 0.8),
                          AppColors.rechteroever
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '${delivery.havenNumber}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Detaylar
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    delivery.companyName,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '👤 $driverName',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (delivery.tunnelUsed) ...[
                        const Icon(Icons.subway_rounded,
                            size: 11, color: AppColors.accent),
                        const SizedBox(width: 3),
                        Text(
                          'Tünel  ',
                          style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 10),
                        ),
                      ],
                      Text(
                        delivery.destinationSide.dutchName,
                        style: TextStyle(
                          color: delivery.destinationSide ==
                                  PortSide.linkeroever
                              ? AppColors.linkeroever
                              : AppColors.rechteroever,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Sağ taraf
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${delivery.totalFee.toStringAsFixed(2)} €',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
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
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DeliveryDetailSheet(
        delivery: delivery,
        driverName: driverName,
        theme: theme,
        isDark: isDark,
        onStatusChange: onStatusChange,
      ),
    );
  }
}

class _DeliveryDetailSheet extends StatelessWidget {
  final DeliveryModel delivery;
  final String driverName;
  final ThemeData theme;
  final bool isDark;
  final ValueChanged<DeliveryStatus> onStatusChange;

  const _DeliveryDetailSheet({
    required this.delivery,
    required this.driverName,
    required this.theme,
    required this.isDark,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    final sheetBg =
        isDark ? const Color(0xFF1A2236) : Colors.white;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
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
          const SizedBox(height: 16),
          Text(
            delivery.companyName,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            'Şoför: $driverName',
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          _DetailRow(label: 'Haven No', value: '${delivery.havenNumber}', theme: theme),
          _DetailRow(
            label: 'Hedef Kıyı',
            value: '${delivery.destinationSide.dutchName} (${delivery.destinationSide.turkishName})',
            theme: theme,
          ),
          _DetailRow(
            label: 'Tünel',
            value: delivery.tunnelUsed ? 'Evet (+17,60 €)' : 'Hayır',
            theme: theme,
          ),
          _DetailRow(
            label: 'Haven Ücreti',
            value: '${delivery.havenFee.toStringAsFixed(2)} €',
            theme: theme,
          ),
          _DetailRow(
            label: 'Toplam',
            value: '${delivery.totalFee.toStringAsFixed(2)} €',
            theme: theme,
            highlight: true,
          ),
          const SizedBox(height: 12),
          // Durum değiştirme
          Text(
            'DURUMU GÜNCELLE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: DeliveryStatus.values.map((s) {
              final isSelected = delivery.status == s;
              final color = switch (s) {
                DeliveryStatus.completed => const Color(0xFF10B981),
                DeliveryStatus.inProgress => const Color(0xFFF59E0B),
                DeliveryStatus.pending => const Color(0xFF94A3B8),
                DeliveryStatus.cancelled => const Color(0xFFEF4444),
              };
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    onStatusChange(s);
                    Navigator.pop(context);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? color
                            : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      s.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected
                            ? color
                            : theme.colorScheme.onSurfaceVariant,
                        fontSize: 9,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;
  final bool highlight;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.theme,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: highlight
                  ? const Color(0xFF10B981)
                  : theme.colorScheme.onSurface,
              fontSize: highlight ? 16 : 13,
              fontWeight:
                  highlight ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
