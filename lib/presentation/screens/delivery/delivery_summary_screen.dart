import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/delivery_model.dart';
import '../../../data/models/tariff_zone_model.dart';
import '../../../data/services/tariff_service.dart';
import '../../../data/services/invoice_service.dart';
import 'quote_preview_screen.dart';

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
                .scale(
                    begin: const Offset(0, 0),
                    duration: 500.ms,
                    curve: Curves.elasticOut),
            const SizedBox(height: 16),
            Text(
              delivery.isQuickQuote ? 'Hızlı Teklif Hazır' : 'Teslimat Hazır',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 6),
            Text(
              DateFormat('d MMMM yyyy, HH:mm').format(delivery.createdAt),
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13),
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 24),

            // Main Card
            _buildMainCard(context, sideColor)
                .animate()
                .fadeIn(delay: 400.ms, duration: 400.ms)
                .slideY(begin: 0.1, end: 0),
            const SizedBox(height: 14),

            // Güzergah Kartı (varsa)
            if (delivery.hasRoute) ...[
              _buildRouteCard()
                  .animate()
                  .fadeIn(delay: 450.ms, duration: 400.ms)
                  .slideY(begin: 0.1, end: 0),
              const SizedBox(height: 14),
            ],

            // TIR Kartı (varsa)
            if (delivery.truckModelName != null) ...[
              _buildTruckCard()
                  .animate()
                  .fadeIn(delay: 480.ms, duration: 400.ms)
                  .slideY(begin: 0.1, end: 0),
              const SizedBox(height: 14),
            ],

            // Tariff Card
            _buildTariffCard(sideColor)
                .animate()
                .fadeIn(delay: 500.ms, duration: 400.ms)
                .slideY(begin: 0.1, end: 0),
            const SizedBox(height: 24),

            // Buttons
            _buildButtonSection(context)
                .animate()
                .fadeIn(delay: 600.ms),
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
                      delivery.displayClientName,
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
                    // Hızlı teklif ve dil etiketleri
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      children: [
                        if (delivery.isQuickQuote)
                          _buildBadge(
                              Icons.flash_on_rounded,
                              'Hızlı Teklif',
                              AppColors.warning),
                        _buildBadge(
                          Icons.translate_rounded,
                          '${delivery.quoteLanguage.flag} ${delivery.quoteLanguage.label}',
                          AppColors.info,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (delivery.hasGenset || delivery.isAdr)
                Wrap(
                  spacing: 4,
                  children: [
                    if (delivery.hasGenset)
                      _buildBadge(
                          Icons.electrical_services_rounded,
                          'Genset',
                          const Color(0xFF00BCD4)),
                    if (delivery.isAdr)
                      _buildBadge(
                          Icons.warning_amber_rounded,
                          'ADR',
                          const Color(0xFFFF6B35)),
                  ],
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
          // Tarife modu
          const SizedBox(height: 10),
          _InfoRow(
            icon: Icons.calculate_rounded,
            label: 'Tarife Modu',
            value: _getTarifModeLabel(delivery.tariffMode),
            valueColor: AppColors.textSecondary,
          ),
          if (delivery.distanceKm != null) ...[
            const SizedBox(height: 10),
            _InfoRow(
              icon: Icons.route_rounded,
              label: 'Mesafe',
              value: '${delivery.distanceKm!.toStringAsFixed(0)} km',
              valueColor: AppColors.textSecondary,
            ),
          ],
          if (delivery.hasGenset) ...[
            const SizedBox(height: 10),
            const _InfoRow(
              icon: Icons.electrical_services_rounded,
              label: 'Genset',
              value: 'Motor/Şase — Aktif',
              valueColor: Color(0xFF00BCD4),
            ),
          ],
          if (delivery.isAdr) ...[
            const SizedBox(height: 10),
            const _InfoRow(
              icon: Icons.warning_amber_rounded,
              label: 'ADR',
              value: 'Tehlikeli Madde — Aktif',
              valueColor: Color(0xFFFF6B35),
            ),
          ],
          if (delivery.hasDieselSurcharge) ...[
            const SizedBox(height: 10),
            _InfoRow(
              icon: Icons.local_gas_station_rounded,
              label: 'Dizel Toeslag',
              value:
                  '%${delivery.dieselSurchargePercent.toStringAsFixed(1)} = ${delivery.dieselSurchargeFee.toStringAsFixed(2)} €',
              valueColor: AppColors.warning,
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

  // ─── Güzergah Kartı ───────────────────────────────────────────────────────
  Widget _buildRouteCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.alt_route_rounded,
                  size: 16, color: AppColors.accent),
              SizedBox(width: 8),
              Text(
                'GÜZERGAH',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (delivery.pickupHaven != null &&
              delivery.pickupHaven!.isNotEmpty)
            _RouteStep(
              icon: Icons.anchor_rounded,
              color: AppColors.rechteroever,
              label: 'Konşimentoya Alınacak Liman',
              value: delivery.pickupHaven!,
            ),
          if (delivery.deliveryAddress != null &&
              delivery.deliveryAddress!.isNotEmpty) ...[
            _buildArrow(),
            _RouteStep(
              icon: Icons.location_on_rounded,
              color: AppColors.accent,
              label: 'Boşaltma / Yükleme Adresi',
              value: delivery.deliveryAddress!,
            ),
          ],
          if (delivery.returnHaven != null &&
              delivery.returnHaven!.isNotEmpty) ...[
            _buildArrow(),
            _RouteStep(
              icon: Icons.anchor_rounded,
              color: AppColors.success,
              label: 'Geri Verilecek Liman',
              value: delivery.returnHaven!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildArrow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: Icon(Icons.arrow_downward_rounded,
          size: 16, color: AppColors.textMuted),
    );
  }

  // ─── TIR Kartı ────────────────────────────────────────────────────────────
  Widget _buildTruckCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.local_shipping_rounded,
                color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  delivery.truckModelName ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontSize: 15,
                  ),
                ),
                if (delivery.estimatedFuelLiters != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.local_gas_station_rounded,
                          size: 13, color: AppColors.warning),
                      const SizedBox(width: 4),
                      Text(
                        'Tahmini Yakıt: ${delivery.estimatedFuelLiters!.toStringAsFixed(1)} L',
                        style: const TextStyle(
                          color: AppColors.warning,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (delivery.distanceKm != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '(${delivery.distanceKm!.toStringAsFixed(0)} km)',
                          style: const TextStyle(
                              color: AppColors.textMuted, fontSize: 11),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
          const Icon(Icons.local_shipping_rounded,
              size: 28, color: AppColors.primary),
        ],
      ),
    );
  }

  // ─── Ücret Dökümü ─────────────────────────────────────────────────────────
  Widget _buildTariffCard(Color sideColor) {
    // Baz ücret etiketi
    String baseFeeLabel;
    if (delivery.tariffMode == TariffMode.havenBased) {
      baseFeeLabel = 'Haven ${delivery.havenNumber} Ücreti';
    } else if (delivery.tariffMode == TariffMode.kmZone) {
      final km = delivery.distanceKm?.toStringAsFixed(0) ?? '?';
      baseFeeLabel = 'Km Aralık Ücreti ($km km)';
    } else {
      final km = delivery.distanceKm?.toStringAsFixed(0) ?? '?';
      baseFeeLabel = 'Km Başı Ücret ($km km)';
    }

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
            label: baseFeeLabel,
            value: '${delivery.havenFee.toStringAsFixed(2)} €',
          ),
          if (delivery.tunnelUsed) ...[
            const SizedBox(height: 8),
            _FeeRow(
              label: 'Kennedy Tünel Ücreti',
              value: '${delivery.tunnelFee.toStringAsFixed(2)} €',
              isHighlighted: true,
              highlightColor: AppColors.tunnel,
              icon: Icons.alt_route,
            ),
          ],
          if (delivery.hasGenset) ...[
            const SizedBox(height: 8),
            _FeeRow(
              label: 'Genset Ücreti',
              value: delivery.gensetFee > 0
                  ? '${delivery.gensetFee.toStringAsFixed(2)} €'
                  : 'TBD',
              isHighlighted: true,
              highlightColor: const Color(0xFF00BCD4),
              icon: Icons.electrical_services_rounded,
            ),
          ],
          if (delivery.isAdr) ...[
            const SizedBox(height: 8),
            _FeeRow(
              label: 'ADR Ücreti',
              value: delivery.adrFee > 0
                  ? '${delivery.adrFee.toStringAsFixed(2)} €'
                  : 'TBD',
              isHighlighted: true,
              highlightColor: const Color(0xFFFF6B35),
              icon: Icons.warning_amber_rounded,
            ),
          ],
          // Dizel Toeslag
          if (delivery.hasDieselSurcharge) ...[
            const SizedBox(height: 8),
            _FeeRow(
              label:
                  'Brandstoftoeslag (%${delivery.dieselSurchargePercent.toStringAsFixed(1)})',
              value: '${delivery.dieselSurchargeFee.toStringAsFixed(2)} €',
              isHighlighted: true,
              highlightColor: AppColors.warning,
              icon: Icons.local_gas_station_rounded,
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
                  fontSize: 26,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Butonlar ─────────────────────────────────────────────────────────────
  Widget _buildButtonSection(BuildContext context) {
    final isAccepted = delivery.quoteStatus == QuoteStatus.accepted;
    final isInvoiced = delivery.quoteStatus == QuoteStatus.invoiced;

    return Column(
      children: [
        // Teklif PDF butonu
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => QuotePreviewScreen(delivery: delivery),
                ),
              );
            },
            icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
            label: const Text('Fiyat Teklifi Oluştur (Offerte)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C3FC5),
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Teklif Kabul / Fatura
        if (!isInvoiced) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _handleAcceptAndInvoice(context),
              icon: Icon(
                isAccepted
                    ? Icons.receipt_rounded
                    : Icons.check_circle_outline_rounded,
                size: 18,
              ),
              label: Text(isAccepted
                  ? 'Faturaya Çevir'
                  : 'Teklif Kabul Edildi → Faturaya Çevir'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isAccepted ? AppColors.success : AppColors.info,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],

        // Fatura zaten varsa göster
        if (isInvoiced) ...[
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.receipt_rounded,
                    color: AppColors.success, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        delivery.invoiceNumber ?? '',
                        style: const TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      if (delivery.invoiceDueDate != null)
                        Text(
                          'Vade: ${DateFormat('dd.MM.yyyy').format(delivery.invoiceDueDate!)}',
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 11),
                        ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) =>
                          QuotePreviewScreen(delivery: delivery, isInvoice: true),
                    ));
                  },
                  child: const Text('Görüntüle'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],

        // Düzenle + Kaydet
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.edit_rounded, size: 18),
                label: const Text('Düzenle'),
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 52)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () {
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
        ),
      ],
    );
  }

  void _handleAcceptAndInvoice(BuildContext context) {
    final isAccepted = delivery.quoteStatus == QuoteStatus.accepted;

    if (!isAccepted) {
      // Önce kabul et, sonra kullanıcıya sor
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.bgCard,
          title: const Text('Teklif Kabul Edildi',
              style: TextStyle(color: AppColors.textPrimary)),
          content: const Text(
            'Bu teklif kabul edildi olarak işaretlenecek ve ardından faturaya çevrilecektir. Onaylıyor musunuz?',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                final invoiced = InvoiceService.convertToInvoice(
                  InvoiceService.markAsAccepted(delivery),
                );
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) =>
                      QuotePreviewScreen(delivery: invoiced, isInvoice: true),
                ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
              ),
              child: const Text('Onayla → Faturalandır'),
            ),
          ],
        ),
      );
    } else {
      // Zaten kabul edilmişse direkt fatura
      final invoiced = InvoiceService.convertToInvoice(delivery);
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) =>
            QuotePreviewScreen(delivery: invoiced, isInvoice: true),
      ));
    }
  }

  Widget _buildBadge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _getTarifModeLabel(TariffMode mode) {
    switch (mode) {
      case TariffMode.havenBased:
        return 'Haven Bazlı';
      case TariffMode.kmZone:
        return 'Km Aralık Bazlı';
      case TariffMode.perKm:
        return 'Km Başı';
    }
  }
}

// ─── Güzergah Adımı ──────────────────────────────────────────────────────────
class _RouteStep extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _RouteStep({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 10),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Info Row ─────────────────────────────────────────────────────────────────
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

// ─── Ücret Satırı ─────────────────────────────────────────────────────────────
class _FeeRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlighted;
  final Color highlightColor;
  final IconData? icon;

  const _FeeRow({
    required this.label,
    required this.value,
    this.isHighlighted = false,
    this.highlightColor = AppColors.tunnel,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (isHighlighted && icon != null)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Icon(icon, size: 13, color: highlightColor),
              ),
            Text(
              label,
              style: TextStyle(
                color:
                    isHighlighted ? highlightColor : AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            color: isHighlighted ? highlightColor : AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
