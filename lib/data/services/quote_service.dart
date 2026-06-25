import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../data/models/delivery_model.dart';
import '../../data/models/tariff_zone_model.dart';
import '../../data/services/tariff_service.dart';
import '../../data/services/language_service.dart';

class QuoteService {
  // ─── Renk Paleti (PDF) ────────────────────────────────────────────────────
  static final _colorPrimary = PdfColor.fromHex('#1A237E');
  static final _colorAccent = PdfColor.fromHex('#2979FF');
  static final _colorSuccess = PdfColor.fromHex('#00C853');
  static final _colorWarning = PdfColor.fromHex('#FF6B35');
  static final _colorCyan = PdfColor.fromHex('#00BCD4');
  static final _colorBg = PdfColor.fromHex('#F8F9FC');
  static final _colorText = PdfColor.fromHex('#1C2333');
  static final _colorTextLight = PdfColor.fromHex('#6B7280');
  static final _colorBorder = PdfColor.fromHex('#E5E7EB');
  static final _colorTunnel = PdfColor.fromHex('#9C27B0');
  static final _colorDiesel = PdfColor.fromHex('#F59E0B');
  static final _colorInvoice = PdfColor.fromHex('#059669');

  // ─── Teklif PDF ───────────────────────────────────────────────────────────
  static Future<Uint8List> generateOfferte(
    DeliveryModel delivery, {
    QuoteLanguage? languageOverride,
  }) async {
    final lang = languageOverride ?? delivery.quoteLanguage;
    final pdf = pw.Document();
    final refNo = _generateRefNo(delivery);
    final dateStr = DateFormat('dd-MM-yyyy').format(delivery.createdAt);
    final L = (String key) => LanguageService.get(lang, key);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(refNo, dateStr, L, isInvoice: false),
              pw.SizedBox(height: 20),

              _buildClientSection(delivery, L),
              pw.SizedBox(height: 16),

              // Güzergah bölümü (varsa)
              if (delivery.hasRoute) ...[
                _buildRouteSection(delivery, L),
                pw.SizedBox(height: 16),
              ],

              // TIR bilgisi (varsa)
              if (delivery.truckModelName != null) ...[
                _buildTruckSection(delivery, L),
                pw.SizedBox(height: 16),
              ],

              _buildTransportSection(delivery, L),
              pw.SizedBox(height: 16),

              _buildPriceSection(delivery, L),
              pw.SizedBox(height: 16),

              if (delivery.hasGenset || delivery.isAdr)
                _buildBadgeSection(delivery, L),

              pw.Spacer(),
              _buildFooter(L),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // ─── Fatura PDF ───────────────────────────────────────────────────────────
  static Future<Uint8List> generateInvoice(DeliveryModel delivery) async {
    final lang = delivery.quoteLanguage;
    final pdf = pw.Document();
    final L = (String key) => LanguageService.get(lang, key);

    final dateStr = delivery.invoiceDate != null
        ? DateFormat('dd-MM-yyyy').format(delivery.invoiceDate!)
        : DateFormat('dd-MM-yyyy').format(DateTime.now());
    final dueDateStr = delivery.invoiceDueDate != null
        ? DateFormat('dd-MM-yyyy').format(delivery.invoiceDueDate!)
        : '';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildInvoiceHeader(
                delivery.invoiceNumber ?? '',
                dateStr,
                dueDateStr,
                L,
              ),
              pw.SizedBox(height: 20),

              _buildClientSection(delivery, L),
              pw.SizedBox(height: 16),

              if (delivery.hasRoute) ...[
                _buildRouteSection(delivery, L),
                pw.SizedBox(height: 16),
              ],

              _buildTransportSection(delivery, L),
              pw.SizedBox(height: 16),

              _buildPriceSection(delivery, L, isInvoice: true),
              pw.SizedBox(height: 16),

              // Ödeme bilgisi
              _buildPaymentInfo(delivery, dueDateStr, L),

              pw.Spacer(),
              _buildFooter(L),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // ─── Header (Teklif) ──────────────────────────────────────────────────────
  static pw.Widget _buildHeader(
    String refNo,
    String dateStr,
    String Function(String) L, {
    bool isInvoice = false,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: _colorPrimary,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'ANVERS LIMAN',
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'Teslimat Yönetim Sistemi',
                style: pw.TextStyle(
                  color: const PdfColor.fromInt(0xB3FFFFFF),
                  fontSize: 10,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'Haven van Antwerpen',
                style: pw.TextStyle(
                  color: const PdfColor.fromInt(0x8AFFFFFF),
                  fontSize: 9,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: pw.BoxDecoration(
                  color: _colorAccent,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(
                  L('offerte'),
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                '${L('ref')}: $refNo',
                style: pw.TextStyle(
                    color: const PdfColor.fromInt(0xB3FFFFFF), fontSize: 9),
              ),
              pw.Text(
                '${L('date')}: $dateStr',
                style: pw.TextStyle(
                    color: const PdfColor.fromInt(0xB3FFFFFF), fontSize: 9),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Header (Fatura) ──────────────────────────────────────────────────────
  static pw.Widget _buildInvoiceHeader(
    String invoiceNo,
    String dateStr,
    String dueDateStr,
    String Function(String) L,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: _colorInvoice,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'ANVERS LIMAN',
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'Teslimat Yönetim Sistemi',
                style: pw.TextStyle(
                  color: const PdfColor.fromInt(0xB3FFFFFF),
                  fontSize: 10,
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Container(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(
                  L('invoice'),
                  style: pw.TextStyle(
                    color: _colorInvoice,
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                invoiceNo,
                style: pw.TextStyle(
                    color: const PdfColor.fromInt(0xB3FFFFFF), fontSize: 9),
              ),
              pw.Text(
                '${L('date')}: $dateStr',
                style: pw.TextStyle(
                    color: const PdfColor.fromInt(0xB3FFFFFF), fontSize: 9),
              ),
              if (dueDateStr.isNotEmpty)
                pw.Text(
                  '${L('dueDate')}: $dueDateStr',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Müşteri Bilgisi ──────────────────────────────────────────────────────
  static pw.Widget _buildClientSection(
      DeliveryModel delivery, String Function(String) L) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: _colorBg,
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: _colorBorder),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  L('client'),
                  style: pw.TextStyle(
                    color: _colorTextLight,
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  delivery.displayClientName,
                  style: pw.TextStyle(
                    color: _colorText,
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                if (delivery.contactPerson != null &&
                    delivery.contactPerson!.isNotEmpty) ...[
                  pw.SizedBox(height: 3),
                  pw.Text(
                    '${L('contactPerson')} ${delivery.contactPerson}',
                    style:
                        pw.TextStyle(color: _colorTextLight, fontSize: 10),
                  ),
                ],
                if (delivery.isQuickQuote) ...[
                  pw.SizedBox(height: 3),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: pw.BoxDecoration(
                      color: _colorDiesel.shade(0.9),
                      borderRadius: pw.BorderRadius.circular(3),
                    ),
                    child: pw.Text(
                      'QUICK QUOTE',
                      style: pw.TextStyle(
                        color: _colorDiesel,
                        fontSize: 7,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              _buildZoneBadge(delivery.destinationSide),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Güzergah Bölümü ──────────────────────────────────────────────────────
  static pw.Widget _buildRouteSection(
      DeliveryModel delivery, String Function(String) L) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          L('route'),
          style: pw.TextStyle(
            color: _colorPrimary,
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Container(
          padding: const pw.EdgeInsets.all(14),
          decoration: pw.BoxDecoration(
            color: _colorBg,
            border: pw.Border.all(color: _colorBorder),
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (delivery.pickupHaven != null &&
                  delivery.pickupHaven!.isNotEmpty)
                _buildRouteRow(
                  '⚓',
                  L('pickupHaven'),
                  delivery.pickupHaven!,
                  _colorAccent,
                ),
              if (delivery.deliveryAddress != null &&
                  delivery.deliveryAddress!.isNotEmpty) ...[
                pw.SizedBox(height: 4),
                _buildRouteRow(
                  '↓',
                  L('deliveryAddress'),
                  delivery.deliveryAddress!,
                  _colorText,
                ),
              ],
              if (delivery.returnHaven != null &&
                  delivery.returnHaven!.isNotEmpty) ...[
                pw.SizedBox(height: 4),
                _buildRouteRow(
                  '⚓',
                  L('returnHaven'),
                  delivery.returnHaven!,
                  _colorSuccess,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildRouteRow(
    String icon,
    String label,
    String value,
    PdfColor color,
  ) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(icon, style: const pw.TextStyle(fontSize: 12)),
        pw.SizedBox(width: 8),
        pw.SizedBox(
          width: 120,
          child: pw.Text(
            label,
            style: pw.TextStyle(color: _colorTextLight, fontSize: 9),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            value,
            style: pw.TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // ─── TIR Bilgisi ──────────────────────────────────────────────────────────
  static pw.Widget _buildTruckSection(
      DeliveryModel delivery, String Function(String) L) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: _colorBg,
        border: pw.Border.all(color: _colorBorder),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Row(
        children: [
          pw.Text(
            '🚛',
            style: const pw.TextStyle(fontSize: 18),
          ),
          pw.SizedBox(width: 10),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                delivery.truckModelName ?? '',
                style: pw.TextStyle(
                  color: _colorText,
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 11,
                ),
              ),
              if (delivery.estimatedFuelLiters != null)
                pw.Text(
                  '${L('estimatedFuel')}: ${delivery.estimatedFuelLiters!.toStringAsFixed(1)} L',
                  style: pw.TextStyle(
                    color: _colorTextLight,
                    fontSize: 9,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Transport Detayları ──────────────────────────────────────────────────
  static pw.Widget _buildTransportSection(
      DeliveryModel delivery, String Function(String) L) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          L('transportDetails'),
          style: pw.TextStyle(
            color: _colorPrimary,
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: _colorBorder),
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Column(
            children: [
              _buildDetailRow(
                L('haven'),
                'Haven ${delivery.havenNumber}',
                isFirst: true,
              ),
              _buildDetailRow(
                L('destination'),
                '${delivery.destinationSide.dutchName} (${delivery.destinationSide.turkishName})',
              ),
              _buildDetailRow(
                L('departure'),
                delivery.driverSideAtDelivery.dutchName,
              ),
              _buildDetailRow(
                L('tunnel'),
                delivery.tunnelUsed ? L('tunnelYes') : L('tunnelNo'),
                valueColor: delivery.tunnelUsed ? _colorTunnel : _colorTextLight,
              ),
              if (delivery.estimatedMinutes != null)
                _buildDetailRow(
                  L('estimatedTime'),
                  '±${delivery.estimatedMinutes} ${L('minutes')}',
                  isLast: true,
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Fiyat Tablosu ────────────────────────────────────────────────────────
  static pw.Widget _buildPriceSection(
    DeliveryModel delivery,
    String Function(String) L, {
    bool isInvoice = false,
  }) {
    // Baz ücret etiketi
    String baseFeeLabel;
    double baseFeeAmount;
    if (delivery.tariffMode == TariffMode.havenBased) {
      baseFeeLabel = 'Haven ${delivery.havenNumber} — ${L('havenFee')}';
      baseFeeAmount = delivery.havenFee;
    } else if (delivery.tariffMode == TariffMode.kmZone) {
      final km = delivery.distanceKm?.toStringAsFixed(0) ?? '?';
      baseFeeLabel = '${L('kmZoneFee')} ($km km)';
      baseFeeAmount = delivery.havenFee; // zoneFee havenFee'ye yazılmış
    } else {
      final km = delivery.distanceKm?.toStringAsFixed(0) ?? '?';
      baseFeeLabel = '${L('perKmFee')} ($km km)';
      baseFeeAmount = delivery.havenFee;
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          L('priceBreakdown'),
          style: pw.TextStyle(
            color: _colorPrimary,
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: _colorBorder),
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Column(
            children: [
              // Tablo başlığı
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: pw.BoxDecoration(
                  color: _colorPrimary.shade(0.9),
                  borderRadius: const pw.BorderRadius.only(
                    topLeft: pw.Radius.circular(5),
                    topRight: pw.Radius.circular(5),
                  ),
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        L('description'),
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.Text(
                      L('amount'),
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Baz ücret
              _buildPriceRow(baseFeeLabel, baseFeeAmount),
              // Tünel
              if (delivery.tunnelUsed)
                _buildPriceRow(
                  'Kennedy Tunnel — ${L('tunnelFee')}',
                  delivery.tunnelFee,
                  color: _colorTunnel,
                ),
              // Genset
              if (delivery.hasGenset)
                _buildPriceRow(
                  L('gensetFee'),
                  delivery.gensetFee,
                  color: _colorCyan,
                  isTbd: delivery.gensetFee <= 0,
                  tbdLabel: L('tbdLabel'),
                ),
              // ADR
              if (delivery.isAdr)
                _buildPriceRow(
                  L('adrFee'),
                  delivery.adrFee,
                  color: _colorWarning,
                  isTbd: delivery.adrFee <= 0,
                  tbdLabel: L('tbdLabel'),
                ),
              // Dizel Toeslag
              if (delivery.hasDieselSurcharge)
                _buildPriceRow(
                  '${L('dieselSurcharge')} (${delivery.dieselSurchargePercent.toStringAsFixed(1)}%)',
                  delivery.dieselSurchargeFee,
                  color: _colorDiesel,
                ),
              // TOPLAM
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: pw.BoxDecoration(
                  color: isInvoice
                      ? _colorInvoice.shade(0.85)
                      : _colorSuccess.shade(0.85),
                  borderRadius: const pw.BorderRadius.only(
                    bottomLeft: pw.Radius.circular(5),
                    bottomRight: pw.Radius.circular(5),
                  ),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      L('total'),
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      '€ ${delivery.totalFee.toStringAsFixed(2)}',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          L('excVat'),
          style: pw.TextStyle(
            color: _colorTextLight,
            fontSize: 8,
            fontStyle: pw.FontStyle.italic,
          ),
        ),
        pw.SizedBox(height: 3),
        if (!isInvoice)
          pw.Text(
            L('validity'),
            style: pw.TextStyle(
              color: _colorTextLight,
              fontSize: 8,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
      ],
    );
  }

  // ─── Ödeme Bilgisi (Fatura) ───────────────────────────────────────────────
  static pw.Widget _buildPaymentInfo(
    DeliveryModel delivery,
    String dueDateStr,
    String Function(String) L,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: _colorInvoice.shade(0.9),
        border: pw.Border.all(color: _colorInvoice),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  '💳 Betaling / Ödeme / Payment',
                  style: pw.TextStyle(
                    color: _colorInvoice,
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'IBAN: BE XX XXXX XXXX XXXX',
                  style: pw.TextStyle(
                    color: _colorText,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
          if (dueDateStr.isNotEmpty)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  L('dueDate'),
                  style: pw.TextStyle(
                    color: _colorTextLight,
                    fontSize: 8,
                  ),
                ),
                pw.Text(
                  dueDateStr,
                  style: pw.TextStyle(
                    color: _colorInvoice,
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // ─── Genset / ADR Uyarı Kartları ─────────────────────────────────────────
  static pw.Widget _buildBadgeSection(
      DeliveryModel delivery, String Function(String) L) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 16),
      child: pw.Row(
        children: [
          if (delivery.hasGenset) ...[
            pw.Expanded(
              child: _buildBadge(
                icon: '⚡',
                label: 'GENSET',
                sublabel: L('gensetBadge'),
                color: _colorCyan,
              ),
            ),
            if (delivery.isAdr) pw.SizedBox(width: 10),
          ],
          if (delivery.isAdr)
            pw.Expanded(
              child: _buildBadge(
                icon: '⚠',
                label: 'ADR',
                sublabel: L('adrBadge'),
                color: _colorWarning,
              ),
            ),
        ],
      ),
    );
  }

  static pw.Widget _buildBadge({
    required String icon,
    required String label,
    required String sublabel,
    required PdfColor color,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: pw.BoxDecoration(
        color: color.shade(0.9),
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: color),
      ),
      child: pw.Row(
        children: [
          pw.Text(icon, style: const pw.TextStyle(fontSize: 16)),
          pw.SizedBox(width: 8),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                label,
                style: pw.TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                sublabel,
                style: pw.TextStyle(color: color, fontSize: 8),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Footer ───────────────────────────────────────────────────────────────
  static pw.Widget _buildFooter(String Function(String) L) {
    return pw.Column(
      children: [
        pw.Divider(color: _colorBorder),
        pw.SizedBox(height: 6),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              L('footerCompany'),
              style: pw.TextStyle(color: _colorTextLight, fontSize: 8),
            ),
            pw.Text(
              L('footerPort'),
              style: pw.TextStyle(color: _colorTextLight, fontSize: 8),
            ),
            pw.Text(
              L('excVat'),
              style: pw.TextStyle(
                color: _colorTextLight,
                fontSize: 8,
                fontStyle: pw.FontStyle.italic,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Yardımcı Widget'lar ──────────────────────────────────────────────────
  static pw.Widget _buildDetailRow(
    String label,
    String value, {
    bool isFirst = false,
    bool isLast = false,
    PdfColor? valueColor,
  }) {
    return pw.Container(
      padding:
          const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: pw.BoxDecoration(
        color: isFirst ? _colorBg : PdfColors.white,
        border: isLast
            ? null
            : pw.Border(
                bottom: pw.BorderSide(color: _colorBorder, width: 0.5),
              ),
      ),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 110,
            child: pw.Text(
              label,
              style: pw.TextStyle(color: _colorTextLight, fontSize: 9),
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              color: valueColor ?? _colorText,
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPriceRow(
    String description,
    double amount, {
    PdfColor? color,
    bool isTbd = false,
    String tbdLabel = 'Nader te bepalen',
  }) {
    return pw.Container(
      padding:
          const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: _colorBorder, width: 0.5),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            description,
            style: pw.TextStyle(
              color: color ?? _colorText,
              fontSize: 9,
            ),
          ),
          pw.Text(
            isTbd ? tbdLabel : '€ ${amount.toStringAsFixed(2)}',
            style: pw.TextStyle(
              color: color ?? _colorText,
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              fontStyle:
                  isTbd ? pw.FontStyle.italic : pw.FontStyle.normal,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildZoneBadge(PortSide side) {
    final isRechts = side == PortSide.rechteroever;
    final color = isRechts
        ? PdfColor.fromHex('#2979FF')
        : PdfColor.fromHex('#F57C00');
    return pw.Container(
      padding:
          const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: pw.BoxDecoration(
        color: color.shade(0.9),
        borderRadius: pw.BorderRadius.circular(4),
        border: pw.Border.all(color: color),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            side.dutchName,
            style: pw.TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(
            side.turkishName,
            style: pw.TextStyle(color: color, fontSize: 8),
          ),
        ],
      ),
    );
  }

  // ─── Referans numarası üretimi ────────────────────────────────────────────
  static String _generateRefNo(DeliveryModel delivery) {
    final now = delivery.createdAt;
    final year = now.year.toString().substring(2);
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final haven = delivery.havenNumber.toString().padLeft(4, '0');
    final prefix = delivery.isQuickQuote ? 'QQ' : 'ALT';
    return '$prefix-$year$month$day-H$haven';
  }
}
