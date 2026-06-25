import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/locale_provider.dart';
import '../../../data/models/delivery_model.dart';
import '../../../data/models/tariff_zone_model.dart';
import '../../../data/models/truck_model.dart';
import '../../../data/services/tariff_service.dart';
import 'quote_preview_screen.dart';

/// Hızlı Teklif — Şirket bilgisi olmadan sadece tarife girerek hızlıca PDF oluşturur
class QuickQuoteScreen extends ConsumerStatefulWidget {
  const QuickQuoteScreen({super.key});

  @override
  ConsumerState<QuickQuoteScreen> createState() => _QuickQuoteScreenState();
}

class _QuickQuoteScreenState extends ConsumerState<QuickQuoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ownerCtrl = TextEditingController();
  final _havenCtrl = TextEditingController();
  final _pickupHavenCtrl = TextEditingController();
  final _deliveryAddressCtrl = TextEditingController();
  final _returnHavenCtrl = TextEditingController();
  final _distanceKmCtrl = TextEditingController();
  final _dieselPercentCtrl = TextEditingController(text: '0');

  PortSide _driverSide = PortSide.rechteroever;
  TariffMode _tariffMode = TariffMode.havenBased;
  // Profildeki varsayılan teklif dili ile başlar
  late QuoteLanguage _selectedLanguage;
  TruckModel? _selectedTruck;
  DeliveryTariff? _calculatedTariff;
  bool _isCalculating = false;
  bool _hasGenset = false;
  bool _isAdr = false;

  final _userTariff = UserTariff.defaultTariff();

  @override
  void initState() {
    super.initState();
    // Profildeki tercih edilen teklif dili ile başla
    _selectedLanguage = ref.read(quoteLanguageProvider);
  }

  @override
  void dispose() {
    _ownerCtrl.dispose();
    _havenCtrl.dispose();
    _pickupHavenCtrl.dispose();
    _deliveryAddressCtrl.dispose();
    _returnHavenCtrl.dispose();
    _distanceKmCtrl.dispose();
    _dieselPercentCtrl.dispose();
    super.dispose();
  }

  void _calculateTariff() {
    final havenText = _havenCtrl.text.trim();
    if (havenText.isEmpty) {
      setState(() => _calculatedTariff = null);
      return;
    }
    final havenNumber = int.tryParse(havenText);
    if (havenNumber == null || !TariffService.isValidHaven(havenNumber)) {
      setState(() => _calculatedTariff = null);
      return;
    }

    final dieselPercent =
        double.tryParse(_dieselPercentCtrl.text.replaceAll(',', '.')) ?? 0.0;

    setState(() => _isCalculating = true);

    Future.delayed(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      DeliveryTariff tariff;
      switch (_tariffMode) {
        case TariffMode.havenBased:
          tariff = TariffService.calculate(
            havenNumber: havenNumber,
            driverCurrentSide: _driverSide,
            hasGenset: _hasGenset,
            isAdr: _isAdr,
            dieselSurchargePercent: dieselPercent,
          );
          break;
        case TariffMode.kmZone:
          final km = double.tryParse(
                  _distanceKmCtrl.text.replaceAll(',', '.')) ??
              0;
          if (km <= 0) {
            setState(() {
              _calculatedTariff = null;
              _isCalculating = false;
            });
            return;
          }
          tariff = TariffService.calculateKmZone(
            havenNumber: havenNumber,
            driverCurrentSide: _driverSide,
            distanceKm: km,
            zones: _userTariff.kmZones,
            hasGenset: _hasGenset,
            isAdr: _isAdr,
            dieselSurchargePercent: dieselPercent,
          );
          break;
        case TariffMode.perKm:
          final km = double.tryParse(
                  _distanceKmCtrl.text.replaceAll(',', '.')) ??
              0;
          if (km <= 0) {
            setState(() {
              _calculatedTariff = null;
              _isCalculating = false;
            });
            return;
          }
          tariff = TariffService.calculatePerKm(
            havenNumber: havenNumber,
            driverCurrentSide: _driverSide,
            distanceKm: km,
            ratePerKm: _userTariff.perKmRate,
            minimumFee: _userTariff.minimumFee,
            hasGenset: _hasGenset,
            isAdr: _isAdr,
            dieselSurchargePercent: dieselPercent,
          );
          break;
      }
      setState(() {
        _calculatedTariff = tariff;
        _isCalculating = false;
      });
    });
  }

  void _generateQuote() {
    if (!_formKey.currentState!.validate()) return;
    if (_calculatedTariff == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Lütfen önce tarife hesaplayın')),
      );
      return;
    }

    final dieselPercent =
        double.tryParse(_dieselPercentCtrl.text.replaceAll(',', '.')) ?? 0.0;
    final distanceKm =
        double.tryParse(_distanceKmCtrl.text.replaceAll(',', '.'));

    double? estimatedFuel;
    if (_selectedTruck != null && distanceKm != null && distanceKm > 0) {
      estimatedFuel = _selectedTruck!.estimatedFuelLiters(distanceKm);
    }

    final havenNumber = int.parse(_havenCtrl.text.trim());
    final delivery = DeliveryModel(
      companyName: 'Anonim',
      quoteOwnerName: _ownerCtrl.text.trim().isNotEmpty
          ? _ownerCtrl.text.trim()
          : null,
      havenNumber: havenNumber,
      destinationSide: _calculatedTariff!.destinationSide,
      driverSideAtDelivery: _driverSide,
      tunnelUsed: _calculatedTariff!.needsTunnel,
      havenFee: _calculatedTariff!.baseFee,
      tunnelFee: _calculatedTariff!.tunnelFee,
      hasGenset: _hasGenset,
      gensetFee: _calculatedTariff!.gensetFee,
      isAdr: _isAdr,
      adrFee: _calculatedTariff!.adrFee,
      dieselSurchargePercent: dieselPercent,
      dieselSurchargeFee: _calculatedTariff!.dieselSurchargeFee,
      tariffMode: _tariffMode,
      distanceKm: distanceKm,
      pickupHaven: _pickupHavenCtrl.text.trim().isNotEmpty
          ? _pickupHavenCtrl.text.trim()
          : null,
      deliveryAddress: _deliveryAddressCtrl.text.trim().isNotEmpty
          ? _deliveryAddressCtrl.text.trim()
          : null,
      returnHaven: _returnHavenCtrl.text.trim().isNotEmpty
          ? _returnHavenCtrl.text.trim()
          : null,
      truckModelId: _selectedTruck?.id,
      truckModelName: _selectedTruck?.fullName,
      estimatedFuelLiters: estimatedFuel,
      totalFee: _calculatedTariff!.total,
      estimatedMinutes: _calculatedTariff!.estimatedMinutes,
      createdAt: DateTime.now(),
      driverId: 'current_user',
      quoteLanguage: _selectedLanguage,
      isQuickQuote: true,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuotePreviewScreen(delivery: delivery),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.flash_on_rounded, color: AppColors.warning, size: 18),
            SizedBox(width: 6),
            Text('Hızlı Teklif'),
          ],
        ),
        backgroundColor: AppColors.bgDark,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Info Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.flash_on_rounded,
                      color: AppColors.warning, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Hızlı Teklif: Şirket adı girmeden, sadece tarife ve adres bilgisiyle anında PDF oluşturur.',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms),

            const SizedBox(height: 16),

            // Teklif Sahibi
            _buildCard(
              'TEKLİF SAHİBİ',
              Icons.person_rounded,
              [
                TextFormField(
                  controller: _ownerCtrl,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'İsim / Referans (Opsiyonel)',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                    helperText: 'PDF\'de müşteri adı olarak görünür',
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 80.ms).slideY(begin: 0.1),

            const SizedBox(height: 14),

            // Dil
            _buildCard(
              'TEKLİF DİLİ',
              Icons.translate_rounded,
              [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: QuoteLanguage.values.map((lang) {
                    final isSel = _selectedLanguage == lang;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedLanguage = lang),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: isSel
                              ? AppColors.primary.withValues(alpha: 0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSel
                                ? AppColors.primary
                                : AppColors.glassBorder,
                            width: isSel ? 1.5 : 1,
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
                                color: isSel
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: isSel
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ).animate().fadeIn(delay: 120.ms).slideY(begin: 0.1),

            const SizedBox(height: 14),

            // Tarife Modu
            _buildCard(
              'TARİFE MODU',
              Icons.calculate_rounded,
              [
                Row(
                  children: [
                    for (final m in [
                      (TariffMode.havenBased, 'Haven', Icons.anchor_rounded),
                      (TariffMode.kmZone, 'Km Aralık', Icons.route_rounded),
                      (TariffMode.perKm, 'Km Başı', Icons.straighten_rounded),
                    ])
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: m.$1 != TariffMode.perKm ? 6 : 0,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _tariffMode = m.$1);
                              _calculateTariff();
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 10),
                              decoration: BoxDecoration(
                                color: _tariffMode == m.$1
                                    ? AppColors.primary.withValues(alpha: 0.15)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _tariffMode == m.$1
                                      ? AppColors.primary
                                      : AppColors.glassBorder,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(m.$3,
                                      size: 18,
                                      color: _tariffMode == m.$1
                                          ? AppColors.primary
                                          : AppColors.textMuted),
                                  const SizedBox(height: 4),
                                  Text(
                                    m.$2,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: _tariffMode == m.$1
                                          ? AppColors.textPrimary
                                          : AppColors.textMuted,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ).animate().fadeIn(delay: 160.ms).slideY(begin: 0.1),

            const SizedBox(height: 14),

            // Haven + Konum + Mesafe
            _buildCard(
              'HEDEF HAVEN & KONUM',
              Icons.anchor_rounded,
              [
                // Kıyı Seçici
                Row(
                  children: PortSide.values.map((side) {
                    final isSel = _driverSide == side;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _driverSide = side);
                          _calculateTariff();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: EdgeInsets.only(
                              right:
                                  side == PortSide.rechteroever ? 8 : 0),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 8),
                          decoration: BoxDecoration(
                            color: isSel
                                ? (side == PortSide.rechteroever
                                        ? AppColors.rechteroever
                                        : AppColors.linkeroever)
                                    .withValues(alpha: 0.15)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSel
                                  ? (side == PortSide.rechteroever
                                      ? AppColors.rechteroever
                                      : AppColors.linkeroever)
                                  : AppColors.glassBorder,
                              width: isSel ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                side.dutchName,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSel
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                side.turkishName,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isSel
                                      ? AppColors.textSecondary
                                      : AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _havenCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Haven Numarası (1-2000)',
                    prefixIcon: Icon(Icons.anchor_rounded),
                  ),
                  onChanged: (_) => _calculateTariff(),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Haven numarası zorunludur';
                    }
                    final n = int.tryParse(v);
                    if (n == null || !TariffService.isValidHaven(n)) {
                      return 'Geçersiz haven';
                    }
                    return null;
                  },
                ),
                if (_tariffMode != TariffMode.havenBased) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _distanceKmCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Mesafe (km)',
                      prefixIcon: Icon(Icons.route_rounded),
                      suffixText: 'km',
                    ),
                    onChanged: (_) => _calculateTariff(),
                    validator: (v) {
                      if (_tariffMode != TariffMode.havenBased) {
                        if (v == null || v.isEmpty) {
                          return 'Mesafe zorunludur';
                        }
                        final km = double.tryParse(v.replaceAll(',', '.'));
                        if (km == null || km <= 0) {
                          return 'Geçerli km girin';
                        }
                      }
                      return null;
                    },
                  ),
                ],
                if (_isCalculating)
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: LinearProgressIndicator(),
                  ),
                if (_calculatedTariff != null && !_isCalculating) ...[
                  const SizedBox(height: 14),
                  _QuickTariffSummary(tariff: _calculatedTariff!),
                ],
              ],
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

            const SizedBox(height: 14),

            // Güzergah
            _buildCard(
              'GÜZERGAH (Opsiyonel)',
              Icons.alt_route_rounded,
              [
                _routeField(
                  controller: _pickupHavenCtrl,
                  label: 'Konşimentoya Alınacak Liman',
                  icon: Icons.anchor_rounded,
                  color: AppColors.rechteroever,
                ),
                const SizedBox(height: 8),
                _routeField(
                  controller: _deliveryAddressCtrl,
                  label: 'Boşaltma / Yükleme Adresi',
                  icon: Icons.location_on_rounded,
                  color: AppColors.accent,
                ),
                const SizedBox(height: 8),
                _routeField(
                  controller: _returnHavenCtrl,
                  label: 'Geri Verilecek Liman',
                  icon: Icons.anchor_rounded,
                  color: AppColors.success,
                ),
              ],
            ).animate().fadeIn(delay: 240.ms).slideY(begin: 0.1),

            const SizedBox(height: 14),

            // TIR
            _buildCard(
              'TIR MODELİ (Opsiyonel)',
              Icons.local_shipping_rounded,
              [
                DropdownButtonFormField<TruckModel>(
                  value: _selectedTruck,
                  dropdownColor: AppColors.bgCard,
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 13),
                  decoration: const InputDecoration(
                    labelText: 'TIR Modeli Seçin',
                    prefixIcon: Icon(Icons.local_shipping_rounded),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('— Seçilmedi —',
                          style: TextStyle(color: AppColors.textMuted)),
                    ),
                    ...TruckCatalog.models.map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(
                          '${t.fullName} (${t.fuelConsumptionPer100km} L/100km)',
                          style: const TextStyle(
                              color: AppColors.textPrimary),
                        ),
                      ),
                    ),
                  ],
                  onChanged: (t) {
                    setState(() => _selectedTruck = t);
                    _calculateTariff();
                  },
                ),
              ],
            ).animate().fadeIn(delay: 280.ms).slideY(begin: 0.1),

            const SizedBox(height: 14),

            // Dizel
            _buildCard(
              'DİZEL TOESLAG (Opsiyonel)',
              Icons.local_gas_station_rounded,
              [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _dieselPercentCtrl,
                        keyboardType:
                            const TextInputType.numberWithOptions(
                                decimal: true),
                        style: const TextStyle(
                            color: AppColors.textPrimary, fontSize: 18),
                        decoration: const InputDecoration(
                          labelText: 'Dizel Toeslag %',
                          prefixIcon: Icon(
                              Icons.local_gas_station_rounded,
                              color: AppColors.warning),
                          suffixText: '%',
                        ),
                        onChanged: (_) => _calculateTariff(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      children: [
                        for (final pct in [5.0, 8.0, 10.0])
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: GestureDetector(
                              onTap: () {
                                _dieselPercentCtrl.text =
                                    pct.toStringAsFixed(0);
                                _calculateTariff();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.warning
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: AppColors.warning
                                        .withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  '%${pct.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    color: AppColors.warning,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ).animate().fadeIn(delay: 320.ms).slideY(begin: 0.1),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: _generateQuote,
              icon: const Icon(Icons.picture_as_pdf_rounded),
              label: const Text('PDF Teklif Oluştur'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                foregroundColor: Colors.black87,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ).animate().fadeIn(delay: 360.ms),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, IconData icon, List<Widget> children) {
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
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.warning),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _routeField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: color, size: 18),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}

class _QuickTariffSummary extends StatelessWidget {
  final DeliveryTariff tariff;
  const _QuickTariffSummary({required this.tariff});

  @override
  Widget build(BuildContext context) {
    final sideColor = tariff.destinationSide == PortSide.rechteroever
        ? AppColors.rechteroever
        : AppColors.linkeroever;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            sideColor.withValues(alpha: 0.1),
            AppColors.bgCardLight,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: sideColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Haven ${tariff.havenNumber} — ${tariff.destinationSide.dutchName}',
                style: TextStyle(
                  color: sideColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              if (tariff.needsTunnel)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.tunnel.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                        color: AppColors.tunnel.withValues(alpha: 0.3)),
                  ),
                  child: const Text(
                    '⚠ Tünel',
                    style: TextStyle(
                      color: AppColors.tunnel,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const Divider(height: 16, color: AppColors.bgCardLight),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TOPLAM',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              Text(
                tariff.formattedTotal,
                style: const TextStyle(
                  color: AppColors.success,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.95, 0.95));
  }
}
