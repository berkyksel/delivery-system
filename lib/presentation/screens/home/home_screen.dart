import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/locale_provider.dart';
import '../../../data/models/delivery_model.dart';
import '../../../data/services/tariff_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Seçili kıyı — haritadan seçilebilir
  PortSide _currentSide = PortSide.rechteroever;

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

  // ── Konum Seçici BottomSheet ─────────────────────────────────────────────────
  Future<void> _showLocationPicker() async {
    final selected = await showModalBottomSheet<PortSide>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _LocationPickerSheet(currentSide: _currentSide),
    );
    if (selected != null && mounted) {
      setState(() => _currentSide = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalEarnings = _mockDeliveries
        .where((d) => d.status == DeliveryStatus.completed)
        .fold(0.0, (sum, d) => sum + d.totalFee);
    final tunnelCount = _mockDeliveries.where((d) => d.tunnelUsed).length;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = ref.watch(appL10nProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, theme, l10n),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildStatsRow(totalEarnings, tunnelCount, theme, isDark, l10n),
                const SizedBox(height: 20),
                _buildPortSideCard(theme, isDark, l10n),
                const SizedBox(height: 20),
                _buildRecentDeliveriesHeader(context, theme, l10n),
                const SizedBox(height: 12),
                ..._mockDeliveries.asMap().entries.map(
                  (entry) => _buildDeliveryCard(
                          entry.value, entry.key, theme, isDark)
                      .animate()
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

  Widget _buildAppBar(BuildContext context, ThemeData theme, dynamic l10n) {
    final isDark = theme.brightness == Brightness.dark;
    final gradientColors = isDark
        ? const [Color(0xFF0D47A1), Color(0xFF0A0E1A)]
        : const [Color(0xFF1565C0), Color(0xFF42A5F5)];
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                            l10n.homeGreeting,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            l10n.homeWelcome,
                            style: const TextStyle(
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

  Widget _buildStatsRow(
    double totalEarnings,
    int tunnelCount,
    ThemeData theme,
    bool isDark,
    dynamic l10n,
  ) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.local_shipping_rounded,
            label: l10n.homeToday,
            value: '${_mockDeliveries.length}',
            subtitle: l10n.homeDelivery,
            color: AppColors.primary,
            theme: theme,
            isDark: isDark,
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.euro_rounded,
            label: l10n.homeEarnings,
            value: totalEarnings.toStringAsFixed(2),
            subtitle: 'EUR',
            color: AppColors.success,
            theme: theme,
            isDark: isDark,
          )
              .animate()
              .fadeIn(delay: 80.ms, duration: 400.ms)
              .slideY(begin: 0.2, end: 0),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.alt_route,
            label: l10n.homeTunnel,
            value: '$tunnelCount',
            subtitle: l10n.homeTunnelPassage,
            color: AppColors.tunnel,
            theme: theme,
            isDark: isDark,
          )
              .animate()
              .fadeIn(delay: 160.ms, duration: 400.ms)
              .slideY(begin: 0.2, end: 0),
        ),
      ],
    );
  }

  Widget _buildPortSideCard(ThemeData theme, bool isDark, dynamic l10n) {
    final cardBg = theme.colorScheme.surface;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.08);

    final isRight = _currentSide == PortSide.rechteroever;
    final sideColor =
        isRight ? AppColors.rechteroever : AppColors.linkeroever;
    final sideText = isRight
        ? 'Rechteroever (Sağ Kıyı)'
        : 'Linkeroever (Sol Kıyı)';

    return GestureDetector(
      onTap: _showLocationPicker,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: sideColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.location_on_rounded,
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
                    l10n.homeCurrentLocation,
                    style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant),
                  ),
                  Text(
                    sideText,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: sideColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: sideColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.map_rounded, size: 12, color: sideColor),
                  const SizedBox(width: 4),
                  Text(
                    l10n.homeChange,
                    style: TextStyle(
                      color: sideColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 240.ms, duration: 400.ms);
  }

  Widget _buildRecentDeliveriesHeader(
      BuildContext context, ThemeData theme, dynamic l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          l10n.homeRecentDeliveries,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        TextButton(
          onPressed: () => context.go(AppRoutes.history),
          child: Text(
            l10n.homeSeeAll,
            style: const TextStyle(color: AppColors.accent, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryCard(
      DeliveryModel delivery, int index, ThemeData theme, bool isDark) {
    final sideColor = delivery.destinationSide == PortSide.rechteroever
        ? AppColors.rechteroever
        : AppColors.linkeroever;

    final cardBg = theme.colorScheme.surface;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.08);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
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
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      'Haven ${delivery.havenNumber}',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 3,
                      height: 3,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurfaceVariant,
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
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
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

// ══════════════════════════════════════════════════════════════════════════════
// Konum Seçici BottomSheet
// ══════════════════════════════════════════════════════════════════════════════
class _LocationPickerSheet extends StatefulWidget {
  final PortSide currentSide;
  const _LocationPickerSheet({required this.currentSide});

  @override
  State<_LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<_LocationPickerSheet> {
  late PortSide _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.currentSide;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF111827) : Colors.white;
    final surfaceBg = isDark ? const Color(0xFF1A2236) : const Color(0xFFF8FAFC);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color:
                  theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Başlık
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.map_rounded,
                    color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mevcut Konumunuz',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'Antwerp Limanı kıyısını seçin',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Liman haritası görseli ─────────────────────────────────────
          Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              color: surfaceBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.06),
              ),
            ),
            child: Stack(
              children: [
                // Schelde nehri arka planı
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CustomPaint(
                    size: const Size(double.infinity, 160),
                    painter: _AntwerpMapPainter(
                      selectedSide: _selected,
                      isDark: isDark,
                    ),
                  ),
                ),
                // Rechteroever tıklama alanı (sağ yarı)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: MediaQuery.of(context).size.width / 2 - 20,
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _selected = PortSide.rechteroever),
                    child: Container(color: Colors.transparent),
                  ),
                ),
                // Linkeroever tıklama alanı (sol yarı)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: MediaQuery.of(context).size.width / 2 - 20,
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _selected = PortSide.linkeroever),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── İki kıyı seçim kartları ───────────────────────────────────
          Row(
            children: PortSide.values.map((side) {
              final isSelected = _selected == side;
              final color = side == PortSide.rechteroever
                  ? AppColors.rechteroever
                  : AppColors.linkeroever;
              final flag = side == PortSide.rechteroever ? '🏗️' : '🚢';
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selected = side),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(
                        right: side == PortSide.rechteroever ? 8 : 0),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withValues(alpha: 0.12)
                          : surfaceBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? color
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.black.withValues(alpha: 0.08)),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(flag,
                                style: const TextStyle(fontSize: 18)),
                            const Spacer(),
                            if (isSelected)
                              Icon(Icons.check_circle_rounded,
                                  color: color, size: 18),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          side.dutchName,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? color
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          side.turkishName,
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          side == PortSide.rechteroever
                              ? 'Haven 206 – 1700'
                              : 'Haven 101 – 869',
                          style: TextStyle(
                            fontSize: 10,
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Onayla butonu
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context, _selected),
              icon: const Icon(Icons.check_rounded, size: 18),
              label: Text(
                '${_selected.dutchName} Olarak Kaydet',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _selected == PortSide.rechteroever
                    ? AppColors.rechteroever
                    : AppColors.linkeroever,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Antwerp Liman Haritası CustomPainter ──────────────────────────────────────
class _AntwerpMapPainter extends CustomPainter {
  final PortSide selectedSide;
  final bool isDark;

  const _AntwerpMapPainter({
    required this.selectedSide,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Arka plan
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..color = isDark ? const Color(0xFF0D1B2A) : const Color(0xFFE8F4FD),
    );

    // Schelde nehri — ortadan geçen mavi şerit
    final riverPaint = Paint()
      ..color = isDark ? const Color(0xFF1565C0) : const Color(0xFF42A5F5)
      ..style = PaintingStyle.fill;

    final riverPath = Path()
      ..moveTo(w * 0.35, 0)
      ..lineTo(w * 0.45, 0)
      ..lineTo(w * 0.60, h)
      ..lineTo(w * 0.50, h)
      ..close();
    canvas.drawPath(riverPath, riverPaint);

    // Nehir üstü ince parlaklık
    canvas.drawPath(
      riverPath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.08)
        ..style = PaintingStyle.fill,
    );

    // Rechteroever (sağ kıyı) alanı
    final rightSelected = selectedSide == PortSide.rechteroever;
    final rightPaint = Paint()
      ..color = rightSelected
          ? AppColors.rechteroever.withValues(alpha: 0.25)
          : (isDark
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.black.withValues(alpha: 0.04))
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(w * 0.60, 0, w * 0.40, h),
      rightPaint,
    );

    // Linkeroever (sol kıyı) alanı
    final leftSelected = selectedSide == PortSide.linkeroever;
    final leftPaint = Paint()
      ..color = leftSelected
          ? AppColors.linkeroever.withValues(alpha: 0.25)
          : (isDark
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.black.withValues(alpha: 0.04))
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w * 0.35, h),
      leftPaint,
    );

    // Seçili taraf için kenarlık vurgusu
    if (rightSelected) {
      canvas.drawRect(
        Rect.fromLTWH(w * 0.60, 0, w * 0.40, h),
        Paint()
          ..color = AppColors.rechteroever.withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
    if (leftSelected) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, w * 0.35, h),
        Paint()
          ..color = AppColors.linkeroever.withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    // Labellar
    final textStyle = TextStyle(
      color: isDark ? Colors.white70 : Colors.black54,
      fontSize: 10,
      fontWeight: FontWeight.w600,
    );

    // "LINKEROEVER" etiketi
    _drawText(canvas, 'LINKEROEVER', Offset(w * 0.17, h * 0.18), textStyle,
        leftSelected ? AppColors.linkeroever : null);

    // "SCHELDE" etiketi
    _drawText(canvas, 'SCHELDE', Offset(w * 0.42, h * 0.45),
        textStyle.copyWith(color: Colors.white70, fontSize: 8), null,
        rotated: true);

    // "RECHTEROEVER" etiketi
    _drawText(canvas, 'RECHTEROEVER', Offset(w * 0.68, h * 0.18), textStyle,
        rightSelected ? AppColors.rechteroever : null);

    // Harita konumu ikonları
    _drawLocationPin(canvas, Offset(w * 0.17, h * 0.6),
        leftSelected ? AppColors.linkeroever : Colors.grey.withValues(alpha: 0.5));
    _drawLocationPin(canvas, Offset(w * 0.78, h * 0.6),
        rightSelected ? AppColors.rechteroever : Colors.grey.withValues(alpha: 0.5));

    // Kuzey ok işareti
    _drawNorthArrow(canvas, Offset(w - 20, 20), isDark);
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style,
      Color? highlightColor,
      {bool rotated = false}) {
    final painter = TextPainter(
      text: TextSpan(
          text: text,
          style: highlightColor != null
              ? style.copyWith(
                  color: highlightColor, fontWeight: FontWeight.w800)
              : style),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    if (rotated) {
      canvas.save();
      canvas.translate(offset.dx, offset.dy);
      canvas.rotate(-1.5708); // -90 derece
      painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));
      canvas.restore();
    } else {
      painter.paint(
          canvas, Offset(offset.dx - painter.width / 2, offset.dy));
    }
  }

  void _drawLocationPin(Canvas canvas, Offset center, Color color) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    canvas.drawCircle(center, 6, paint);
    canvas.drawCircle(
        center, 6, Paint()..color = color.withValues(alpha: 0.3)..style = PaintingStyle.stroke..strokeWidth = 3);
  }

  void _drawNorthArrow(Canvas canvas, Offset pos, bool isDark) {
    final color =
        isDark ? Colors.white.withValues(alpha: 0.5) : Colors.black38;
    final paint = Paint()..color = color..strokeWidth = 1.5..style = PaintingStyle.stroke;
    canvas.drawLine(pos, Offset(pos.dx, pos.dy - 12), paint);
    canvas.drawLine(pos, Offset(pos.dx - 4, pos.dy - 8),
        Paint()..color = color..strokeWidth = 1.5..style = PaintingStyle.stroke);
    canvas.drawLine(pos, Offset(pos.dx + 4, pos.dy - 8),
        Paint()..color = color..strokeWidth = 1.5..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(_AntwerpMapPainter old) =>
      old.selectedSide != selectedSide || old.isDark != isDark;
}

// ── Stat Kartı ───────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String subtitle;
  final Color color;
  final ThemeData theme;
  final bool isDark;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.theme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = theme.colorScheme.surface;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.08);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
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
            style: TextStyle(
              fontSize: 11,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Durum Rozeti ─────────────────────────────────────────────────────────────
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
        color = AppColors.info;
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
