import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/delivery_model.dart';
import '../../../data/services/tariff_service.dart';

class DeliverySummaryScreen extends StatelessWidget {
  final DeliveryModel delivery;
  const DeliverySummaryScreen({super.key, required this.delivery});

  @override
  Widget build(BuildContext context) {
    final sideColor = delivery.destinationSide == PortSide.rechteroever
        ? AppColors.rechteroever
        : AppColors.linkeroever;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('Teslimat Özeti'),
        backgroundColor: AppColors.bgDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Success Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 44,
              ),
            )
                .animate()
                .scale(begin: const Offset(0, 0), duration: 500.ms,
                    curve: Curves.elasticOut),
            const SizedBox(height: 16),
            const Text(
              'Teslimat Hazır',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 6),
            Text(
              DateFormat('d MMMM yyyy, HH:mm').format(delivery.createdAt),
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 24),

            // Main Card
            _buildMainCard(context, sideColor)
                .animate()
                .fadeIn(delay: 400.ms, duration: 400.ms)
                .slideY(begin: 0.1, end: 0),
            const SizedBox(height: 16),

            // Tariff Card
            _buildTariffCard(sideColor)
                .animate()
                .fadeIn(delay: 500.ms, duration: 400.ms)
                .slideY(begin: 0.1, end: 0),
            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.edit_rounded, size: 18),
                    label: const Text('Düzenle'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 52),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Firestore'a kaydet
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✓ Teslimat kaydedildi!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                      context.go(AppRoutes.home);
                    },
                    icon: const Icon(Icons.save_rounded, size: 18),
                    label: const Text('Kaydet'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      minimumSize: const Size(0, 52),
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 600.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildMainCard(BuildContext context, Color sideColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: sideColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.anchor_rounded, color: sideColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      delivery.companyName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (delivery.contactPerson != null)
                      Text(
                        delivery.contactPerson!,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.bgCardLight),
          const SizedBox(height: 16),
          _InfoRow(
            icon: Icons.anchor_rounded,
            label: 'Haven',
            value: 'Haven ${delivery.havenNumber}',
            valueColor: AppColors.textPrimary,
          ),
          const SizedBox(height: 10),
          _InfoRow(
            icon: Icons.location_on_rounded,
            label: 'Bölge',
            value:
                '${delivery.destinationSide.dutchName} (${delivery.destinationSide.turkishName})',
            valueColor: sideColor,
          ),
          const SizedBox(height: 10),
          _InfoRow(
            icon: Icons.my_location_rounded,
            label: 'Hareket Noktası',
            value: delivery.driverSideAtDelivery.dutchName,
            valueColor: AppColors.textSecondary,
          ),
          if (delivery.tunnelUsed) ...[
            const SizedBox(height: 10),
            const _InfoRow(
              icon: Icons.alt_route,
              label: 'Tünel',
              value: 'Kennedy Tünel — Geçiş Var',
              valueColor: AppColors.tunnel,
            ),
          ],
          if (delivery.estimatedMinutes != null) ...[
            const SizedBox(height: 10),
            _InfoRow(
              icon: Icons.timer_outlined,
              label: 'Tahmini Süre',
              value: '~${delivery.estimatedMinutes} dakika',
              valueColor: AppColors.textSecondary,
            ),
          ],
          if (delivery.notes != null && delivery.notes!.isNotEmpty) ...[
            const SizedBox(height: 10),
            _InfoRow(
              icon: Icons.notes_rounded,
              label: 'Notlar',
              value: delivery.notes!,
              valueColor: AppColors.textSecondary,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTariffCard(Color sideColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.15),
            AppColors.bgCard,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.receipt_long_rounded,
                  size: 16, color: AppColors.accent),
              SizedBox(width: 8),
              Text(
                'ÜCRET DÖKÜMÜ',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _FeeRow(
            label: 'Haven ${delivery.havenNumber} Ücreti',
            value: '${delivery.havenFee.toStringAsFixed(2)} €',
          ),
          if (delivery.tunnelUsed) ...[
            const SizedBox(height: 8),
            _FeeRow(
              label: 'Kennedy Tünel Ücreti',
              value: '${delivery.tunnelFee.toStringAsFixed(2)} €',
              isHighlighted: true,
            ),
          ],
          const Divider(height: 24, color: AppColors.bgCardLight),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TOPLAM',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  fontSize: 16,
                ),
              ),
              Text(
                '${delivery.totalFee.toStringAsFixed(2)} €',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.success,
                  fontSize: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 10),
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _FeeRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlighted;

  const _FeeRow({
    required this.label,
    required this.value,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (isHighlighted)
              const Padding(
                padding: EdgeInsets.only(right: 6),
                child: Icon(Icons.alt_route,
                    size: 13, color: AppColors.tunnel),
              ),
            Text(
              label,
              style: TextStyle(
                color: isHighlighted
                    ? AppColors.tunnel
                    : AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            color: isHighlighted ? AppColors.tunnel : AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
