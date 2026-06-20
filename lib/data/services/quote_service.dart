import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../data/models/delivery_model.dart';
import '../../data/services/tariff_service.dart';

class QuoteService {
  // ─── Renk Paleti (PDF) ────────────────────────────────────────────────────
  static final _colorPrimary = PdfColor.fromHex('#1A237E');    // Koyu lacivert
  static final _colorAccent = PdfColor.fromHex('#2979FF');     // Mavi
  static final _colorSuccess = PdfColor.fromHex('#00C853');    // Yeşil
  static final _colorWarning = PdfColor.fromHex('#FF6B35');    // Turuncu (ADR)
  static final _colorCyan = PdfColor.fromHex('#00BCD4');       // Cyan (Genset)
  static final _colorBg = PdfColor.fromHex('#F8F9FC');         // Açık gri bg
  static final _colorText = PdfColor.fromHex('#1C2333');       // Koyu metin
  static final _colorTextLight = PdfColor.fromHex('#6B7280');  // Açık metin
  static final _colorBorder = PdfColor.fromHex('#E5E7EB');     // Kenarlık
  static final _colorTunnel = PdfColor.fromHex('#9C27B0');     // Mor (tünel)

  /// Ana PDF üretim metodu
  static Future<Uint8List> generateOfferte(DeliveryModel delivery) async {
    final pdf = pw.Document();
    final refNo = _generateRefNo(delivery);
    final dateStr = DateFormat('dd-MM-yyyy').format(delivery.createdAt);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ── HEADER ──────────────────────────────────────────────────
              _buildHeader(refNo, dateStr),
              pw.SizedBox(height: 24),

              // ── KLANT INFO (Müşteri Bilgisi) ─────────────────────────────
              _buildClientSection(delivery),
              pw.SizedBox(height: 20),

              // ── HAVEN / TRANSPORT DETAILS ────────────────────────────────
              _buildTransportSection(delivery),
              pw.SizedBox(height: 20),

              // ── PRIJSOPGAVE (Fiyat Teklifi) ──────────────────────────────
              _buildPriceSection(delivery),
              pw.SizedBox(height: 20),

              // ── BADGES (Genset / ADR uyarıları) ─────────────────────────
              if (delivery.hasGenset || delivery.isAdr)
                _buildBadgeSection(delivery),

              pw.Spacer(),

              // ── FOOTER ──────────────────────────────────────────────────
              _buildFooter(),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // ─── Header ───────────────────────────────────────────────────────────────
  static pw.Widget _buildHeader(String refNo, String dateStr) {
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
                padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: pw.BoxDecoration(
                  color: _colorAccent,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(
                  'OFFERTE',
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
                'Ref: $refNo',
                style: pw.TextStyle(color: const PdfColor.fromInt(0xB3FFFFFF), fontSize: 9),
              ),
              pw.Text(
                'Datum: $dateStr',
                style: pw.TextStyle(color: const PdfColor.fromInt(0xB3FFFFFF), fontSize: 9),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Müşteri Bilgisi ──────────────────────────────────────────────────────
  static pw.Widget _buildClientSection(DeliveryModel delivery) {
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
                  'KLANT / MÜŞTERİ',
                  style: pw.TextStyle(
                    color: _colorTextLight,
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  delivery.companyName,
                  style: pw.TextStyle(
                    color: _colorText,
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                if (delivery.contactPerson != null) ...[
                  pw.SizedBox(height: 3),
                  pw.Text(
                    't.a.v. ${delivery.contactPerson}',
                    style: pw.TextStyle(
                      color: _colorTextLight,
                      fontSize: 10,
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

  // ─── Transport Detayları ──────────────────────────────────────────────────
  static pw.Widget _buildTransportSection(DeliveryModel delivery) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'TRANSPORTDETAILS',
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
              _buildDetailRow('Haven', 'Haven ${delivery.havenNumber}', isFirst: true),
              _buildDetailRow(
                'Bestemming',
                '${delivery.destinationSide.dutchName} (${delivery.destinationSide.turkishName})',
              ),
              _buildDetailRow(
                'Vertrekpunt',
                delivery.driverSideAtDelivery.dutchName,
              ),
              _buildDetailRow(
                'Kennedy Tunnel',
                delivery.tunnelUsed ? 'Ja — Tunnel doorkruist' : 'Nee',
                valueColor: delivery.tunnelUsed ? _colorTunnel : _colorTextLight,
              ),
              if (delivery.estimatedMinutes != null)
                _buildDetailRow(
                  'Geschatte tijd',
                  '±${delivery.estimatedMinutes} minuten',
                  isLast: true,
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Fiyat Tablosu ────────────────────────────────────────────────────────
  static pw.Widget _buildPriceSection(DeliveryModel delivery) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'PRIJSOPGAVE',
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
                padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                        'Omschrijving',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.Text(
                      'Bedrag (€)',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Haven ücreti
              _buildPriceRow(
                'Haven ${delivery.havenNumber} — haventarief',
                delivery.havenFee,
              ),
              // Tünel ücreti
              if (delivery.tunnelUsed)
                _buildPriceRow(
                  'Kennedy Tunnel — doorkruistoeslag',
                  delivery.tunnelFee,
                  color: _colorTunnel,
                ),
              // Genset ücreti
              if (delivery.hasGenset)
                _buildPriceRow(
                  'Genset toeslag (motor/chassis)',
                  delivery.gensetFee,
                  color: _colorCyan,
                  isTbd: delivery.gensetFee <= 0,
                ),
              // ADR ücreti
              if (delivery.isAdr)
                _buildPriceRow(
                  'ADR toeslag (gevaarlijke stoffen)',
                  delivery.adrFee,
                  color: _colorWarning,
                  isTbd: delivery.adrFee <= 0,
                ),
              // TOPLAM
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: pw.BoxDecoration(
                  color: _colorSuccess.shade(0.85),
                  borderRadius: const pw.BorderRadius.only(
                    bottomLeft: pw.Radius.circular(5),
                    bottomRight: pw.Radius.circular(5),
                  ),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'TOTAAL',
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
      ],
    );
  }

  // ─── Genset / ADR Uyarı Kartları ─────────────────────────────────────────
  static pw.Widget _buildBadgeSection(DeliveryModel delivery) {
    return pw.Row(
      children: [
        if (delivery.hasGenset) ...[
          pw.Expanded(child: _buildBadge(
            icon: '⚡',
            label: 'GENSET',
            sublabel: 'Motor/chassis aanwezig',
            color: _colorCyan,
          )),
          if (delivery.isAdr) pw.SizedBox(width: 10),
        ],
        if (delivery.isAdr)
          pw.Expanded(child: _buildBadge(
            icon: '⚠',
            label: 'ADR',
            sublabel: 'Gevaarlijke stoffen',
            color: _colorWarning,
          )),
      ],
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
  static pw.Widget _buildFooter() {
    return pw.Column(
      children: [
        pw.Divider(color: _colorBorder),
        pw.SizedBox(height: 6),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Anvers Liman Teslimat Sistemi',
              style: pw.TextStyle(color: _colorTextLight, fontSize: 8),
            ),
            pw.Text(
              'Haven van Antwerpen — België',
              style: pw.TextStyle(color: _colorTextLight, fontSize: 8),
            ),
            pw.Text(
              'Alle prijzen zijn exclusief BTW',
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
      padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 9),
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
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 9),
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
            isTbd ? 'Nader te bepalen' : '€ ${amount.toStringAsFixed(2)}',
            style: pw.TextStyle(
              color: color ?? _colorText,
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              fontStyle: isTbd ? pw.FontStyle.italic : pw.FontStyle.normal,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildZoneBadge(PortSide side) {
    final isRechts = side == PortSide.rechteroever;
    final color = isRechts ? PdfColor.fromHex('#2979FF') : PdfColor.fromHex('#F57C00');
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
    return 'ALT-$year$month$day-H$haven';
  }
}
