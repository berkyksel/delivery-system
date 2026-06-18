import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/delivery_model.dart';
import '../../../data/services/tariff_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedFilter = 0; // 0=Tümü, 1=Bugün, 2=Bu Hafta, 3=Bu Ay

  final List<String> _filters = ['Tümü', 'Bugün', 'Bu Hafta', 'Bu Ay'];

  // Mock data
  static final List<DeliveryModel> _allDeliveries = [
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
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      driverId: 'user_1',
      status: DeliveryStatus.completed,
    ),
    DeliveryModel(
      id: '4',
      companyName: 'CMA CGM',
      havenNumber: 1700,
      destinationSide: PortSide.linkeroever,
      driverSideAtDelivery: PortSide.rechteroever,
      tunnelUsed: true,
      havenFee: 14.00,
      tunnelFee: 17.60,
      totalFee: 31.60,
      estimatedMinutes: 40,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      driverId: 'user_1',
      status: DeliveryStatus.completed,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  double get _totalEarnings => _allDeliveries
      .where((d) => d.status == DeliveryStatus.completed)
      .fold(0.0, (sum, d) => sum + d.totalFee);

  int get _tunnelCount =>
      _allDeliveries.where((d) => d.tunnelUsed).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: CustomScrollView(
        slivers: [
          _buildHeader(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildSummaryRow()
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.1),
                  const SizedBox(height: 16),
                  _buildFilterChips()
                      .animate()
                      .fadeIn(delay: 100.ms, duration: 400.ms),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final delivery = _allDeliveries[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _HistoryCard(delivery: delivery)
                        .animate()
                        .fadeIn(delay: (200 + index * 60).ms)
                        .slideX(begin: 0.05, end: 0),
                  );
                },
                childCount: _allDeliveries.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SliverAppBar(
      expandedHeight: 110,
      pinned: true,
      automaticallyImplyLeading: false,
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
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'Teslimat Geçmişi',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${_allDeliveries.length} kayıt',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
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

  Widget _buildSummaryRow() {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'Toplam Teslimat',
            value: _allDeliveries.length.toString(),
            icon: Icons.local_shipping_rounded,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            label: 'Toplam Kazanç',
            value: '${_totalEarnings.toStringAsFixed(2)} €',
            icon: Icons.euro_rounded,
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            label: 'Tünel Geçişi',
            value: _tunnelCount.toString(),
            icon: Icons.alt_route,
            color: AppColors.tunnel,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.asMap().entries.map((entry) {
          final isSelected = _selectedFilter == entry.key;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = entry.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.bgCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.glassBorder,
                  ),
                ),
                child: Text(
                  entry.value,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : AppColors.textSecondary,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.w400,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final DeliveryModel delivery;
  const _HistoryCard({required this.delivery});

  @override
  Widget build(BuildContext context) {
    final sideColor = delivery.destinationSide == PortSide.rechteroever
        ? AppColors.rechteroever
        : AppColors.linkeroever;

    final timeAgo = _formatTimeAgo(delivery.createdAt);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: sideColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.anchor_rounded, color: sideColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        delivery.companyName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Text(
                      '${delivery.totalFee.toStringAsFixed(2)} €',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Haven ${delivery.havenNumber}',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(width: 6),
                    Container(
                        width: 3,
                        height: 3,
                        decoration: const BoxDecoration(
                            color: AppColors.textMuted,
                            shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text(
                      delivery.destinationSide.dutchName,
                      style: TextStyle(color: sideColor, fontSize: 12),
                    ),
                    if (delivery.tunnelUsed) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.alt_route,
                          size: 11, color: AppColors.tunnel),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  timeAgo,
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes} dakika önce';
    if (diff.inHours < 24) return '${diff.inHours} saat önce';
    return '${diff.inDays} gün önce';
  }
}
