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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = ref.watch(appL10nProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.flash_on_rounded, color: AppColors.warning, size: 18),
            const SizedBox(width: 6),
            Text(l10n.quickQuoteTitle),
          ],
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
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
              child: Row(
                children: [
                  const Icon(Icons.flash_on_rounded,
                      color: AppColors.warning, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.quickQuoteBanner,
                      style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 12),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms),

            const SizedBox(height: 16),

            // Teklif Sahibi
            _buildCard(
              l10n.quickQuoteOwner,
              Icons.person_rounded,
              theme,
              isDark,
              [
                TextFormField(
                  controller: _ownerCtrl,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: l10n.quickQuoteOwnerLabel,
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    helperText: l10n.quickQuoteOwnerHelper,
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 80.ms).slideY(begin: 0.1),

            const SizedBox(height: 14),

            // Dil
            _buildCard(
              l10n.quickQuoteLanguage,
              Icons.translate_rounded,
              theme,
              isDark,
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
                                : isDark
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : Colors.black.withValues(alpha: 0.08),
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
                                    ? theme.colorScheme.onSurface
                                    : theme.colorScheme.onSurfaceVariant,
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
              l10n.quickQuoteTariffMode,
              Icons.calculate_rounded,
              theme,
              isDark,
              [
                Row(
                  children: [
                    for (final m in [
                      (TariffMode.havenBased, l10n.modeHaven, Icons.anchor_rounded),
                      (TariffMode.kmZone, l10n.modeKmZone, Icons.route_rounded),
                      (TariffMode.perKm, l10n.modePerKm, Icons.straighten_rounded),
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
                                      : isDark
                                          ? Colors.white.withValues(alpha: 0.1)
                                          : Colors.black.withValues(alpha: 0.08),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(m.$3,
                                      size: 18,
                                      color: _tariffMode == m.$1
                                          ? AppColors.primary
                                          : theme.colorScheme.onSurfaceVariant),
                                  const SizedBox(height: 4),
                                  Text(
                                    m.$2,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: _tariffMode == m.$1
                                          ? theme.colorScheme.onSurface
                                          : theme.colorScheme.onSurfaceVariant,
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
              l10n.quickQuoteHavenLocation,
              Icons.anchor_rounded,
              theme,
              isDark,
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
                                  : isDark
                                      ? Colors.white.withValues(alpha: 0.1)
                                      : Colors.black.withValues(alpha: 0.08),
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
                                      ? theme.colorScheme.onSurface
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                side.turkishName,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isSel
                                      ? theme.colorScheme.onSurfaceVariant
                                      : theme.colorScheme.onSurfaceVariant,
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
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    labelText: l10n.generalHavenNumber,
                    prefixIcon: const Icon(Icons.anchor_rounded),
                  ),
                  onChanged: (_) => _calculateTariff(),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return l10n.generalHavenRequired;
                    }
                    final n = int.tryParse(v);
                    if (n == null || !TariffService.isValidHaven(n)) {
                      return l10n.generalInvalidHaven;
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
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: l10n.generalDistance,
                      prefixIcon: const Icon(Icons.route_rounded),
                      suffixText: 'km',
                    ),
                    onChanged: (_) => _calculateTariff(),
                    validator: (v) {
                      if (_tariffMode != TariffMode.havenBased) {
                        if (v == null || v.isEmpty) {
                          return l10n.generalDistanceRequired;
                        }
                        final km = double.tryParse(v.replaceAll(',', '.'));
                        if (km == null || km <= 0) {
                          return l10n.generalInvalidKm;
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
              l10n.quickQuoteRoute,
              Icons.alt_route_rounded,
              theme,
              isDark,
              [
                _routeField(
                  controller: _pickupHavenCtrl,
                  label: l10n.generalPickupHaven,
                  icon: Icons.anchor_rounded,
                  color: AppColors.rechteroever,
                  theme: theme,
                ),
                const SizedBox(height: 8),
                _routeField(
                  controller: _deliveryAddressCtrl,
                  label: l10n.generalDeliveryAddress,
                  icon: Icons.location_on_rounded,
                  color: AppColors.accent,
                  theme: theme,
                ),
                const SizedBox(height: 8),
                _routeField(
                  controller: _returnHavenCtrl,
                  label: l10n.generalReturnHaven,
                  icon: Icons.anchor_rounded,
                  color: AppColors.success,
                  theme: theme,
                ),
              ],
            ).animate().fadeIn(delay: 240.ms).slideY(begin: 0.1),

            const SizedBox(height: 14),

            // TIR
            _buildCard(
              l10n.quickQuoteTruckModel,
              Icons.local_shipping_rounded,
              theme,
              isDark,
              [
                DropdownButtonFormField<TruckModel>(
                  value: _selectedTruck,
                  dropdownColor: theme.colorScheme.surface,
                  style: TextStyle(
                      color: theme.colorScheme.onSurface, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: l10n.generalSelectTruck,
                    prefixIcon: const Icon(Icons.local_shipping_rounded),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text(l10n.generalNone,
                          style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant)),
                    ),
                    ...TruckCatalog.models.map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(
                          '${t.fullName} (${t.fuelConsumptionPer100km} L/100km)',
                          style: TextStyle(
                              color: theme.colorScheme.onSurface),
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
              l10n.quickQuoteDiesel,
              Icons.local_gas_station_rounded,
              theme,
              isDark,
              [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _dieselPercentCtrl,
                        keyboardType:
                            const TextInputType.numberWithOptions(
                                decimal: true),
                        style: TextStyle(
                            color: theme.colorScheme.onSurface, fontSize: 18),
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
              label: Text(l10n.quickQuoteGenerate),
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

  Widget _buildCard(String title, IconData icon, ThemeData theme, bool isDark, List<Widget> children) {
    final cardBg = theme.colorScheme.surface;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.08);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
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
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurfaceVariant,
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
    required ThemeData theme,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 13),
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
