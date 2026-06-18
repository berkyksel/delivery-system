import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/delivery_model.dart';
import '../../../data/services/tariff_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Mock data - Firebase entegrasyonu eklenince kaldırılacak
  static final List<DeliveryModel> _mockDeliveries = [
    DeliveryModel(
      id: '1',
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
      driverId: 'user_1',
      status: DeliveryStatus.completed,
    ),
    DeliveryModel(
      id: '2',
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
      driverId: 'user_1',
      status: DeliveryStatus.completed,
    ),
    DeliveryModel(
      id: '3',
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
      driverId: 'user_1',
      status: DeliveryStatus.inProgress,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final totalEarnings = _mockDeliveries
        .where((d) => d.status == DeliveryStatus.completed)
        .fold(0.0, (sum, d) => sum + d.totalFee);
    final tunnelCount = _mockDeliveries
        .where((d) => d.tunnelUsed)
        .length;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildStatsRow(totalEarnings, tunnelCount),
                const SizedBox(height: 20),
                _buildPortSideCard(),
                const SizedBox(height: 20),
                _buildRecentDeliveriesHeader(context),
                const SizedBox(height: 12),
                ..._mockDeliveries.asMap().entries.map(
                  (entry) => _buildDeliveryCard(entry.value, entry.key).animate()
                    .fadeIn(delay: (entry.key * 80).ms)
                    .slideX(begin: 0.1, end: 0),
                ),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.bgDark,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D47A1), Color(0xFF0A0E1A)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Günaydın! 👋',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 14,
                            ),
                          ),
                          const Text(
                            'Hoş geldiniz',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: const Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('d MMMM yyyy, EEEE', 'tr').format(DateTime.now()),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
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

  Widget _buildStatsRow(double totalEarnings, int tunnelCount) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.local_shipping_rounded,
            label: 'Bugün',
            value: '${_mockDeliveries.length}',
            subtitle: 'teslimat',
            color: AppColors.primary,
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.euro_rounded,
            label: 'Kazanç',
            value: totalEarnings.toStringAsFixed(2),
            subtitle: 'EUR',
            color: AppColors.success,
          ).animate().fadeIn(delay: 80.ms, duration: 400.ms).slideY(begin: 0.2, end: 0),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.alt_route,
            label: 'Tünel',
            value: '$tunnelCount',
            subtitle: 'geçiş',
            color: AppColors.tunnel,
          ).animate().fadeIn(delay: 160.ms, duration: 400.ms).slideY(begin: 0.2, end: 0),
        ),
      ],
    );
  }

  Widget _buildPortSideCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A2236), Color(0xFF111827)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.rechteroever.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: AppColors.rechteroever,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mevcut Konum',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                Text(
                  'Rechteroever (Sağ Kıyı)',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.rechteroever.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.rechteroever.withValues(alpha: 0.3)),
            ),
            child: const Text(
              'Değiştir',
              style: TextStyle(
                color: AppColors.rechteroever,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 240.ms, duration: 400.ms);
  }

  Widget _buildRecentDeliveriesHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Son Teslimatlar',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        TextButton(
          onPressed: () => context.go(AppRoutes.history),
          child: const Text(
            'Tümünü Gör',
            style: TextStyle(color: AppColors.accent, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryCard(DeliveryModel delivery, int index) {
    final sideColor = delivery.destinationSide == PortSide.rechteroever
        ? AppColors.rechteroever
        : AppColors.linkeroever;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: sideColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.anchor_rounded,
              color: sideColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  delivery.companyName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      'Haven ${delivery.havenNumber}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 3,
                      height: 3,
                      decoration: const BoxDecoration(
                        color: AppColors.textMuted,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      delivery.destinationSide.dutchName,
                      style: TextStyle(color: sideColor, fontSize: 12),
                    ),
                    if (delivery.tunnelUsed) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.alt_route,
                          size: 12, color: AppColors.tunnel),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${delivery.totalFee.toStringAsFixed(2)} €',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              _StatusBadge(status: delivery.status),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String subtitle;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final DeliveryStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case DeliveryStatus.completed:
        color = AppColors.success;
        break;
      case DeliveryStatus.inProgress:
        color = AppColors.warning;
        break;
      case DeliveryStatus.cancelled:
        color = AppColors.error;
        break;
      default:
        color = AppColors.textMuted;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
