import 'package:intl/intl.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/delivery_model.dart';

/// Teklif → Fatura dönüşüm servisi
class InvoiceService {
  InvoiceService._();

  static final _invoiceFormat = DateFormat('yyyyMMdd');

  /// Fatura numarası üretir: FAC-YYYYMMDD-XXXX
  static String generateInvoiceNumber(DeliveryModel delivery) {
    final dateStr = _invoiceFormat.format(DateTime.now());
    final haven = delivery.havenNumber.toString().padLeft(4, '0');
    return 'FAC-$dateStr-H$haven';
  }

  /// Teklifi faturaya dönüştürür (vade tarihi + fatura numarası atar)
  static DeliveryModel convertToInvoice(DeliveryModel delivery) {
    final now = DateTime.now();
    final dueDate = now.add(
      const Duration(days: AppConstants.invoiceDueDays),
    );
    final invoiceNum = generateInvoiceNumber(delivery);

    return delivery.copyWith(
      quoteStatus: QuoteStatus.invoiced,
      invoiceDate: now,
      invoiceDueDate: dueDate,
      invoiceNumber: invoiceNum,
      status: DeliveryStatus.completed,
    );
  }

  /// Teklifi "kabul edildi" olarak işaretler
  static DeliveryModel markAsAccepted(DeliveryModel delivery) {
    return delivery.copyWith(
      quoteStatus: QuoteStatus.accepted,
    );
  }

  /// Fatura özet metni (UI için)
  static String invoiceSummary(DeliveryModel delivery) {
    if (delivery.invoiceNumber == null) return '';
    final dateStr = DateFormat('dd.MM.yyyy').format(delivery.invoiceDate!);
    final dueStr = DateFormat('dd.MM.yyyy').format(delivery.invoiceDueDate!);
    return '${delivery.invoiceNumber} | $dateStr → $dueStr';
  }

  /// Kalan gün sayısı (vade tarihine)
  static int daysUntilDue(DeliveryModel delivery) {
    if (delivery.invoiceDueDate == null) return 0;
    return delivery.invoiceDueDate!.difference(DateTime.now()).inDays;
  }

  /// Vadesi geçmiş mi?
  static bool isOverdue(DeliveryModel delivery) {
    if (delivery.invoiceDueDate == null) return false;
    return DateTime.now().isAfter(delivery.invoiceDueDate!);
  }
}
