import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/locale_provider.dart';
import '../../../data/models/tariff_zone_model.dart';

class TariffScreen extends ConsumerStatefulWidget {
  const TariffScreen({super.key});

  @override
  ConsumerState<TariffScreen> createState() => _TariffScreenState();
}

class _TariffScreenState extends ConsumerState<TariffScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Düzenlenebilir tarife verileri
  UserTariff _tariff = UserTariff.defaultTariff();

  // Haven tarifeleri düzenleme state
  bool _isEditingHaven = false;
  final Map<String, TextEditingController> _havenControllers = {};

  // Genel ücret kontrolcüleri
  late TextEditingController _tunnelCtrl;
  late TextEditingController _gensetCtrl;
  late TextEditingController _adrCtrl;
  late TextEditingController _dieselDefaultCtrl;
  late TextEditingController _perKmRateCtrl;
  late TextEditingController _minimumFeeCtrl;

  // Yeni haven ekleme
  final _newHavenRangeCtrl = TextEditingController();
  final _newHavenFeeCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initControllers();
  }

  void _initControllers() {
    _tunnelCtrl =
        TextEditingController(text: _tariff.tunnelFee.toStringAsFixed(2));
    _gensetCtrl =
        TextEditingController(text: _tariff.gensetFee.toStringAsFixed(2));
    _adrCtrl = TextEditingController(text: _tariff.adrFee.toStringAsFixed(2));
    _dieselDefaultCtrl = TextEditingController(
      text: _tariff.defaultDieselSurchargePercent.toStringAsFixed(1),
    );
    _perKmRateCtrl =
        TextEditingController(text: _tariff.perKmRate.toStringAsFixed(2));
    _minimumFeeCtrl =
        TextEditingController(text: _tariff.minimumFee.toStringAsFixed(2));

    // Haven kontrolleri
    for (final entry in _tariff.havenRates.entries) {
      _havenControllers[entry.key] =
          TextEditingController(text: entry.value.toStringAsFixed(2));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tunnelCtrl.dispose();
    _gensetCtrl.dispose();
    _adrCtrl.dispose();
    _dieselDefaultCtrl.dispose();
    _perKmRateCtrl.dispose();
    _minimumFeeCtrl.dispose();
    for (final c in _havenControllers.values) {
      c.dispose();
    }
    _newHavenRangeCtrl.dispose();
    _newHavenFeeCtrl.dispose();
    super.dispose();
  }

  void _saveGeneralFees() {
    final tunnel =
        double.tryParse(_tunnelCtrl.text.replaceAll(',', '.')) ?? 17.60;
    final genset =
        double.tryParse(_gensetCtrl.text.replaceAll(',', '.')) ?? 0.0;
    final adr = double.tryParse(_adrCtrl.text.replaceAll(',', '.')) ?? 0.0;
    final diesel =
        double.tryParse(_dieselDefaultCtrl.text.replaceAll(',', '.')) ?? 0.0;

    setState(() {
      _tariff = _tariff.copyWith(
        tunnelFee: tunnel,
        gensetFee: genset,
        adrFee: adr,
        defaultDieselSurchargePercent: diesel,
      );
    });
    _showSaveSnack();
  }

  void _saveHavenRates() {
    final Map<String, double> newRates = {};
    for (final entry in _havenControllers.entries) {
      final val =
          double.tryParse(entry.value.text.replaceAll(',', '.')) ?? 0.0;
      newRates[entry.key] = val;
    }
    setState(() {
      _tariff = _tariff.copyWith(havenRates: newRates);
      _isEditingHaven = false;
    });
    _showSaveSnack();
  }

  void _addHavenRate() {
    final range = _newHavenRangeCtrl.text.trim();
    final fee =
        double.tryParse(_newHavenFeeCtrl.text.replaceAll(',', '.')) ?? 0.0;
    if (range.isEmpty || fee <= 0) return;

    final newRates = Map<String, double>.from(_tariff.havenRates);
    newRates[range] = fee;
    _havenControllers[range] =
        TextEditingController(text: fee.toStringAsFixed(2));

    setState(() {
      _tariff = _tariff.copyWith(havenRates: newRates);
    });
    _newHavenRangeCtrl.clear();
    _newHavenFeeCtrl.clear();
  }

  void _deleteHavenRate(String key) {
    final newRates = Map<String, double>.from(_tariff.havenRates);
    newRates.remove(key);
    _havenControllers[key]?.dispose();
    _havenControllers.remove(key);
    setState(() {
      _tariff = _tariff.copyWith(havenRates: newRates);
    });
  }

  void _saveKmZones() {
    final perKm =
        double.tryParse(_perKmRateCtrl.text.replaceAll(',', '.')) ?? 1.20;
    final min =
        double.tryParse(_minimumFeeCtrl.text.replaceAll(',', '.')) ?? 30.0;
    setState(() {
      _tariff = _tariff.copyWith(
        perKmRate: perKm,
        minimumFee: min,
      );
    });
    _showSaveSnack();
  }

  void _showSaveSnack() {
    final l10n = ref.read(appL10nProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.tariffSaved),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
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
      body: CustomScrollView(
        slivers: [
          // ── App Bar ─────────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 130,
            pinned: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0D47A1), Color(0xFF0A0E1A)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          l10n.tariffTitle,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          l10n.tariffSubtitle,
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
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.accent,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              tabs: [
                Tab(icon: const Icon(Icons.anchor_rounded, size: 18), text: l10n.tariffTabHaven),
                Tab(icon: const Icon(Icons.route_rounded, size: 18), text: l10n.tariffTabKmZone),
                Tab(icon: const Icon(Icons.tune_rounded, size: 18), text: l10n.tariffTabGeneral),
              ],
            ),
          ),

          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildHavenTab(),
                _buildKmZoneTab(),
                _buildGeneralTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Haven Tarifeleri Tab ───────────────────────────────────────────────────
  Widget _buildHavenTab() {
    final theme = Theme.of(context);
    final l10n = ref.watch(appL10nProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bölge Bilgisi
          _buildZoneInfoCard()
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.1),
          const SizedBox(height: 16),

          // Haven Tarifeleri Başlık
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.tariffTabHaven.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 1.2,
                ),
              ),
              Row(
                children: [
                  if (_isEditingHaven) ...[
                    TextButton.icon(
                      onPressed: () =>
                          setState(() => _isEditingHaven = false),
                      icon: const Icon(Icons.close_rounded, size: 14),
                      label: Text(l10n.tariffCancel, style: const TextStyle(fontSize: 12)),
                    ),
                    ElevatedButton.icon(
                      onPressed: _saveHavenRates,
                      icon: const Icon(Icons.save_rounded, size: 14),
                      label: Text(l10n.tariffSave,
                          style: const TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        minimumSize: const Size(0, 32),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12),
                      ),
                    ),
                  ] else
                    IconButton(
                      onPressed: () =>
                          setState(() => _isEditingHaven = true),
                      icon: const Icon(Icons.edit_rounded,
                          color: AppColors.accent),
                      tooltip: 'Tarifeleri Düzenle',
                    ),
                ],
              ),
            ],
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 10),

          // Tünel Ücreti Kartı
          _buildTunnelCard()
              .animate()
              .fadeIn(delay: 150.ms)
              .slideY(begin: 0.1),
          const SizedBox(height: 10),

          // Haven Tarife Kartları
          ..._tariff.havenRates.entries.indexed.map(
            (item) {
              final idx = item.$1;
              final entry = item.$2;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildHavenCard(
                  entry.key,
                  entry.value,
                  isEditing: _isEditingHaven,
                  controller: _havenControllers[entry.key],
                ).animate().fadeIn(delay: (200 + idx * 60).ms).slideX(begin: 0.05),
              );
            },
          ),

          // Yeni Haven Ekle
          if (_isEditingHaven) ...[
            const SizedBox(height: 8),
            _buildAddHavenCard()
                .animate()
                .fadeIn(delay: 300.ms)
                .slideY(begin: 0.1),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Km Aralık Tab ─────────────────────────────────────────────────────────
  Widget _buildKmZoneTab() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.08);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Açıklama
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: AppColors.info.withValues(alpha: 0.2)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 16, color: AppColors.info),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Adres teslimatı veya km bazlı fiyatlandırma için kullanılır. Teslimat mesafesine göre otomatik dilim seçimi yapılır.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 20),

          const Text(
            'KM ARALIK DİLİMLERİ',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 1.2,
            ),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 12),

          // Zone kartları
          ..._tariff.kmZones.indexed.map((item) {
            final idx = item.$1;
            final zone = item.$2;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildKmZoneCard(zone, idx)
                  .animate()
                  .fadeIn(delay: (150 + idx * 60).ms)
                  .slideX(begin: 0.05),
            );
          }),

          const SizedBox(height: 20),

          // Km Başı Ücret
          const Text(
            'KM BAŞI ÜCRET',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 1.2,
            ),
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _perKmRateCtrl,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        style:
                            const TextStyle(color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          labelText: 'Km başı ücret',
                          suffixText: '€/km',
                          prefixIcon: Icon(Icons.straighten_rounded),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _minimumFeeCtrl,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        style:
                            const TextStyle(color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          labelText: 'Minimum ücret',
                          suffixText: '€',
                          prefixIcon: Icon(Icons.price_check_rounded),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saveKmZones,
                    icon: const Icon(Icons.save_rounded, size: 18),
                    label: Text(ref.read(appL10nProvider).tariffSaveKm),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      minimumSize: const Size(0, 46),
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 450.ms),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Genel Tab ─────────────────────────────────────────────────────────────
  Widget _buildGeneralTab() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = ref.watch(appL10nProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GENEL ÜCRETLER',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 1.2,
            ),
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.08),
              ),
            ),
            child: Column(
              children: [
                _buildFeeField(
                  controller: _tunnelCtrl,
                  label: 'Kennedy Tünel Ücreti',
                  icon: Icons.alt_route,
                  color: AppColors.tunnel,
                  suffix: '€',
                ),
                const SizedBox(height: 12),
                _buildFeeField(
                  controller: _gensetCtrl,
                  label: 'Genset Ücreti',
                  icon: Icons.electrical_services_rounded,
                  color: const Color(0xFF00BCD4),
                  suffix: '€',
                  helperText: '0 = TBD (belirlenecek)',
                ),
                const SizedBox(height: 12),
                _buildFeeField(
                  controller: _adrCtrl,
                  label: 'ADR Ücreti',
                  icon: Icons.warning_amber_rounded,
                  color: const Color(0xFFFF6B35),
                  suffix: '€',
                  helperText: '0 = TBD (belirlenecek)',
                ),
                const SizedBox(height: 12),
                _buildFeeField(
                  controller: _dieselDefaultCtrl,
                  label: 'Varsayılan Dizel Toeslag',
                  icon: Icons.local_gas_station_rounded,
                  color: AppColors.warning,
                  suffix: '%',
                  helperText: 'Yeni teslimat oluştururken ön yüklenir',
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saveGeneralFees,
                    icon: const Icon(Icons.save_rounded, size: 18),
                    label: Text(l10n.tariffSaveGeneral),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      minimumSize: const Size(0, 46),
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 20),

          // Varsayılana sıfırla
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.restore_rounded,
                    color: AppColors.error, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.tariffResetAll,
                    style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant, fontSize: 13),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: theme.colorScheme.surface,
                        title: Text(l10n.tariffReset,
                            style: TextStyle(color: theme.colorScheme.onSurface)),
                        content: Text(
                          l10n.tariffResetConfirm,
                          style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: Text(l10n.tariffCancel),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(ctx).pop();
                              for (final c
                                  in _havenControllers.values) {
                                c.dispose();
                              }
                              _havenControllers.clear();
                              setState(() {
                                _tariff = UserTariff.defaultTariff();
                              });
                              _initControllers();
                              _showSaveSnack();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                            ),
                            child: Text(l10n.tariffDoReset),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text(l10n.tariffDoReset,
                      style: const TextStyle(color: AppColors.error)),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ─── Widget Yardımcılar ──────────────────────────────────────────────────
  Widget _buildTunnelCard() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.tunnel.withValues(alpha: 0.15),
            theme.colorScheme.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.tunnel.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.tunnel.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                const Icon(Icons.alt_route, color: AppColors.tunnel, size: 26),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kennedy Tünel Ücreti',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Sağ ↔ Sol kıyı geçişlerinde uygulanır',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${AppConstants.tunnelFee.toStringAsFixed(2)} €',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.tunnel,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHavenCard(
    String range,
    double fee, {
    required bool isEditing,
    TextEditingController? controller,
  }) {
    final sideColor = _getHavenRangeColor(range);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.08);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isEditing
                ? AppColors.accent.withValues(alpha: 0.3)
                : borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: sideColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  'Haven',
                  style: TextStyle(
                    color: sideColor.withValues(alpha: 0.7),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  range,
                  style: TextStyle(
                    color: sideColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: isEditing && controller != null
                ? TextFormField(
                    controller: controller,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700),
                    decoration: const InputDecoration(
                      suffixText: '€',
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                    ),
                  )
                : Text(
                    '${fee.toStringAsFixed(2)} €',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.success,
                    ),
                  ),
          ),
          if (isEditing)
            IconButton(
              onPressed: () => _deleteHavenRate(range),
              icon: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.error, size: 18),
            ),
        ],
      ),
    );
  }

  Widget _buildAddHavenCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: AppColors.accent.withValues(alpha: 0.2),
            style: BorderStyle.solid),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'YENİ HAVEN TARİFESİ EKLE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.accent,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _newHavenRangeCtrl,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Haven / Aralık',
                    hintText: 'örn: 1700 veya 900-950',
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: _newHavenFeeCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Ücret',
                    suffixText: '€',
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _addHavenRate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  minimumSize: const Size(44, 44),
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Icon(Icons.add_rounded, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKmZoneCard(TariffZone zone, int index) {
    const colors = [
      Color(0xFF1E88E5), // Mavi
      Color(0xFF43A047), // Yeşil
      Color(0xFFFB8C00), // Turuncu
      Color(0xFF8E24AA), // Mor
    ];
    final color = colors[index % colors.length];

    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.route_rounded, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  zone.label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  zone.perKmRate != null && zone.perKmRate! > 0
                      ? '${zone.perKmRate!.toStringAsFixed(2)} €/km'
                      : 'Sabit ücret',
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            '${zone.fixedFee.toStringAsFixed(2)} €',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneInfoCard() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.08);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LİMAN BÖLGELERİ',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(
                child: _ZoneInfo(
                  color: AppColors.rechteroever,
                  name: 'Rechteroever',
                  turkishName: 'Sağ Kıyı',
                  range: 'Haven 1 – 999',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _ZoneInfo(
                  color: AppColors.linkeroever,
                  name: 'Linkeroever',
                  turkishName: 'Sol Kıyı',
                  range: 'Haven 1000 – 2000',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeeField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color color,
    required String suffix,
    String? helperText,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: color, size: 20),
        suffixText: suffix,
        helperText: helperText,
        helperStyle: const TextStyle(color: AppColors.textMuted, fontSize: 10),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: color.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: color, width: 1.5),
        ),
      ),
    );
  }

  Color _getHavenRangeColor(String range) {
    final num = int.tryParse(range.replaceAll(RegExp(r'[^0-9]'), '').substring(0,
        range.replaceAll(RegExp(r'[^0-9]'), '').length.clamp(1, 4)));
    if (num == null) return AppColors.textSecondary;
    if (num >= 1 && num <= 999) return AppColors.rechteroever;
    return AppColors.linkeroever;
  }
}

class _ZoneInfo extends StatelessWidget {
  final Color color;
  final String name;
  final String turkishName;
  final String range;

  const _ZoneInfo({
    required this.color,
    required this.name,
    required this.turkishName,
    required this.range,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                name,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            turkishName,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            range,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
