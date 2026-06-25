import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/locale_provider.dart';
import '../../../data/services/tariff_service.dart';
import '../../../data/models/delivery_model.dart';
import '../../../data/models/tariff_zone_model.dart';
import '../../../data/models/truck_model.dart';

class NewDeliveryScreen extends ConsumerStatefulWidget {
  const NewDeliveryScreen({super.key});

  @override
  ConsumerState<NewDeliveryScreen> createState() => _NewDeliveryScreenState();
}

class _NewDeliveryScreenState extends ConsumerState<NewDeliveryScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _companyCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _havenCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  // Güzergah
  final _pickupHavenCtrl = TextEditingController();
  final _deliveryAddressCtrl = TextEditingController();
  final _returnHavenCtrl = TextEditingController();

  // Km bazlı tarife
  final _distanceKmCtrl = TextEditingController();

  // Dizel toeslag
  final _dieselPercentCtrl = TextEditingController(text: '0');

  PortSide _driverSide = PortSide.rechteroever;
  DeliveryTariff? _calculatedTariff;
  bool _isCalculating = false;
  bool _hasGenset = false;
  bool _isAdr = false;

  // Tarife modu
  TariffMode _tariffMode = TariffMode.havenBased;

  // Dil seçimi - profildeki varsayılan dil ile başlar
  late QuoteLanguage _selectedLanguage;

  // TIR modeli
  TruckModel? _selectedTruck;

  // Kullanıcı tarifesi (varsayılan)
  final _userTariff = UserTariff.defaultTariff();

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Profildeki tercih edilen teklif dili ile başla
    _selectedLanguage = ref.read(quoteLanguageProvider);
  }

  @override
  void dispose() {
    _companyCtrl.dispose();
    _contactCtrl.dispose();
    _havenCtrl.dispose();
    _notesCtrl.dispose();
    _pickupHavenCtrl.dispose();
    _deliveryAddressCtrl.dispose();
    _returnHavenCtrl.dispose();
    _distanceKmCtrl.dispose();
    _dieselPercentCtrl.dispose();
    _tabController.dispose();
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
          final km =
              double.tryParse(_distanceKmCtrl.text.replaceAll(',', '.')) ?? 0;
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
          final km =
              double.tryParse(_distanceKmCtrl.text.replaceAll(',', '.')) ?? 0;
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

  void _createDelivery() {
    if (!_formKey.currentState!.validate()) return;
    if (_calculatedTariff == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Lütfen geçerli bir haven numarası ve mesafe girin')),
      );
      return;
    }

    final dieselPercent =
        double.tryParse(_dieselPercentCtrl.text.replaceAll(',', '.')) ?? 0.0;
    final distanceKm =
        double.tryParse(_distanceKmCtrl.text.replaceAll(',', '.'));

    // TIR yakıt hesabı
    double? estimatedFuel;
    if (_selectedTruck != null && distanceKm != null && distanceKm > 0) {
      estimatedFuel = _selectedTruck!.estimatedFuelLiters(distanceKm);
    }

    final delivery = DeliveryModel.fromTariff(
      companyName: _companyCtrl.text.trim().isEmpty
          ? 'Anonim'
          : _companyCtrl.text.trim(),
      havenNumber: int.parse(_havenCtrl.text.trim()),
      driverSide: _driverSide,
      tariff: _calculatedTariff!,
      driverId: 'current_user',
      contactPerson: _contactCtrl.text.trim().isNotEmpty
          ? _contactCtrl.text.trim()
          : null,
      notes: _notesCtrl.text.trim().isNotEmpty
          ? _notesCtrl.text.trim()
          : null,
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
      quoteLanguage: _selectedLanguage,
    );

    context.push(AppRoutes.deliverySummary, extra: delivery);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('Yeni Teslimat / Teklif'),
        backgroundColor: AppColors.bgDark,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          // Hızlı Teklif kısayol butonu
          TextButton.icon(
            onPressed: () => context.push(AppRoutes.quickQuote),
            icon: const Icon(Icons.flash_on_rounded,
                size: 16, color: AppColors.warning),
            label: const Text(
              'Hızlı',
              style: TextStyle(color: AppColors.warning, fontSize: 12),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Firma Bilgileri ──────────────────────────────────────────────
            _buildSection(
              'FİRMA BİLGİLERİ',
              Icons.business_rounded,
              [
                TextFormField(
                  controller: _companyCtrl,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Firma Adı',
                    prefixIcon: Icon(Icons.business_outlined),
                    helperText: 'Boş bırakırsanız "Anonim" olarak kaydedilir',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _contactCtrl,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'İletişim Kişisi (Opsiyonel)',
                    prefixIcon: Icon(Icons.person_outlined),
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 14),

            // ── Mevcut Konum ─────────────────────────────────────────────────
            _buildSection(
              'MEVCUT KONUMUM',
              Icons.my_location_rounded,
              [_buildSideSelector()],
            ).animate().fadeIn(delay: 80.ms, duration: 400.ms).slideY(begin: 0.1),

            const SizedBox(height: 14),

            // ── Tarife Modu ──────────────────────────────────────────────────
            _buildSection(
              'TARİFE MODU',
              Icons.calculate_rounded,
              [_buildTariffModeSelector()],
            ).animate().fadeIn(delay: 120.ms, duration: 400.ms).slideY(begin: 0.1),

            const SizedBox(height: 14),

            // ── Haven / Mesafe ───────────────────────────────────────────────
            _buildSection(
              _tariffMode == TariffMode.havenBased
                  ? 'HEDEF HAVEN'
                  : 'HAVEN & MESAFE',
              Icons.anchor_rounded,
              [
                TextFormField(
                  controller: _havenCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Haven Numarası (1-2000)',
                    prefixIcon: const Icon(Icons.anchor_rounded),
                    suffixText:
                        _calculatedTariff?.destinationSide.dutchName,
                    suffixStyle: TextStyle(
                      color: _calculatedTariff?.destinationSide ==
                              PortSide.rechteroever
                          ? AppColors.rechteroever
                          : AppColors.linkeroever,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  onChanged: (_) => _calculateTariff(),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Haven numarası zorunludur';
                    }
                    final num = int.tryParse(v);
                    if (num == null || !TariffService.isValidHaven(num)) {
                      return 'Geçersiz haven (1-2000 arası)';
                    }
                    return null;
                  },
                ),
                // Km alanı (haven bazlı değilse)
                if (_tariffMode != TariffMode.havenBased) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _distanceKmCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Mesafe (km)',
                      prefixIcon: const Icon(Icons.route_rounded),
                      suffixText: 'km',
                      helperText: _tariffMode == TariffMode.kmZone
                          ? _getZoneHelperText()
                          : '${_userTariff.perKmRate.toStringAsFixed(2)} €/km  |  min. ${_userTariff.minimumFee.toStringAsFixed(0)} €',
                    ),
                    onChanged: (_) => _calculateTariff(),
                    validator: (v) {
                      if (_tariffMode != TariffMode.havenBased) {
                        if (v == null || v.isEmpty) return 'Mesafe zorunludur';
                        final km =
                            double.tryParse(v.replaceAll(',', '.'));
                        if (km == null || km <= 0) return 'Geçerli bir km girin';
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
                  const SizedBox(height: 16),
                  _TariffPreviewCard(tariff: _calculatedTariff!),
                ],
              ],
            ).animate().fadeIn(delay: 160.ms, duration: 400.ms).slideY(begin: 0.1),

            const SizedBox(height: 14),

            // ── Güzergah ─────────────────────────────────────────────────────
            _buildSection(
              'GÜZERGAH',
              Icons.alt_route_rounded,
              [
                _routeField(
                  controller: _pickupHavenCtrl,
                  label: 'Konşimentoya Alınacak Liman',
                  icon: Icons.anchor_rounded,
                  color: AppColors.rechteroever,
                  hint: 'örn. Haven 1700 / Delwaidedok',
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Icon(Icons.arrow_downward_rounded,
                      size: 16, color: AppColors.textMuted),
                ),
                const SizedBox(height: 4),
                _routeField(
                  controller: _deliveryAddressCtrl,
                  label: 'Boşaltma / Yükleme Adresi',
                  icon: Icons.location_on_rounded,
                  color: AppColors.accent,
                  hint: 'örn. Industrieweg 42, Gent',
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Icon(Icons.arrow_downward_rounded,
                      size: 16, color: AppColors.textMuted),
                ),
                const SizedBox(height: 4),
                _routeField(
                  controller: _returnHavenCtrl,
                  label: 'Geri Verilecek Liman',
                  icon: Icons.anchor_rounded,
                  color: AppColors.success,
                  hint: 'örn. Haven 1700 / Delwaidedok',
                ),
              ],
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1),

            const SizedBox(height: 14),

            // ── TIR Modeli ───────────────────────────────────────────────────
            _buildSection(
              'TIR MODELİ',
              Icons.local_shipping_rounded,
              [_buildTruckSelector()],
            ).animate().fadeIn(delay: 240.ms, duration: 400.ms).slideY(begin: 0.1),

            const SizedBox(height: 14),

            // ── Konteyner Özellikleri ────────────────────────────────────────
            _buildSection(
              'KONTEYNER ÖZELLİKLERİ',
              Icons.widgets_rounded,
              [
                _ContainerOptionTile(
                  icon: Icons.electrical_services_rounded,
                  iconColor: const Color(0xFF00BCD4),
                  title: 'Genset',
                  subtitle: 'Motorlu şase / Reefer konteyner',
                  dutchLabel: 'Genset (motor/chassis)',
                  fee: AppConstants.gensetFee,
                  isEnabled: _hasGenset,
                  onToggle: (val) {
                    setState(() => _hasGenset = val);
                    _calculateTariff();
                  },
                ),
                const SizedBox(height: 12),
                Divider(color: AppColors.glassBorder, height: 1),
                const SizedBox(height: 12),
                _ContainerOptionTile(
                  icon: Icons.warning_amber_rounded,
                  iconColor: const Color(0xFFFF6B35),
                  title: 'ADR',
                  subtitle: 'Tehlikeli madde / Patlayıcı',
                  dutchLabel: 'ADR (gevaarlijke stoffen)',
                  fee: AppConstants.adrFee,
                  isEnabled: _isAdr,
                  onToggle: (val) {
                    setState(() => _isAdr = val);
                    _calculateTariff();
                  },
                ),
              ],
            ).animate().fadeIn(delay: 280.ms, duration: 400.ms).slideY(begin: 0.1),

            const SizedBox(height: 14),

            // ── Dizel Toeslag ────────────────────────────────────────────────
            _buildSection(
              'DİZEL TOESLAG',
              Icons.local_gas_station_rounded,
              [_buildDieselSection()],
            ).animate().fadeIn(delay: 320.ms, duration: 400.ms).slideY(begin: 0.1),

            const SizedBox(height: 14),

            // ── Teklif Dili ──────────────────────────────────────────────────
            _buildSection(
              'TEKLİF DİLİ',
              Icons.translate_rounded,
              [_buildLanguageSelector()],
            ).animate().fadeIn(delay: 360.ms, duration: 400.ms).slideY(begin: 0.1),

            const SizedBox(height: 14),

            // ── Notlar ───────────────────────────────────────────────────────
            _buildSection(
              'NOTLAR',
              Icons.notes_rounded,
              [
                TextFormField(
                  controller: _notesCtrl,
                  style: const TextStyle(color: AppColors.textPrimary),
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Ek notlar (Opsiyonel)',
                    prefixIcon: Icon(Icons.notes_rounded),
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 400.ms, duration: 400.ms).slideY(begin: 0.1),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: _createDelivery,
              icon: const Icon(Icons.check_rounded),
              label: const Text('Teslimat / Teklif Oluştur'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ).animate().fadeIn(delay: 450.ms, duration: 400.ms),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── Kıyı Seçici ────────────────────────────────────────────────────────────
  Widget _buildSideSelector() {
    return Row(
      children: PortSide.values
          .map((side) => Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _driverSide = side);
                    _calculateTariff();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(
                        right: side == PortSide.rechteroever ? 8 : 0),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      color: _driverSide == side
                          ? (side == PortSide.rechteroever
                                  ? AppColors.rechteroever
                                  : AppColors.linkeroever)
                              .withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _driverSide == side
                            ? (side == PortSide.rechteroever
                                ? AppColors.rechteroever
                                : AppColors.linkeroever)
                            : AppColors.glassBorder,
                        width: _driverSide == side ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          side == PortSide.rechteroever
                              ? Icons.arrow_forward_rounded
                              : Icons.arrow_back_rounded,
                          size: 16,
                          color: _driverSide == side
                              ? (side == PortSide.rechteroever
                                  ? AppColors.rechteroever
                                  : AppColors.linkeroever)
                              : AppColors.textMuted,
                        ),
                        const SizedBox(width: 6),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              side.dutchName,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _driverSide == side
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              side.turkishName,
                              style: TextStyle(
                                fontSize: 10,
                                color: _driverSide == side
                                    ? AppColors.textSecondary
                                    : AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }

  // ── Tarife Modu Seçici ─────────────────────────────────────────────────────
  Widget _buildTariffModeSelector() {
    final modes = [
      (TariffMode.havenBased, 'Haven Bazlı', Icons.anchor_rounded),
      (TariffMode.kmZone, 'Km Aralık', Icons.route_rounded),
      (TariffMode.perKm, 'Km Başı', Icons.straighten_rounded),
    ];
    return Row(
      children: modes
          .map((m) => Expanded(
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
                          width: _tariffMode == m.$1 ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            m.$3,
                            size: 18,
                            color: _tariffMode == m.$1
                                ? AppColors.primary
                                : AppColors.textMuted,
                          ),
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
              ))
          .toList(),
    );
  }

  // ── TIR Seçici ─────────────────────────────────────────────────────────────
  Widget _buildTruckSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<TruckModel>(
          value: _selectedTruck,
          dropdownColor: AppColors.bgCard,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: const InputDecoration(
            labelText: 'TIR Modeli Seçin',
            prefixIcon:
                Icon(Icons.local_shipping_rounded),
            helperText: 'Seçilirse tahmini yakıt tüketimi hesaplanır',
          ),
          items: [
            const DropdownMenuItem(
              value: null,
              child: Text('— Seçilmedi —',
                  style: TextStyle(color: AppColors.textMuted)),
            ),
            ...TruckCatalog.models.map(
              (truck) => DropdownMenuItem(
                value: truck,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      truck.fullName,
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${truck.fuelConsumptionPer100km} L/100km · ${truck.axleConfig}',
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          ],
          onChanged: (truck) {
            setState(() => _selectedTruck = truck);
            _calculateTariff();
          },
        ),
        if (_selectedTruck != null) ...[
          const SizedBox(height: 10),
          _buildTruckInfoCard(_selectedTruck!),
        ],
      ],
    );
  }

  Widget _buildTruckInfoCard(TruckModel truck) {
    final distanceKm =
        double.tryParse(_distanceKmCtrl.text.replaceAll(',', '.')) ?? 0;
    final estimatedFuel =
        distanceKm > 0 ? truck.estimatedFuelLiters(distanceKm) : null;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2236),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.local_shipping_rounded,
                color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  truck.displayName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Tank: ${truck.tankCapacityLiters.toStringAsFixed(0)} L  |  Tüketim: ${truck.fuelConsumptionPer100km} L/100km',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 11),
                ),
                if (estimatedFuel != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Tahmini Yakıt: ${estimatedFuel.toStringAsFixed(1)} L',
                    style: const TextStyle(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                        fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Dizel Toeslag ──────────────────────────────────────────────────────────
  Widget _buildDieselSection() {
    final hasDiesel =
        (double.tryParse(_dieselPercentCtrl.text.replaceAll(',', '.')) ?? 0) >
            0;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _dieselPercentCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  labelText: 'Dizel Toeslag Yüzdesi (%)',
                  prefixIcon: const Icon(Icons.local_gas_station_rounded,
                      color: AppColors.warning),
                  suffixText: '%',
                  helperText:
                      'Ör: Dizel 300€ ise +%8 = 24€ Brandstoftoeslag',
                  helperStyle:
                      const TextStyle(color: AppColors.textMuted, fontSize: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: hasDiesel
                            ? AppColors.warning
                            : AppColors.glassBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: hasDiesel
                            ? AppColors.warning.withValues(alpha: 0.5)
                            : AppColors.glassBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppColors.warning, width: 1.5),
                  ),
                ),
                onChanged: (_) => _calculateTariff(),
              ),
            ),
            const SizedBox(width: 10),
            // Hızlı seçim butonları
            Column(
              children: [
                for (final pct in [5.0, 8.0, 10.0])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: GestureDetector(
                      onTap: () {
                        _dieselPercentCtrl.text = pct.toStringAsFixed(0);
                        _calculateTariff();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: AppColors.warning.withValues(alpha: 0.3)),
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
        if (hasDiesel && _calculatedTariff != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border:
                  Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '⛽ Brandstoftoeslag',
                  style: TextStyle(
                      color: AppColors.warning,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
                Text(
                  '+${_calculatedTariff!.dieselSurchargeFee.toStringAsFixed(2)} €',
                  style: const TextStyle(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ── Dil Seçici ─────────────────────────────────────────────────────────────
  Widget _buildLanguageSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: QuoteLanguage.values.map((lang) {
        final isSelected = _selectedLanguage == lang;
        return GestureDetector(
          onTap: () => setState(() => _selectedLanguage = lang),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.glassBorder,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(lang.flag, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  lang.label,
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Güzergah TextField ────────────────────────────────────────────────────
  Widget _routeField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color color,
    required String hint,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 11),
        prefixIcon: Icon(icon, color: color, size: 18),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }

  // ── Zone Yardım Metni ──────────────────────────────────────────────────────
  String _getZoneHelperText() {
    final zones = _userTariff.kmZones;
    if (zones.isEmpty) return '';
    final parts = zones.take(3).map((z) => '${z.label}: ${z.fixedFee.toStringAsFixed(0)}€').join('  ');
    return parts;
  }

  // ── Section Builder ────────────────────────────────────────────────────────
  Widget _buildSection(String title, IconData icon, List<Widget> children) {
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
              Icon(icon, size: 16, color: AppColors.accent),
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
}

// ─── Konteyner Seçenek Kartı ─────────────────────────────────────────────────
class _ContainerOptionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String dutchLabel;
  final double fee;
  final bool isEnabled;
  final ValueChanged<bool> onToggle;

  const _ContainerOptionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.dutchLabel,
    required this.fee,
    required this.isEnabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isEnabled
            ? iconColor.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEnabled
              ? iconColor.withValues(alpha: 0.4)
              : AppColors.glassBorder,
          width: isEnabled ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isEnabled
                  ? iconColor.withValues(alpha: 0.15)
                  : AppColors.bgCardLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isEnabled ? iconColor : AppColors.textMuted,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isEnabled
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isEnabled
                            ? iconColor.withValues(alpha: 0.15)
                            : AppColors.bgCardLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        fee > 0 ? '+${fee.toStringAsFixed(2)} €' : 'Fiyat TBD',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isEnabled ? iconColor : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textMuted),
                ),
                Text(
                  dutchLabel,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted.withValues(alpha: 0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: onToggle,
            activeThumbColor: iconColor,
            trackColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return iconColor.withValues(alpha: 0.3);
              }
              return AppColors.bgCardLight;
            }),
          ),
        ],
      ),
    );
  }
}

// ─── Tarife Önizleme Kartı ───────────────────────────────────────────────────
class _TariffPreviewCard extends StatelessWidget {
  final DeliveryTariff tariff;
  const _TariffPreviewCard({required this.tariff});

  @override
  Widget build(BuildContext context) {
    final sideColor = tariff.destinationSide == PortSide.rechteroever
        ? AppColors.rechteroever
        : AppColors.linkeroever;

    // Baz ücret etiketini belirle
    String baseFeeLabel;
    if (tariff.mode == TariffMode.havenBased) {
      baseFeeLabel = 'Haven Ücreti';
    } else if (tariff.mode == TariffMode.kmZone) {
      final km = tariff.distanceKm?.toStringAsFixed(0) ?? '?';
      baseFeeLabel = 'Km Aralık ($km km)';
    } else {
      final km = tariff.distanceKm?.toStringAsFixed(0) ?? '?';
      baseFeeLabel = 'Km Başı ($km km)';
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            sideColor.withValues(alpha: 0.1),
            AppColors.bgCardLight,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: sideColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.anchor_rounded, size: 14, color: sideColor),
                  const SizedBox(width: 6),
                  Text(
                    'Haven ${tariff.havenNumber} — ${tariff.destinationSide.dutchName}',
                    style: TextStyle(
                        color: sideColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13),
                  ),
                ],
              ),
              if (tariff.estimatedMinutes != null)
                Row(
                  children: [
                    const Icon(Icons.timer_outlined,
                        size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '~${tariff.estimatedMinutes} dk',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: AppColors.bgCardLight),
          const SizedBox(height: 8),
          _FeeRow(
            label: baseFeeLabel,
            value: '${tariff.baseFee.toStringAsFixed(2)} €',
            color: AppColors.textPrimary,
          ),
          if (tariff.needsTunnel) ...[
            const SizedBox(height: 6),
            _FeeRow(
              label: 'Tünel Ücreti (Kennedy)',
              value: tariff.formattedTunnelFee,
              color: AppColors.tunnel,
              icon: Icons.alt_route,
            ),
          ],
          if (tariff.hasGenset) ...[
            const SizedBox(height: 6),
            _FeeRow(
              label: 'Genset Ücreti',
              value: tariff.gensetFee > 0 ? tariff.formattedGensetFee : 'TBD',
              color: const Color(0xFF00BCD4),
              icon: Icons.electrical_services_rounded,
            ),
          ],
          if (tariff.isAdr) ...[
            const SizedBox(height: 6),
            _FeeRow(
              label: 'ADR Ücreti',
              value: tariff.adrFee > 0 ? tariff.formattedAdrFee : 'TBD',
              color: const Color(0xFFFF6B35),
              icon: Icons.warning_amber_rounded,
            ),
          ],
          if (tariff.dieselSurchargeFee > 0) ...[
            const SizedBox(height: 6),
            _FeeRow(
              label: '⛽ Brandstoftoeslag',
              value: tariff.formattedDieselFee,
              color: AppColors.warning,
              icon: Icons.local_gas_station_rounded,
            ),
          ],
          const Divider(color: AppColors.bgCardLight, height: 20),
          _FeeRow(
            label: 'TOPLAM',
            value: tariff.formattedTotal,
            color: AppColors.success,
            isBold: true,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.95, 0.95));
  }
}

class _FeeRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isBold;
  final IconData? icon;

  const _FeeRow({
    required this.label,
    required this.value,
    required this.color,
    this.isBold = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isBold
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                fontSize: isBold ? 13 : 12,
                fontWeight:
                    isBold ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: isBold ? 16 : 13,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
