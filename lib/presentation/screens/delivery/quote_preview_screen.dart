import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/delivery_model.dart';
import '../../../data/services/quote_service.dart';

class QuotePreviewScreen extends StatefulWidget {
  final DeliveryModel delivery;
  final bool isInvoice;

  const QuotePreviewScreen({
    super.key,
    required this.delivery,
    this.isInvoice = false,
  });

  @override
  State<QuotePreviewScreen> createState() => _QuotePreviewScreenState();
}

class _QuotePreviewScreenState extends State<QuotePreviewScreen> {
  Uint8List? _pdfBytes;
  bool _isLoading = true;
  bool _isSharing = false;
  String? _error;

  // Aktif dil seçimi (PDF yeniden oluşturma için)
  late QuoteLanguage _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.delivery.quoteLanguage;
    _generatePdf();
  }

  Future<void> _generatePdf() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final Uint8List bytes;
      if (widget.isInvoice) {
        bytes = await QuoteService.generateInvoice(
          widget.delivery.copyWith(quoteLanguage: _selectedLanguage),
        );
      } else {
        bytes = await QuoteService.generateOfferte(
          widget.delivery,
          languageOverride: _selectedLanguage,
        );
      }
      if (mounted) {
        setState(() {
          _pdfBytes = bytes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'PDF oluşturulamadı: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _sharePdf() async {
    if (_pdfBytes == null) return;
    setState(() => _isSharing = true);
    try {
      final dir = await getTemporaryDirectory();
      final prefix = widget.isInvoice ? 'fatura' : 'offerte';
      final fileName =
          '${prefix}_haven${widget.delivery.havenNumber}_${widget.delivery.displayClientName.replaceAll(' ', '_')}.pdf';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(_pdfBytes!);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'application/pdf')],
          subject: widget.isInvoice
              ? 'Fatura — ${widget.delivery.displayClientName} — ${widget.delivery.invoiceNumber ?? ''}'
              : 'Offerte — ${widget.delivery.displayClientName} — Haven ${widget.delivery.havenNumber}',
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Paylaşım hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  Future<void> _printPdf() async {
    if (_pdfBytes == null) return;
    await Printing.layoutPdf(onLayout: (_) async => _pdfBytes!);
  }

  @override
  Widget build(BuildContext context) {
    final title =
        widget.isInvoice ? 'Fatura / Invoice' : 'Fiyat Teklifi — Offerte';

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.bgDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_pdfBytes != null) ...[
            IconButton(
              icon: const Icon(Icons.print_rounded),
              tooltip: 'Yazdır',
              onPressed: _printPdf,
            ),
            _isSharing
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.share_rounded),
                    tooltip: 'Paylaş',
                    onPressed: _sharePdf,
                  ),
          ],
        ],
      ),
      body: Column(
        children: [
          // ── Dil seçici (fatura değilse) ────────────────────────────────────
          if (!widget.isInvoice)
            _buildLanguageBar(),

          // ── PDF önizleme ───────────────────────────────────────────────────
          Expanded(child: _buildBody()),
        ],
      ),
      bottomNavigationBar: _pdfBytes != null ? _buildBottomBar() : null,
    );
  }

  Widget _buildLanguageBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: Border(bottom: BorderSide(color: AppColors.glassBorder)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PDF DİLİ',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: QuoteLanguage.values.map((lang) {
                final isSelected = _selectedLanguage == lang;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedLanguage = lang);
                      _generatePdf();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.glassBorder,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(lang.flag,
                              style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 5),
                          Text(
                            lang.label,
                            style: TextStyle(
                              color: isSelected
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: const CircularProgressIndicator(
                color: AppColors.accent,
              ),
            ).animate().scale(begin: const Offset(0.8, 0.8)),
            const SizedBox(height: 20),
            const Text(
              'PDF oluşturuluyor...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ).animate().fadeIn(delay: 300.ms),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _generatePdf,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      );
    }

    return PdfPreview(
      build: (_) async => _pdfBytes!,
      allowPrinting: true,
      allowSharing: true,
      canChangeOrientation: false,
      canChangePageFormat: false,
      canDebug: false,
      pdfPreviewPageDecoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      actions: const [],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: Border(top: BorderSide(color: AppColors.glassBorder)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _printPdf,
              icon: const Icon(Icons.print_rounded, size: 18),
              label: const Text('Yazdır'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 50),
                foregroundColor: AppColors.textPrimary,
                side: BorderSide(color: AppColors.glassBorder),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _isSharing ? null : _sharePdf,
              icon: _isSharing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Icon(
                      widget.isInvoice
                          ? Icons.send_rounded
                          : Icons.share_rounded,
                      size: 18),
              label: Text(_isSharing
                  ? 'Paylaşılıyor...'
                  : widget.isInvoice
                      ? 'Faturayı Paylaş'
                      : 'Teklifi Paylaş'),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.isInvoice
                    ? AppColors.success
                    : AppColors.accent,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 50),
              ),
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 1, end: 0, duration: 300.ms);
  }
}
